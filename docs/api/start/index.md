---
layout: default
title: API Documents
api_menu: 1
on_page: api_start

---

Start
=====

All methods in this section can be carried out by a connection to the **/ws/start** server.

Each method appends to the route **/** e.g. 'login' method would be on route **/login**

The Start Server should be the first place you connect to on the game server. It will give you
the names of other servers which are currently active in the game. It also has the
functionality to allow you to log into your account.


---
Client Code
========

A Client Code is used to identify a client to the server. A Client Code is provided by the server
and once given it should continue to be used, even if you log out and back in again. This
enables the server to retain your settings.

A session is associated with a Client Code and it  may 'time-out' (after a few hours) but even so, 
you should still keep the same Client Code for subsequent sessions.

A Client may be a different web browser (Internet Explorer, Chrome, Safari etc.) or a
different computer, or a script running. Each of these should be given a different Client Code

In the following API calls, if it specifies a Client Code then it is mandatory. If you do not
supply a Client Code the call will be rejected.



---
Server : connect
================

On making a Web Socket connection, the server will send a **connect** message indicating the
current status of the room. It may also send an update whenever the server status changes.

{% highlight JSON %}
{
    "code"          : 0,
    "message"       : "Welcome to the Space Bot War game server.",
    "data"          : "server",
}
{% endhighlight %}

code
----

The numeric code representing the status of the **server** where **0** represents success
and any other value indicates a fault.

message
-------

A human readable message, for example a message to the effect that the server is off-line.

data
----

Supplimentary data, for example the time at which the server is due back on line.




---
Client : get_client_code
========================

This is on the route **/get_client_code**

Get a new Client Code. Note you should only do this if you do not have a Client Code.
e.g. if this is the first time on this computer, or with this Web Browser. If you do have 
one (even if it is timed out) you should reuse it.

{% highlight JSON %}
{
    "msg_id"        : 123,
    "client_code"   : "1660686c-8b5d-3b7c-825d-1d828db8f9ca-2f928",
}
{% endhighlight %}

msg_id (optional)
-----------------

An **ID** to identify this message. If used the server reply will contain the same message
ID. This can be useful if you wish to link the server response to the client request.

client_code (optional)
----------------------

You can validate/refresh your existing client code. If valid the server will return
the same Client Code. If not valid it will return a new one.

If you do not supply a Client code, then you will get a new one.

RESPONSE
--------

The server will respond with a **Server : get_client_code** message.




---
Server : get_client_code
======================

Server response to the **Client : get_client_code** request

{% highlight JSON %}
{
    "code"          : 0,
    "message"       : "OK",
    "client_code"   : "1660686c-8b5d-3b7c-825d-1d828db8f9ca-2f928",
    "msg_id"        : 123,
}
{% endhighlight %}

The **code**, **message** and **msg_id** are the standard server response.

client_code
-----------

This is the Client Code you should use from now on with this browser/computer
combination. Even if the session times out the Client Code will still be valid
for later sessions and you should not request another one.




---
Client : get_radius
===================

This is on the route **/get_radius**

Get the API keys for the Radius login (note, Radius login is not yet implemented)

{% highlight JSON %}
{
    "msg_id"        : 123,
}
{% endhighlight %}

msg_id (optional)
-----------------

An **ID** to identify this message. If used the server reply will contain the same message
ID. This can be useful if you wish to link the server response to the client request.
(I am probably not going to mention this again, take it as read)

RESPONSE
--------

The server will respond with a **Server:: get_radius** message.




---
Server : get_radius
===================

Return the radius API key values. In response to a **Client : get_radius** request.

{% highlight JSON %}
{
    "msg_id"            : 123,
    "code"              : 0,
    "message"           : "Radius API key",
    "radius_api_key"    : "78855680-671c-4c70-b294-3e392a0a7c80",
}
{% endhighlight %}

radius_api_key
--------------

This is the key that should be sent to the Radius Social login site.





---
Client : register
=================

This is on the route **/register**

Register a new account with the server.

