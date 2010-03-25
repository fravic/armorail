package septenary.duelparty.boardtiles {
	import septenary.duelparty.*;

	public class PassSwapTile extends BoardTile {
		public function PassSwapTile() {
            _activateOnPass = true;
            _reducesMoveCount = false;
		}

		public override function activate(player:Player, onPass:Boolean=false):void {
			super.activate(player);
            GameEvent.addOneTimeEventListener(player, GameEvent.ACTION_COMPLETE, fightersReversed);
			player.reverseFighters();
		}

        protected function fightersReversed(e:GameEvent):void {
            activateDone(e.target as Player);
        }
	}
}