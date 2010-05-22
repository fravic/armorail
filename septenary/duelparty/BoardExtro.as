package septenary.duelparty {
    import flash.utils.Dictionary;

    public class BoardExtro extends Screen {

        protected var _players:Array;
        protected var _local:Player;
        protected var _statsForPlayers:Dictionary;

        public function BoardExtro(local:Player, players:Array, victory:Boolean) {
            const boxTopY:Number = 200;
            const boxSpacing:Number = 200;

            _alwaysOnTop = true;

            _local = local;
            _players = players;

            var placements:Array = Singleton.get(GameInterface).placementsForPlayers(_players);

            for (var i:int = 0; i < players.length; i++) {
                var box:EndStatsBox = endStatsBoxForPlayer(players[i], placements[i]);
                box.x = DuelParty.stageWidth/2;
                box.y = i * boxSpacing + boxTopY;
                addChild(box);
            }

            Singleton.get(GameScreen).darken();
            Singleton.get(GameInterface).hidePlayerInterfaces();

            super();
        }

        protected function endStatsBoxForPlayer(player:Player, placement:int):EndStatsBox {
            var newBox:EndStatsBox = new EndStatsBox();

            newBox.lblPlayerName.text = player.playerData.name;
            newBox.lblTotalCoins.text = player.gameStats.totalCoins;
            newBox.lblPlayerKills.text = player.gameStats.playerKills;
            newBox.lblFighterKills.text = player.gameStats.fighterKills;
            newBox.lblCreepKills.text = player.gameStats.creepKills;
            newBox.placement.gotoAndStop(placement);

            if (player == _local) {
                    
            } else {
                
            }

            return newBox;
        }

        protected function closeExtro():void {
            Singleton.get(GameScreen).unDarken();
            Singleton.get(GameInterface).showPlayerInterfaces();
        }
    }
}