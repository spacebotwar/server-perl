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
over the next 500ms. Each of the matches in tournament can either be watched in real time (by any number of
observers) or played back by anyone at a later time.

Version 1 will enable the basic principles to be tested, HTML5, Web Sockets, running users own programs (in a
'sandbox' mode).

Version 2.0
===========

In version 2, each user will be able to create a base of operations, manually create buildings to support 
their operations (ship yards, mines, storage) etc. They will be able to send their fleets out to attack
other players ships (piracy) or bases (war) or Artifical Intelligence players (AI) in order to obtain 
resources to help them progress in the game.

In this the game is similar to other games of the same genre. The difference however is that the fleets 
will be able to be pre-programmed so that players can experiment with different tactics and these tactics
will be carried out automatically.

The game API will be 'open' so that all aspects of the game can be automated if the player so wishes. We
will add the ability for users without the skill to run external programs to run their scripts within
the servers 'sandbox'.

Game Scenario
=============

The art and graphics will be based on Steam Punk. i.e. how Jules Verne might have imagined space travel.

The scenario is a space based economy where space trael is dangerous (due to aliens, piracy etc.), so they are
controlled by computers (Babbage Engines?) and called SpaceBots.

The people who program these SpaceBots are held in high esteem, rather like rock stars or reality TV
guests are today!

The economy is based around the availability of computing power (BU, or Babbage Units) which give each
owner the ability to perform a certain number of computations per day. Every program you run (ship attack,
ship defence, building, exploring) will consume these units. Your progress in the game will be determined
by how quickly you can accumulate these BU (by piracy, war, discovery etc.) and by how efficiently you
can devise your programs.



