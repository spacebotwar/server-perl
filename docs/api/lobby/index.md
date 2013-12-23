---
layout: default
title: API Documents
api_menu: 1
on_page: api_lobby

---

Lobby
=====

All methods in this section can be carried out by a connection to the **/lobby/** route.

---
Client ID
========

A client ID is used to identify a client to the server. A client ID is provided by the server
and once given it should continue to be used, even if you log out and back in again. This
enables the server to retain your settings.

A session is associated with a Client ID and it  may 'time-out' (after a few hours) but even so, 
you should still keep the same Client ID for subsequent sessions.

A Client may be a different web browser (Internet Explorer, Chrome, Safari etc.) or a
different computer, or a script running. Each of these should be given a different Client ID

In the following API calls, if it specifies a session ID then it is mandatory. If you don't
supply a session ID the call will be rejected.



---
Server : lobby
==============

On making a Web Socket connection, the server will send a **lobby** message indicating the
current status of the room. It may also send an update whenever the room status changes.

{% highlight JSON %}
{
    "code"          : 0,
    "message"       : "Welcome to the Game Lobby",
    "data"          : "lobby",
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
Client : get_session
====================

Get a new session ID. Note you should only do this if you don't already have a session ID.
If you do have one (even if it is timed out) you should reuse it.

{% highlight JSON %}
{
    "msg_id"        : 123,
}
{% endhighlight %}

### msg_id (optional)

An **ID** to identify this message. If used the server reply will contain the same message
ID. This can be useful if you wish to link the server response to the client request.

### RESPONSE

The server will respond with a **Server : get_session** message.




---
Server : get_session
====================

Server response to the **Client : get_session** request

{% highlight JSON %}
{
    "code"          : 0,
    "message"       : "session",
    "session"       : "1234-ABCD-5678-EF01-000000",
    "msg_id"        : 123,
}
{% endhighlight %}

