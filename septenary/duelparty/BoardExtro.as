package septenary.duelparty {
    import flash.utils.Dictionary;

    public class BoardExtro extends Screen {

        protected var _players:Array;
        protected var _local:Player;
        protected var _statsForPlayers:Dictionary;

        public function BoardExtro(local:Player, players:Array) {
            _local = local;
            _players = players;

            for (var i:int = 0; i < players.length; i++) {
                addChild(endStatsBoxForPlayer(players[i]));
            }

            super();
        }

        protected function endStatsBoxForPlayer(player:Player):EndStatsBox {
            var newBox:EndStatsBox = new EndStatsBox();

            if (player == _local) {

            } else {
                
            }

            return newBox;
        }
    }
}