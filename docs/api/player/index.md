---
layout: default
title: API Documents
api_menu: 1
on_page: api_player

---

Player
======

All methods in this section can be carried out by a connection to the **/ws/player** server.

Each method appends to the route **/** e.g. 'foo' method would be on route **/foo**

The Player API should only be used internally, however if the API is made open to running
programs externally, on privately owned servers, then this API would need to be implemented
on those servers.

Note. In this case the **client** will be the game server and the **server** will be the
Web Socket server responsible for running the players code. This API is not intended to be called
from a Web Browser (although there may be some debugging options which may make it desirable)





---
Server : connect
================

On making a Web Socket connection, the server will send a **connect** message indicating the
current status of the server. It may also send an update whenever the server status changes.

{% highlight JSON %}
{
    "code"          : 0,
    "message"       : "Welcome to Darwin",
    "data"          : "player",
}
{% endhighlight %}

code
----

The numeric code representing the status of the server where **0** represents success
and any other value indicates a fault.

message
-------

A human readable message, for example a message to the effect that the server is off-line.

data
----

Supplimentary data, for example the time at which the server is due back on line.




---
Client : init_program
====================

Initialise the server to provide the code for a new program

{% highlight JSON %}
{
    "msg_id"        : 123,
    "server_secret" : "let's keep this between ourselves.the8g3sthe",
    "program_id"    : "8793ecd3a",
}
{% endhighlight %}

server_secret (required)
------------------------

This is an identification method to reduce the chance of unauthorized
use of the interface except by clients that know the server secret.
Each server should specify a unique string.

program_id (required)
---------------------

This is a unique identifier for the program (we may take this from the
git commit key)


RESPONSE
--------

The server responds with a **Server : init_program** message or an error
code.




---
Server : init_program
====================
The server will response to a **Client : init_program** request.


{% highlight JSON %}
{
    "msg_id"        : 123,
    "code"          : 0,
    "message"       : "Program",
    "program"        : {
        "id"            : "8793ecd3a",
        "name"          : "Superbo",
        "author"        : "Billy",
        "author_id"     : 5743,
        "created"       : "2013-01-04",
        "cloned_from"   : "e82671aef",
    }
}
{% endhighlight %}

The **code**, **message** and **msg_id** are the standard server response.

program
------

A hash of data representing the program that was requested.

id
--

The unique ID of the program that was requested.

name
----

The Name of the program.


author_id
---------

The unique author ID of the person who created (or cloned and modified) this
program.

author
------

The name of the author of this program.


created
-------

The date that the program was created (or cloned)


cloned_from
-----------

If the program is a modified clone of an existing program, the unique ID of
that program.




---
Client : start_state
====================

The client (the game server) sends the initial state of the game, this information
may be sent several times during the startup period of the match. The start position
and the ship stats should be cached. During the game itself, the static data will
not be resent, only the variable data (see **Client : next_position**)

{% highlight JSON %}
{
    match_id    : 23432,
    match_time  : -5.5,
    competitors : [
        {
        "id"            : "8793ecd3a",
        "name"          : "Superbo",
        "author"        : "Billy",
        "author_id"     : 5743,
        "created"       : "2013-01-04",
        "cloned_from"   : "e82671aef",
        },
        {
        "id"            : "023430d3a",
        "name"          : "Snowflake",
        "author"        : "Arsenic",
        "author_id"     : 2357,
        "created"       : "2013-01-09",
        "cloned_from"   : "7582af67",
        }
    ],
    ships       : [
        {
        "id"                    : 0,
        "competitor_id"         : "023430d3a",
        "name"                  : "ship",
        "x"                     : 340,
        "y"                     : 450,
        "orientation"           : 1.23,
        "max_thrust_forward"    : 60,
        "max_thrust_sideway"    : 20,
        "max_thrust_reverse"    : 30
        "max_rotation"          : 1.5,
        },
        ...
    ],
}
{% endhighlight %}

