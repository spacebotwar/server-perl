---
layout: default
title: Changes
---
v-0.006 (2014-02-07)
-------------------
###[UI](https://github.com/spacebotwar/space-bot-war-client)
    - Changed to allow us to map the documentation to the public site.
###[Server]((https://github.com/spacebotwar/space-bot-war)
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
