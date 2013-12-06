space-bot-war
=============

Space age version of Robot War (see http://en.wikipedia.org/wiki/Robotwar ) where fleets of space ships
compete with each other to see who wins. Fleets are fully automated, both for offence and defence, using
computer programs.

The computer programs are written by the game users, using a variety of languages. Programs are expected
to be cloned, copied, modified, updated in a continual effort to obtain the most efficient program.

Every week, a players top fleet will be entered into a tournament and tested against other fleets to see
who has the best program. This will determine the ranking of players in the game.

The game is expected to evolve over time, with new features being added on a continual basis. The releases
are likely to be as follows.

Version 1.0
===========

Users can create accounts and will have the ability to program a fleet of six ships. The programming language
initially will be based on Perl and users will be able to create/test/run their code directly on the server.

The game will include a web site, based on HTML5 and Web Sockets, which will allow the user to follow the
progress of a battle between two fleets in real time (or play back previous battles). Ship movement, missile
firing, explosions, will all be rendered in real time.

Users may 'test' the performance of their fleet against the fleet of any other user and see the result of the
battle take place in real time. They will have no control over their ship movements, it will all take place
automatically based on their program.

A tournament will be run each week, competing each fleet/program against others in the same league in a 'best
of three' set of matches. Each match will last five minutes during which the programs will determine the speed
direction and missile firing for each of their ships. Each program will be informed of the latest known speed
and direction of all other ships every 500 ms and will need to use this information to determine their actions
over the next 500ms.


