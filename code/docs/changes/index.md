---
layout: default
title: Changes
---
v-0.011 (2014-03-04)
###[UI]()
    - Added UI test framework
    - Added tests for login
###[Server]()
    - Found a memory leak and fixed it.
v-0.010 (2014-02-28)
###[UI](https://github.com/spacebotwar/space-bot-war-client/commit/78130a572e41f5004fb41f750204528aa315925b)
    - Major tidy up
    - Revamp of build process
    - Support for main game screen
    - Login, Logout now works
    - Start to implement UI tests
###[Server](https://github.com/spacebotwar/space-bot-war/commit/7e2b240e7477afdc9753bd0d4d5c0e0279bccb48)
    - Collision detection, and avoidance for ship movements

v-0.009 (2014-02-21)
###[UI](https://github.com/spacebotwar/space-bot-war/commit/ec3167b54d8b4ce3c0e1af260d862de4eb8f71e0)
    - Register a user
    - Changes to build procedure
    - Start to implement Jasmine tests
###[Server](https://github.com/spacebotwar/space-bot-war/commit/ec3167b54d8b4ce3c0e1af260d862de4eb8f71e0)
    - Email job queue added
    - Forgotten password implemented
    - Login via email code implemented

v-0.008 (2014-02-12)
###[UI](https://github.com/spacebotwar/space-bot-war-client/commit/b08fdb439122dabf941f7a85e8b61551cc1b332a)
    - Client that builds for production now loads images
###[Server](https://github.com/spacebotwar/space-bot-war/commit/05d4c150b12131a62c1ea053b5359509cbdc5b70)
    - not a lot

---
v-0.007 (2014-02-10)
-------------------
###[UI](https://github.com/spacebotwar/space-bot-war-client/commit/9883d91d3e263a92d2ef74a4389ca391460aeba1)
    - Client can now be built as one file for distribution
###[Server](https://github.com/spacebotwar/space-bot-war/commit/197a363702a375299a7c73c50f662f229dcfd8c9)
    - Toned down the logging messages for Web Sockets

---

v-0.006 (2014-02-07)
-------------------
###[UI](https://github.com/spacebotwar/space-bot-war-client/commit/ba6a3b534ecffb87c8ef7d09d1cef5299e6309e0)
    - Changed to allow us to map the documentation to the public site.
###[Server](https://github.com/spacebotwar/space-bot-war/commit/29d6707f39a89a139281ce4d9e41f2e2755f24d5)
    - Changed to allow us to map the documentation to the public site.
    - Blog entry about coffee-scripts

---

v-0.005 (2014-02-06)
-------------------
###[UI](https://github.com/spacebotwar/space-bot-war-client/commit/609730108eec335a7f6f91f906362f03ac402911)
    - Ship movement in UI is now continuous and smooth (mostly)
###[Server](https://github.com/spacebotwar/space-bot-war/commit/96d5dc91eb5d1480c759b4b512c791fec98b0ddc)
    - Minor changes to ship movement calculations

---

v-0.004 (2014-02-05)
-------------------
###[UI](https://github.com/spacebotwar/space-bot-war-client/commit/8148f6ef9f1642c32f4b0187a11d04b659f3ce30)
    - Convert UI to use Coffee-Script
###[Server](https://github.com/spacebotwar/space-bot-war/commit/7c0ca4cb965aaf185235d2e88728b483e7e891e7)
    - Refactor the player WS to make it easier to test
    - Player code is now held in a database

---

v-0.003 (2014-02-02)
-------------------
###[UI](https://github.com/spacebotwar/space-bot-war-client/commit/4dadb5578d09d2ec93907c19e048f677024ca31a)
    - Nothing significant
###[Server](https://github.com/spacebotwar/space-bot-war/commit/03a0672943e973f3bdd8d27cf67633f64b440a74)
    - Refactor of the player WS to make it easier to test
    - Player code is now held in a database (at least for now)

---

(v-0.002 2014-01-21)
-------------------
###[UI](https://github.com/spacebotwar/space-bot-war-client/commit/e02ce167546bedd21977b51d7029c01de839c6df)
    - initial version
###[Server](https://github.com/spacebotwar/space-bot-war/commit/6a3ecd39946e5949c0dc54e538df4e213bc37d36)
    - Match start-state and game-state is updating correctly
    - Player code is now correctly merging static and dynamic data
    - Player code now works in a 'Safe' compartment :)
    - TODO: Must remove thrust_forward etc. from Enemy ships.
    - TODO: Must make speed and direction into attributes (not methods)

---

v-0.001 (2014-01-19)
-------------------
###[UI](https://github.com/spacebotwar/space-bot-war-client/commit/e02ce167546bedd21977b51d7029c01de839c6df)
    - initial version
###[Server](https://github.com/spacebotwar/space-bot-war/commit/a014862d5049b229cc6898b142a2019ebf162418)
    - Fixed all tests
    - Fixed login
    - Got sensible class structure for ships in place
    - client now displays mock-battle again