match_id
--------

The unique identifier for the match.

match_time
----------

The time, in seconds, from the start of the match, during the startup phase of
the match this will be negative, and represents the time until the match starts.

competitors
-----------

Information about the (two) competitors

### id

The unique ID of the program

### name

The name of the program

### author

The name of the author of the program.

### author_id

A unique ID for the author

### created

The date at which the program was last modified.

### cloned from

The ID of the program this one was cloned from (or blank if it is a totally new program)

ships
-----

An array of all ships, from both competitors, taking part in the match.

### id

The unique ID of the ship.

### competitor_id

The unique ID of the competitor

### name

The name of the ship.

### x

The start X co-ordinate of the ship in the arena

### y

The start Y co-ordinate of the ship in the arena

### orientation

The start orientation (direction it is pointing) of the ship in Radians

### max_forward_thrust

The maximum allowable forward thrust of the ship.

### max_reverse_thrust

The maximum allowable reverse thrust of the ship.

### max_sideway_thrust

The absolute maximum allowable sideways thrust of the ship (note sideway thrust may be positive or negative)

### max_rotation

The absolute maximum allowable rotation speed of the ship in Radians/sec (note rotation may be negative
or positive.

RESPONSE
--------

There is no response necessary from the server.




---
Client : game_state
===================

The current state of the game (sent once the match has started)

{% highlight JSON %}
{
    "code"          : 0,
    "message"       : "Match",
    "match_id"      : 23432,
    "match_time"    : -5.5,
    "spectators"    : 3,
    "ships       : [
        {
        "id"                    : 0,
        "owner_id"              : 1,
        "status"                : "ok",
        "health"                : 98,
        "x"                     : -456,
        "y"                     : 342,
        "rotation"              : 0.23,
        "orientation"           : 1.23,

        "direction"             : 1.35,
        "speed"                 : 60,

        "thrust_forward"        : 55,
        "thrust_sideway"        : 20,
        "thrust_reverse"        : 0,
        
        },
        ...
    ],
}
{% endhighlight %}

This is sent out every 500ms to all players. The message is cut down to the minimum,
only giving enough information to identify the ship and the dynamic (variable) data
such as speed and direction. The static information on ships was provided via the
**start_status** message which should be cached.

match_id
--------

(sent to all players)
The unique ID of the match.

match_time
----------

(sent to all players)
The current time of the match, in seconds, since the game started.

spectators
----------

(sent to all players)
The number of people watching the match

ships
-----

(sent to all players)
An array of all ships in the game, both the current player and the competitor.

id
--

(sent to all players)
A unique ID for the ship

owner_id
--------

(sent to all players)
The unique ID for the owner

x and y
-------

(sent to all players)
The current X,Y co-ordinate of the ship

direction
---------

(sent only to the player who does **not** own the ship)
The direction the ship is currently moving in (based on the vector of all three
thrust directions)

rotation
--------

(sent to all players)
The rate at which the ship is turning, in Radians per second. Positive value 
indicates anti-clockwise rotation, negative indicates clockwise rotation.

orientation
-----------

(sent to all players)
The current orientation of the ship (it may be different to the direction the
ship is moving, for example if it has sideways thrust)

speed
-----

(sent only to the player who does **not** own the ship)
The current speed of the ship (based on a vector of all the thrusts) if it is
at zero, the ship is stationary.

health
------

(sent to all players)
The health of the ship (100 = full health, 0 = destroyed)

thrust_forward
--------------

(sent only to the player who owns the ship)
The current forward thrust setting.

thrust_sideway
--------------

(sent only to the player who owns the ship)
The current sideways thrust setting.

thrust_reverse
--------------

(sent only to the player who owns the ship)
The current reverse thrust setting.

Note
----
A player **knows** his own thrust settings (forward, sideway, reverse) but can only determine
from his sensors the resultant vector of enemy ships (speed and direction). This is why the
data sent back for a players own ships differ in these attributes.






