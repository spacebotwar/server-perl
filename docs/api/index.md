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
several examples of simple web clients you can build upon if you wish.

Example Calls
-------------

Here is an example connection to a Web Socket (in Perl)

{% highlight perl %}
use AnyEvent::WebSocket::Client;

my $client = AnyEvent::WebSocket::Client->new;

my $connection;

$client->connect("ws://spacebotwar.com/ws")->cb(sub {
    ...
});
{% endhighlight %}

More complete examples can be found in the examples directory.

API hierarchy
-------------

The API call is split into several components.

###Connection

A Connection is to a specific **server**. Multiple servers can be added to scale out
horizontally. Servers may offer different functional areas, e.g. chat, game control etc. Each
functional area may be scaled out by adding (or removing) servers based on the demand.

Typically you will only make a connection to one server in each functional area, for example to one chat
server or to one game server so the first objective is to get a list of all servers for each
of the functional areas.

Connect to the "ws://spacebotwar.com/ws" server. This will give you a list of servers and
server types to which you can connect and is the sole purpose of this server.

Each of the connections will require a separate web-socket.


#### Chat servers
A Chat server allows you communicate with other players, either globally, or privately.

#### Arena servers
The Arena is where matches between competitors is organized. This is a one-to-one competition
between two competitors but other competitors can view the match in progress.

#### Game servers
Other Game functionality is controlled by the game servers.

Routes
------

A **route** defines a specific command in the API and these routes use a path-like structure to
group commands with similar functionality. e.g. user account commands are **/user/register**, 
**/user/login** and **/user/logout**


Web Socket Message Structure
----------------------------

A web-socket message has a JSON encoded string as its payload. This is an example of a client request
to log in.

{% highlight json %}
{
    "username"  : "james_bond",
    "password"  : "topS3cret",
    "msg_id"    : "123",
    ...
}
{% endhighlight %}

This shows a message from a client to the server. In this case a 'registration' for a new user.

The arguments are self explanatory except for the **msg_id** which will be described below.

A server response will have a similar JSON message structure.

{% highlight JSON %}
{ 
  "server"   : "Kingsley",
  "type"     : "game", 
  "route"    : "/user/login", 
  "content"  : { 
    "code"     : "0", 
    "msg_id"   : "123",
    ...
    "message"  : "Welcome" 
  } 
}
{% endhighlight %}

The **code** is the success or failure of the request (zero is always success, failure is
denoted by a none zero error code).

The **msg_id** is used to link the client request with the server response. This is required
since the response may be asynchronous. There is no guarantee that the response will be sent
back immediately with the return code so the client needs some way to tie in some future
response back with the previous request. It does so by the unique msg_id. The simplest way
to implement this is by an auto incrementing number.

Note that there will be cases where the server sends messages which were not requested (such as
status changes) where the msg_id will not be relevant and may not be included.

