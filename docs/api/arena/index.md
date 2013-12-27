---
layout: default
title: API Documents
api_menu: 1
on_page: api_arena

---

Arena Lobby
===========

All methods in this section can be carried out by a connection to the **/arena/lobby** route.

The Arena lobby will give you the names and routes to other rooms which are currently (or
about to) be hosting a competition between two fleets of ships.

Note, rooms which are available will depend upon your login status. See the Start Lobby for
details on how to login.

---
Server : lobby
==============

On making a Web Socket connection, the server will send a **lobby** message indicating the
current status of the room. It may also send an update whenever the room status changes.

{% highlight JSON %}
{
    "code"          : 0,
    "message"       : "Welcome to the Arena Lobby",
    "data"          : "arena",
}
{% endhighlight %}

### code

The numeric code representing the status of the **lobby** where **0** represents success
and any other value indicates a fault.

### message

A human readable message, for example a message to the effect that the server is off-line.

## data

Supplimentary data, for example the time at which the server is due back on line.





---
Client : arenas
===============

Get the list of all the current Arena rooms

{% highlight JSON %}
{  
    "msg_id"        : 123,
    "client_code"   : "1660686c-8b5d-3b7c-825d-1d828db8f9ca-2f928",
}
{% endhighlight %}

### msg_id (optional)

An **ID** to identify this message. If used the server reply will contain the same message
ID. This can be useful if you wish to link the server response to the client request.

### client_code (required)

Your client code.

### RESPONSE

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
        "route"         : "/ws/arena/gold",
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

###arenas

This is an array of all arenas available to you. Note, if you are not logged
in then some rooms may not be available to you.

####route

The Route to the arena. In order to watch a match you need to make a connection
to that route. To leave a match you break the connection.

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
to the route. A list of the current matches can be found in the **lobby**.

When you make a connection to the arena you are automatically registered to
receive updates on the match progress. This is through a **Server : areas_state**
message (see below).

In addition there are a number of requests you can make to the room. for all
of these you should use the route to the room, e.g. **arena/gold**




---
Client : arena_status
=====================

Request the current status of the room you have just joined.

{% highlight JSON %}
{
    "client_code"   : "1660686c-8b5d-3b7c-825d-1d828db8f9ca-2f928",
}
{% endhighlight %}

###msg_id (not required)

Do not issue a **msg_id** with this request, since the server will send multiple
responses the msg_id is not honoured.

###RESPONSE

The server will respond with a **Server : arena_status** message, immediately
with the current room status, then in the future if any changes take
place in the room.




---
Server : arena_status
=====================

The server will send this message, either on request from a **Client : arena_status**
message, or periodically if there is a change to the arena status (e.g.
a new match starts).

{% highlight JSON %}
{
    "route"         : "/ws/arena/gold",
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
Server : match_status
=====================

The server will send this message periodically (every 500ms during a match) and it
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

###orientation, rotation

Missiles are always orientatied in the direction of their movement and they don't rotate.

###status

The status can be used to distinguish different phases of the missile. e.g.
**launch**, **running**, **explosion**

###type

The type of the missile, may be used to indicate different missiles and images for them,
e.g. **laser**, **rocket**, etc.






