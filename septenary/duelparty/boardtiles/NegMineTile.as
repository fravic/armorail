package septenary.duelparty.boardtiles {
	import septenary.duelparty.*;

	public class NegMineTile extends BoardTile {

        protected static const BASE_COIN:int = 25;

		public function MineTile() {
		}

		public override function activate(player:Player, onPass:Boolean=false):void {
			super.activate(player);
            GameEvent.addOneTimeEventListener(player, GameEvent.PLAYER_COINS_MODIFIED, coinsTaken);
			player.takeCoins(BASE_COIN);
		}

        protected function coinsTaken(e:GameEvent):void {
			activateDone(e.target as Player);
        }
	}
}