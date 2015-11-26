---
layout: post
title: Separation of Concerns
categories:
- blog
---

Learning about the Javascript framework [Backbone](http://backbonejs.org) has
been a timeconsuming process, but I think it is worthwhile especially when
embarking on a potentially large javascript application (like SpaceBotWar).

One problem I have encountered many times in the past is convoluted code which
has many diverse tasks. e.g. code which captures user input, sends data to the
server, waits for the response, renders the html output, all mixed in together.

Backbone solves this problem elegantly but it requires a bit of thought, this
example shows how I tackled the thorny issue of how to log in and out :)

Using the Model View Controller design pattern we can create a Model that just
models the status of the user.

{% highlight javascript %}

// app/models/login_status.js

define([    "jquery",   "backbone"],
function(    $,          Backbone) {
    // Creates a new Backbone Model class object
    var LoginStatus = Backbone.Model.extend({

        defaults : {
            logged_in   : false,
        },
        initialize : function() {
        }
    });
    return LoginStatus;
});
{% endhighlight %}

As it stands, it just has a single attribute, 'logged_in' which reflects the
logged in status of the user.

In order to log in, we need a log-in form. When we are logged out, we will
display a form to allow username and password to be entered, when we are 
logged in we can display a button to 'log out'. Now this could be done by
having a template and passing in the 'logged_in' status and having conditional
code to display either one view or the other. I prefer keeping logic out
of the template and putting it in the view so I created two templates.

{% highlight html %}

<!-- app/templates/all/main/logged_out.html -->

<div class="login">
  <input type="text" placeholder="Username" id="username">
  <input type="password" placeholder="Password" id="password">
  <p><button id="login" type="button" class="btn btn-default">Sign In</button>
  <a id="lost_password" href="/#/lost_password" class="forgot">lost password?</a></p>
  <p><button id="register" type="button" class="btn btn-default">Register</button></p>
</div>
{% endhighlight %}

{% highlight html %}
<!-- app/templates/all/main/logged_in.html -->

<div class="login">
  <p><button id="logout" type="button" class="btn btn-default">Log Out</button>
</div>
{% endhighlight %}

The decision on which one of these templates is displayed can now be delegated to the View.

{% highlight javascript %}

<!-- app/views/dt/main/login_status.js -->

define([    'jquery',   'hbs!templates/all/main/logged_in',  'hbs!templates/all/main/logged_out', 'backbone', 'marionette'],
function (   $,          template_logged_in,                 template_logged_out,                Backbone) {
    //ItemView provides some default rendering logic
    return Backbone.Marionette.ItemView.extend({
        render : function() {
            if (this.model.get('logged_in')) {
                $(this.el).empty().html(template_logged_in);
            }
            else {
                $(this.el).empty().html(template_logged_out);
            }
        }
        initialize  : function() {
            this.model.bind('change:logged_in', this.render, this);
        }
    });
});
{% endhighlight %}

As it stands, when the app starts, it will display the login form, since the
logged_in attribute in the model defaults to false (which is what we want).

Notice that the View binds to any change in the logged_in attribute of the
Model. This is what I mean by separation of concerns. The View simply has to
render the appropriate template whenever the logged_in status changes, it does
not care *how* it changes. Similarly all the Model has to do is maintain the
status of the attribute and not care about how the View changes.

Now, what should happen when we fill in the login form, username and password
and click the 'Log in' button? Well, eventually it needs to send a message to
the server and get the response, but again I am going to delegate that work
to something other than the view.

{% highlight javascript %}

<!-- app/views/dt/main/login_status.js -->

    ...
    return Backbone.Marionette.ItemView.extend({
        render : function() {
            ...
        },
        events          : {
            'click #login'          : 'login',
            'click #logout'         : 'logout',
        },
        login   : function() {
            var username = $('#username').val();
            var password = $('#password').val();
            Backbone.trigger("user:login", {  username : username, password : password} );
        },
        logout  : function() {
            Backbone.trigger("user:logout");
        },


    ...
{% endhighlight %}

In this case I have bound the *click* events for the *login* and *logout* buttons
to similarly named methods. In those routines I have made use of the Backbone event
handler to *trigger* an event using the namespaces **user:login** and **user:logout**
respectively. As far as the view is concerned, it does not matter how these events
are handled, so long as there is something listening for those events. Indeed there
can be more than one listener and all of them would be informed.

And the listener? Well I decided to create a component that had the sole responsibility
of co-ordinating communication with the server. Part of which is as follows. [This article on
decoupling](http://lostechies.com/derickbailey/2012/04/19/decoupling-backbone-apps-from-websockets/)
was the influence for the design.

{% highlight javascript %}

// app/components/lobby.js

define([    'my-config',    'jquery',    'backbone', 'humane',  'jquery.json'],
function (   MyConfig,       $,           Backbone,   Humane) {

    // The Lobby is responsible for handling login and registration
    //
    var Lobby = function() {
        var ws;

        return {
            init    : function() {
                ...
                // The user has logged in
                Backbone.on("user:login", function(data) {
                    var msg = {
                        route   : "/lobby/login_with_password",
                        content : {
                            password    : data.password,
                            username    : data.username,
                            client_code : client_code
                        }
                    };
                    ws.send(JSON.stringify(msg));
                });
                // The user has logged out
                Backbone.on("user:logout", function() {
                    var msg = {
                        route   : "/lobby/logout",
                        content : {
                            client_code : client_code
                        }
                    };
                    ws.send(JSON.stringify(msg));
                });
                ...
            }
        };
    };
    return Lobby;
});

{% endhighlight %}

**ws** is a WebSocket object, the details of which I won't go into, suffice to say
that it has a **send** method which sends a message to the server and an **onmessage**
method which accepts messages from the server.

The two *Backbone.on* methods are registering a callback function for each of the
events **user:login** and **user:logout** that we saw earlier in the **LoginStatus** view.

We happen to be using Web Sockets to communicate with the server, but by decoupling the
code in this way we would be free to change the communication with minimal change to
the rest of the code.

The **user:login** event results in a message to the server of **/lobby/login_with_password**

All that remains now is to create an event on recept of the server confirming the
receipt of the login or the logout messages, which put a **ws:recv:/lobby/login_with_password** or
a **ws:recv:/logout** message on the Event Handler bus respectively.

And what do we need to do when we receive confirmation? We need to change the state of
the **logged_in** attribute in the LoginStatus Model of course.

{% highlight javascript %}

    // app/models/login_status.js

    ...
    var LoginStatus = Backbone.Model.extend({

        ...
        initialize: function() {
            Backbone.on("ws:recv:/lobby/login_with_password", this.login_success, this);
            Backbone.on("ws:recv:/lobby/logout", this.logout_success, this);
        },

        logout_success : function(data) {
            this.set({'logged_in' : false});
        },

        login_success : function(data) {
            this.set({'logged_in' : true});
        },
        ...
{% endhighlight %}

Which takes us full circle since we have already seen that when the **logged_in** status
changes it also triggers a change in the view.

And although this might seem to be a convoluted and complex method to simply handle a
single flag (logged_in) it really comes into it's own with more complex examples, ensuring
that each module has a simple, single thing to do. It also makes testing so much easier as
well!




