package septenary.duelparty.screens {
    import septenary.duelparty.*;

    import flash.utils.Dictionary;
    import flash.events.MouseEvent;

    public class BoardExtroScreen extends Screen {

        protected var _players:Array;
        protected var _statsForPlayers:Dictionary = new Dictionary();

        protected var _resultsVisible:Boolean = true;

        public function BoardExtroScreen(players:Array, victory:Boolean) {
            super();

            const boxTopY:Number = 200;
            const boxSpacing:Number = 200;

            _alwaysOnTop = true;

            _players = players;

            var placements:Array = Singleton.get(GameInterfaceScreen).placementsForPlayers(_players);

            for (var i:int = 0; i < players.length; i++) {
                var box:EndStatsBox = endStatsBoxForPlayer(players[i], placements[i]);
                box.x = DuelParty.stageWidth/2;
                box.y = i * boxSpacing + boxTopY;
                addChild(box);
                _statsForPlayers[players[i]] = box;
            }

            Singleton.get(GameScreen).darken();
            Singleton.get(GameInterfaceScreen).hidePlayerInterfaces();

            btnHideResults.lbl.text = "Hide Results";
            btnLobby.lbl.text = "Exit - Lobby";
        }

        protected function endStatsBoxForPlayer(player:Player, placement:int):EndStatsBox {
            var newBox:EndStatsBox = new EndStatsBox();

            newBox.lblPlayerName.text = player.playerData.name;
            newBox.lblTotalCoins.text = player.gameStats.totalCoins;
            newBox.lblPlayerKills.text = player.gameStats.playerKills;
            newBox.lblFighterKills.text = player.gameStats.fighterKills;
            newBox.lblCreepKills.text = player.gameStats.creepKills;
            newBox.placement.gotoAndStop(placement);

            if (Singleton.get(NetworkManager).isLocalPlayerNetID(player.playerData.netID)) {
                    
            } else {
                
            }

            return newBox;
        }

        protected function buttonAction(e:MouseEvent):void {
            if (e.target == btnHideResults) {
                toggleExtroVisibility();
            } else if (e.target == btnLobby) {
                dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE));
            }
        }

        protected function toggleExtroVisibility():void {
            if (_resultsVisible) {
                Singleton.get(GameScreen).unDarken();
                Singleton.get(GameInterfaceScreen).showPlayerInterfaces();
                btnHideResults.lbl.text = "Show Results";
            } else {
                Singleton.get(GameScreen).darken();
                Singleton.get(GameInterfaceScreen).hidePlayerInterfaces();
                btnHideResults.lbl.text = "Hide Results";
            }

            _resultsVisible = !_resultsVisible;
            for each (var box:EndStatsBox in _statsForPlayers) {
                box.visible = _resultsVisible;
            }
        }

        public override function gainedFocus():void {
            super.gainedFocus();
            getFocusManager().addGeneralFocusableListener(this, buttonAction);
        }

		public override function lostFocus():void {
            super.lostFocus();
            getFocusManager().removeGeneralFocusableListener(this, buttonAction);
		}
    }
}