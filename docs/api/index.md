---
layout: default
title: API Documents
api_menu: 1
on_page: api
---

API Documents
=============

This document describes the SpaceBotWar server and the open API that will 
enable you to interact with it.

The API is the same one that is used by the SpaceBotWar User Interface (UI)
so anything you can do in the UI you can do from an external program.

Server
------

The playable servers are as follows.

    spacebotwar.com

Web Sockets
-----------

The Web Servers predominatly use Web Socket technology. This offers significant
advantages over HTTP requests, even AJAX calls using HTTP.

  * The overhead for each request is much smaller making for a faster response. An AJAX call could typically have 1200 bytes of header for 8 bytes of data. For the same data in Web Socket the header is about 8 bytes.
  * It is asynchronous and full-duplex. This means the server can *push* data to the client at any time. The client no longer has to resort to frequent polling or similar techniques.
  * By only supporting Web Sockets, the server can be significantly trimmed down making it faster and cheaper. We can then scale out horizontally, providing more power at a cheaper cost.

The consequence however is that your client code needs to be a little more sophisticated. We have provided
several examples of simple web servers you can build upon if you wish.

Example Calls
-------------

Here is an example connection to a Web Socket (in Perl)

{% highlight perl %}
use AnyEvent::WebSocket::Client;

my $client = AnyEvent::WebSocket::Client->new;

my $connection;

$client->connect("ws://spacebotwar.com/ws/start")->cb(sub {
    ...
});
{% endhighlight %}

A more complete example can be found in the examples directory.

API hierarchy
-------------

The API call is split into several components.

###Connection

A Connection is to a specific **server**, there are three functional areas in Space Bot War,
one that controls the game, one for the chat system, one for the system that competes players
in matches. These functional areas are each served by several servers and servers are free to
be added and removed as needed. To access these areas you make a connection as follows.

#### Start

Connect to the **/ws/start** server which will allow you to log on and to obtain the server
names for all the servers controlling the operation of the game.

#### Lobby

The Lobby is the entry point to the chat system and is always on **/ws/lobby** server. From here
you can obtain a list of all other chat servers.

#### Arena

The Arena is where matches between competitors is organized. Connect to **/ws/arena** to get a
list of all servers which are currently available.

Each of these three areas requires a separate Web Socket connection. You may run one connection
to each functional area at a time.

###Route

A **route** defines a specific command in the API and these routes use a path-like structure to
group commands with similar functionality. e.g. user account commands are **/user/register**, 
**/user/login** and **/user/logout**


###Putting it together

Putting the connection and the Route together.

  * Connection - **ws://spacebotwar.com/ws/start**
  * Route - **/general/post_message**

Gives the connection string of **ws://spacebotwar.com/chat/general/post_message**

Web Socket Message Structure
----------------------------

A web-socket message has a JSON encoded string as it's payload. This is an example of a server response.

{% highlight JSON %}
{ "server" : "Kingsley", "route" : "/user/register", "content" : { "code" : "0", "message" : "Registered" } }
{% endhighlight %}

The **server** identifies which server the response came from. The **route** identifies the message and
the **content** is the message payload.

This might be documented as follows...

###Client : Register

Send a registration message from the client to the server.

{% highlight json %}
{
    "username"  : "james_bond",
    "password"  : "topS3cret",
    "email"     : "agent007@mi5.gov.co.uk",
    "msg_id"    : "123",
}
{% endhighlight %}

This shows a message from a client to the server. In this case a 'registration' for a new user.

The arguments are self explanatory except for the **msg_id**

####msg_id

This is a unique number for the message. Due to the asynchronous nature of Web Sockets
there is often no correlation between a client request and the server response. The **msg_id**
is a way for the client to match a server response to an earlier client request.

The simplest way to implement this is to have a counter on the client which is incremented for
each message sent. So sending a *Client : Register* request (message number 123) will result in
a *Server Register* response with msg_id 123.

Note that there will be cases where the server sends messages which were not requested (such as
status changes) where the msg_id will not be relevant and may not be included.

