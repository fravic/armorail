package septenary.duelparty {
    import flash.utils.Dictionary;

    public class BoardExtro extends Screen {

        protected var _players:Array;
        protected var _local:Player;
        protected var _statsForPlayers:Dictionary;

        public function BoardExtro(local:Player, players:Array) {
            const boxSpacing:Number = 200;

            _local = local;
            _players = players;

            for (var i:int = 0; i < players.length; i++) {
                var box:EndStatsBox = endStatsBoxForPlayer(players[i]);
                box.y = i * boxSpacing;
                addChild(box);
            }

            GameScreen.getGameScreen().darken();

            super();
        }

        protected function endStatsBoxForPlayer(player:Player):EndStatsBox {
            var newBox:EndStatsBox = new EndStatsBox();

            newBox.lblTotalCoins.text = player.gameStats.totalCoins;
            newBox.lblPlayerKills.text = player.gameStats.playerKills;
            newBox.lblFighterKills.text = player.gameStats.fighterKills;
            newBox.lblCreepKills.text = player.gameStats.creepKills;

            if (player == _local) {
                    
            } else {
                
            }

            return newBox;
        }

        protected function closeExtro():void {
            GameScreen.getGameScreen().unDarken();
        }
    }
}