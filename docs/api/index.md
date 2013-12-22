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

$client->connect("ws://spacebotwar.com/ws/game/lobby")->cb(sub {
    ...
});
{% endhighlight %}

A more complete example can be found in the examples directory.

API hierarchy
-------------

The API call is split into several components.

###Connection

Each connection requires a separate Web Socket Connection. e.g. **ws://spacebotwar.com/ws/chat** is
the connection to the chat system. There is also a **game** and an **arena** system. You may have a
Web Socket connection into more than one of these at the same time.

###Room

A Connection will allow you to enter one or more **rooms** which are just convenient localities to
separate the total environment into smaller managable sections. For example in the **chat** system
it would be hard to follow conversations if everyone was in the same room. On making a connection
you should join the **lobby** which is a room that is always available and from which you can obtain
a list of all other rooms that can be joined.

###Route

A **route** defines a specific command in the API and these routes use a path-like structure to
group commands with similar functionality. e.g. user account commands are **/user/register**, 
**/user/login** and **/user/logout**

Web Socket Message Structure
----------------------------

A web-socket message has a JSON encoded string as it's payload. This is an example of a server response.

{% highlight JSON %}
{ "room" : "zone_1", "route" : "/user/register_status", "content" : { "code" : "0", "message" : "Registered" } }
{% endhighlight %}

To help to distinguish between client or server messages we will include either **Server** or **Client**
in the header for each section. e.g.

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










