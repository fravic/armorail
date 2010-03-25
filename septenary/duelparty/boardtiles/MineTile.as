package septenary.duelparty.boardtiles {
	import septenary.duelparty.*;

	public class MineTile extends BoardTile {

        protected var _coinGive:int = 50;

        public function get coinGive():int {
            return _coinGive;
        }
        public function set coinGive(value:int):void {
            _coinGive = value;
        }

        public static function getParamFields():Array {
            return ["coinGive"];
        }

        public function MineTile() {
		}
		
		public override function activate(player:Player, onPass:Boolean=false):void {
			super.activate(player);                 
            GameEvent.addOneTimeEventListener(player, GameEvent.PLAYER_COINS_MODIFIED, coinsGiven);
			player.giveCoins(_coinGive);
		}

        protected function coinsGiven(e:GameEvent):void {
            activateDone(e.target as Player);
        }
	}                                                
}