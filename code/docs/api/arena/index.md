---
layout: default
title: API Documents
api_menu: 1
on_page: api_arena

---

Arena
=====

All methods in this section can be carried out by a connection to the **/ws/arena** server.

Each method appends to the route **/** e.g. 'arenas' method would be on route **/arenas**

The Arena should be used to locate other servers which are running Matches. i.e. where
there are matches, or about to be, between two fleets of ships.

Note. Some Servers may only be available to you if you are logged in. See the **Start**
server for details on how to log in.

---
Server : connect
================

On making a Web Socket connection, the server will send a **connect** message indicating the
current status of the server. It may also send an update whenever the server status changes.

{% highlight JSON %}
{
    "code"          : 0,
    "message"       : "Welcome to the Arena",
    "data"          : "arena",
}
{% endhighlight %}

code
----

The numeric code representing the status of the **lobby** where **0** represents success
and any other value indicates a fault.

message
-------

A human readable message, for example a message to the effect that the server is off-line.

data
----

Supplimentary data, for example the time at which the server is due back on line.





---
Client : arenas
===============

Get the list of all the current matches.

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

client_code (required)
----------------------

Your client code.

RESPONSE
--------

The server will respond with a **Server : arenas** message.





---
Server : arenas
===============

Server response to the **Client : arenas** request

{% highlight JSON %}
{
    "msg_id"        : 123,
    "code"          : 0,
    "message"       : "Arenas",
    "arenas"        : [{
        "server"        : "ws://spacebotwar.com/ws/match/scott",
        "spectators"    : 23,
        "start_time"    : -30,
        "status"        : "running",
        "competitors"       : [{
            "name"          : "Scaredy Pants",
            "rank"          : 37,
            "programmer"    : "Dr Death",
        },{
            "name"          : "Hunter",
            "rank"          : 42,
            "programmer"    : "Blotto",
        }],
    },{
        "route"         : "/ws/arena/silver",
        ... etc.
    }]
}
{% endhighlight %}

The **code**, **message** and **msg_id** are the standard server response.

arenas
------

This is an array of all arenas available to you. Note, if you are not logged
in then some rooms may not be available to you.

####server

The Server hosting the arena. In order to watch a match you need to make a connection
to that server. To leave a match you break the connection.

####spectators

The number of other people currently viewing this match.

####start_time

The time that this match started in seconds. Negative means the match has
already started. Positive is the number of seconds before the match starts.

####status

This is the status of the match, it can be one of

  * **starting** the match is currently being set up. Not yet started
  * **running** the match is underway
  * **closing** the match is over and a winner has been decided.

####competitors

The two competitors being matched against each other.

  * **name** of the program
  * **rank** current rank of the program
  * **programmer** name of the programmer/owner


---
Client : connection to arena
============================

To watch a match between two competitors, you first need to make a connection
to the server. A list of the current matches can be found in the **arena**.

When you make a connection to the arena you are automatically registered to
receive updates on the match progress. This is through a **Server : arenas_state**
message (see below).

Once you have connected to a room you can make a number of requests, where the
**route** is the name of the method. e.g. **/arena_status**

A full list of methods to use within a Match server can be found in the **Match**
API.