{% highlight JSON %}
{
    "msg_id"            : 123,
    "client_code"       : "1660686c-8b5d-3b7c-825d-1d828db8f9ca-2f928",
    "username"          : "james_bond",
    "email"             : "jb@mi5.gov.co.uk",
    "password"          : "TopS3cret",
}
{% endhighlight %}

username (required)
------------------

This is the nickname you will be known as and will be part of your login credentials. It should be
at least three characters long.

email (required)
----------------

Your email address, this will be used to help you recover your password should your forget it.

Your email address will need to be verified before you complete the registration process.

password (required)
------------------

The password you will use to log in. It must be at least five characters long, should include
at least of of the following - Uppercase character, Lowercase character, Number.

RESPONSE
--------

The server will respond with a **Server : register** message.




---
Server : register
=================

In response to a **Client : registe** request.

Gives a standard response with **msg_id**, **code**, and **message**




---
Client : forgot_password
========================

NOT YET IMPLEMENTED

This is on the route **/forgot_password**

Request the server to send an email which will allow access to an account where the password
has been forgotten.

{% highlight JSON %}
{
    "msg_id"            : 123,
    "client_code"       : "1660686c-8b5d-3b7c-825d-1d828db8f9ca-2f928",
    "username_or_email" : "james_bond",
}
{% endhighlight %}

username_or_email (required)
-------------------

One or other, but not both, of **username** or **email** should be provided in order to
identify the account.

NOTE: The server responds with success whether or not an account with that username or
email was found. The client should inform the user something along the lines of
'If an account with that username or email is found, a password reminder will be sent'
so as to prevent a phishing attack to determine if a particular email address is in use.

If verified, then an email will be sent to the registered email address with
details of how to log in.

RESPONSE
--------

There will be a **Server : forgot_password** response.



---
Server : forgot_password
========================

The response to a **Client : forgot_password** request.

Gives a standard response with **msg_id**, **code**, and **message**




---
Client : login_with_password
============================

This is on the route **/login_with_password**

Log into the server by giving the username and password

{% highlight JSON %}
{
    "msg_id"            : 123,
    "client_code"       : "1660686c-8b5d-3b7c-825d-1d828db8f9ca-2f928",
    "username"          : "james_bond",
    "password"          : "TopS3cret",
}
{% endhighlight %}

username (required)
-------------------

Your unique username.

password (required)
-------------------

Your password. Note this is case sensitive and must be entered exactly.

RESPONSE
--------

The server will respond with a **Server : login_with_password** message





---
Server : login_with_password
============================

The server response to a **Client : login_with_password** message.

Gives a standard response with **msg_id**, **code**, and **message**

If successful, you will now be logged in with access to your account.




---
Client : login_with_email_code
==============================

NOT YET IMPLEMENTED

This is on the route **/login_with_email_code**

The email sent as a result of the **Client : forgot_password** message
will have a link allowing you to log directly into your account and
to then change your password.

{% highlight JSON %}
{
    "msg_id"            : 123,
    "client_code"       : "1660686c-8b5d-3b7c-825d-1d828db8f9ca-2f928",
    "email_code"        : "342e883c-ab8e-8782-fe89-9d828db8f9ca-2ea8d",
}
{% endhighlight %}

email_code (required)
---------------------

The code sent in the email.

RESPONSE
--------

The server responds with a **Server : login_with_email_code**




---
Server : login_with_email_code
==============================

The server response to a **Client : login_with_email_code** message.

Gives a standard response with **msg_id**, **code**, and **message**

If successful, you will now be logged in with access to your account.




---
Client : logout
===============

This is on the route **/logout**

The client is logged out of the server.

{% highlight JSON %}
{
    "msg_id"            : 123,
    "client_code"       : "1660686c-8b5d-3b7c-825d-1d828db8f9ca-2f928",
}
{% endhighlight %}

RESPONSE
--------

The server will log the user out and respond with a **Server : logout** 
message.




---
Server : logout
===============

The server response to a **Client : logout** message.

Gives a standard response with **msg_id**, **code**, and **message**






