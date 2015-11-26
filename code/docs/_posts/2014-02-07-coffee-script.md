---
layout: post
title: Coffee Script
categories:
- blog
---

Vasari has just finished converting all the code for the User Interface from
Javascript to Coffee-Script and although I have a few reservations it looks like
a good long term move. Code is clearer, less verbose and with less boilerplate.

My only concern is that it is a bit more painful to debug since it is not possible
(yet) to debug directly in coffee-script, you have to debug the compiled Javascript,
that puts an extra layer in the way of understanding. Hopefully this will improve
as browsers are updated and are able to debug the coffee-script directly.

Having seen Coffee-Script in action, it occurred to me that it might make a good
language to use for the scripts people write to control their ships. Of course it
would have the same issues as Javascript, since it would be running on the server
it might give people access to the file system and allow them to do all manner of
things.

Looking into it further, Coffee-Script is a lexical parser than converts the
input (Coffee-Script) into Javascript. Interestingly, Coffee-Script is itself
written in Coffee-Script so it brings a whole new meaning to the term 'chicken
or egg'!

The parser is built upon the Jison API which is in turn based on the API for Bison.
[see github/zaach/jison](https://github.com/zaach/jison). From the readme. 'Jison takes a JSON encoded
grammer ... and outputs a Javascript file capable of parsing the language described
by that grammer'. What does that mean exactly?

The grammer defines the language in a human readable form called Backus-Naur Form
(or BNF). This defines the language in a set of rules and the input to Jison (or
Bison) is essentially machine readable BNF.

So the idea is, we will create a language specifically designed to control the
ships in SpaceBotWar. This will give us control over what the language can do (
and most importantly what it is **not** allowed to do) and will even allow us 
to create language specific expressions for calculations such as the direction
to point missiles.

Like Coffee-Script, the compiler will be written in Coffee-Script and it will
produce Javascript output. This Javascript will run on the NodeJS servers.

We are probably a while off being able to write this, there are a lot more
basic functions that need to be written first, and we already have a Perl based
language we can use to control ships. However I think that a Coffee-Script like
language will have a greater appeal.

If you are interested in collaborating on this project, we are interested in
talking to you! Please email me at sbw@iain-docherty.com

