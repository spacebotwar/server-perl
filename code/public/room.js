(function($){
    $.fn.extend({
        room: function(o) {
            var self    = this;

            self.playerId = null;
            self.players = {};
            var defaults = {};
            var options = $.extend(defaults, o);

            self.displayMessage = function (msg) {
                $(this).html(msg);
            };

            self.addPlayer = function(player) {
                self.players[player.id] = player;
            };

            self.getPlayer = function(id) {
                if (id) {
                    return self.players[id];
                }
                return self.players[self.playerId];
            };

            self.init = function() {
                //console.log('init');
            };

            function Player(options) {
                var player = this;

                player.id = options.id;
            }

            return self.each(function() {
                var o = options;

                self.displayMessage('Connecting to...'+o.url);

                // Connect to WebSocket
                var ws = new WebSocket(o.url);

                ws.onerror = function(e) {
                    self.displayMessage("Error: " + e);
                };

                ws.onopen = function() {
                    self.displayMessage('Connected to...'+o.url);
                    ws.send($.toJSON({"type" : "room", "content" : { "number" : 5 } } ))
                    self.init();

                };

                ws.onmessage = function(e) {
                    var data = $.evalJSON(e.data);
                    var type = data.type;
                    var content = data.content;
                    //console.log('Message received');
//                    $('#debug').html(e.data);

                    if (type == 'new_client') {
                        //console.log('New player connected');
                        var player = new Player({
                            "id" : content.id
                        });
                        self.addPlayer(player);
                    }
                    else if (type == 'old_client') {
                        //console.log('Player disconnected');
                        delete self.players[content.id];
                    }
                    else if (type == 'rooms') {
                        $('#top').html("room content = ["+content[5]+"]");
                    }
                    else if (type == 'room_data') {
                        var c_arena = content.arena;
                        var date = new Date();
                        init_t = date.getTime();

                        var c_ships = c_arena.ships;
                        // first time in.
                        if ('undefined' === typeof arena.ships) {
                            arena.ships = new Array();
                        }
                        var ships = new Array();
                        for (var i=0; i<c_ships.length; i++) {
                            var c_ship = c_ships[i];

                            if ('undefined' === typeof arena.ships[c_ship.id]) {
                                arena.ships[c_ship.id] = new Ship({
                                    x           : c_ship.x,
                                    prev_x      : c_ship.x,
                                    y           : c_ship.y,
                                    prev_y      : c_ship.y,
                                    direction   : c_ship.direction,
                                    speed       : 0,
                                    rotation    : c_ship.rotation,
                                    orientation : c_ship.orientation,
                                    prev_orientation : c_ship.orientation,
                                    status      : c_ship.status,
                                    health      : c_ship.health,
                                    init_t      : init_t,
                                    prev_t      : init_t
                                });
                            }
                            else {
                                var ship = arena.ships[c_ship.id];
                                ship.prev_x     = ship.x;
                                ship.prev_y     = ship.y;
                                ship.prev_t     = ship.init_t;
                                ship.prev_orientation = ship.orientation;
                                ship.x          = c_ship.x;
                                ship.y          = c_ship.y;
                                ship.direction  = c_ship.direction;
                                ship.speed      = c_ship.speed;
                                ship.rotation   = c_ship.rotation;
                                ship.orientation= c_ship.orientation;
                                ship.status     = c_ship.status;
                                ship.health     = c_ship.health;
                                ship.init_t     = init_t;
                            }
                        }
                    }
                };

                ws.onclose = function() {
                    $('#top').html('');
                    self.displayMessage('Disconnected. <a href="/">Reconnect</a>');
                };


            });
        }
    });
})(jQuery);
