---
layout: default
title: API Documents
api_menu: 1
on_page: api_battle

---

Battle
======

All methods in this section can be carried out by a connection to one of the battle
servers given in the **Arena** API. e.g. **ws://spacebotwar.com/ws/battle/scott**

Each method appends to the route **/** e.g. 'battle_status' method would be on route **/battle_status**


---
Server : connect
================

On making a Web Socket connection, the server will send a **connect** message indicating the
current status of the server. It may also send an update whenever the server status changes.

{% highlight JSON %}
{
    "code"          : 0,
    "message"       : "Welcome to the Battle!",
    "data"          : "battle",
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
Client : battle_status
=====================

Request the current status of the battle you have just joined.

{% highlight JSON %}
{
    "client_code"   : "1660686c-8b5d-3b7c-825d-1d828db8f9ca-2f928",
}
{% endhighlight %}

msg_id (not required)
--------------------

Do not issue a **msg_id** with this request, since the server will send multiple
responses the msg_id is not honoured.

RESPONSE
--------

The server will respond with a **Server : battle_status** message, immediately
with the current battle status, then in the future if any changes take
place in the room.




---
Server : battle_status
=====================

The server will send this message, either on request from a **Client : battle_status**
message, or periodically if there is a change to the arena status (e.g.
a new battle starts).

{% highlight JSON %}
{
    "spectators"    : 23,
    "start_time"    : -30,
    "status"        : "running",
    "competitors"       : [{
        "name"          : "Scaredy Pants",
        "rank"          : 37,
        "programmer"    : "Dr Death",
        "health"        : "34"
    },{
        "name"          : "Hunter",
        "rank"          : 42,
        "programmer"    : "Blotto",
        "health"        : "12"
    }],
}
{% endhighlight %}




---
Server : battle_tick
===================

The server will send this message periodically (every 500ms during a battle) and it
is intended to supply the current status, position, direction of all ships and
missiles. The client can use this information to show a real-time enactment of the
battle taking place. Since the data is refreshed at intervals of 500ms the client
should interpolate from one 500ms **tick** to the next. It is acceptable for the
client to lag by 500ms in order to allow interpolation to take place.

{% highlight JSON %}
{
    "game_time"     : 43.5,
    "ships"         : [{
        "competitor"    : 0,
        "ship_id"       : 0,
        "x"             : 2303,
        "y"             : 1200,
        "direction"     : 1.235,
        "orientation"   : 1.205,
        "speed"         : 24,
        "rotation"      : -0.3,
        "status"        : "ok",
        "health"        : 85.3
    },{
        ...
    },{
        ...
    }
    ],
    "missiles"      : [{
        "competitor"    : 0,
        "missile_id"    : 0,
        "x"             : 189,
        "y"             : 1399,
        "direction"     : -1.34,
        "speed"         : 54,
        "status"        : "explode",
        "type"          : "laser",
    },{
        ...
    }
    ]
}
{% endhighlight %}

game_time
---------

The time from when the game started. A game starts at **game_time** zero so
if it is negative, it means the game is being set up and has not yet started.

ships
-----

An array of all ships in the game, for all competitors. Typically there will
be 12 ships, six from each competitor.

###competitor

This is the index into the competitors described in the **Server : status** message.
and will have the value zero or one.

###ship_id

A ship identifier, there being 12 ships these will be numbered zero through to eleven.

###x and y

The X and Y co-ordinate of the ship at this point in time.

###direction

The direction the ship is moving, in radians, note this may be negative or positive.

###speed

The speed that the ship is moving (in pixels per second)

###orientation

The direction the ship is pointing. Generally this will be the same as the direction
of movement, unless the ship has sideways or reverse thrust.

###rotation

The rate at which the orientation of the ship is changing, in radians per second. 
Note, a positive value means it is rotating anti-clockwise, a negative value indicates
clockwise rotation.

###status

The status of the ship, one of **ok**, **damaged**, or **dead**

###health

The health of the ship as a percentage. Ships start at 100% health and as they are
damaged they lose health. At zero percent, the ship status will change (to "dead") and
the ship will be removed from the arena.

missiles
--------

Missiles have similar attributes to ships,

###competitor

As above.

###missile_id

All missiles are identified by a unique ID.

###x and y

As above.

###direction and speed

As above.

###status

The status can be used to distinguish different phases of the missile. e.g.
**launch**, **running**, **explosion**

###type

The type of the missile, may be used to indicate different missiles and images for them,
e.g. **laser**, **rocket**, etc.

