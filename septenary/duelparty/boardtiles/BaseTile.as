package septenary.duelparty.boardtiles {
	import septenary.duelparty.*;

	public class BaseTile extends BoardTile {

        protected var _startPlayer:int = -1;

        public function get startPlayer():int {
            return _startPlayer;
        }
        public function set startPlayer(value:int):void {
            _startPlayer = value;
        }

        public static function getParamFields():Array {
            return ["startPlayer"];
        }

		public function BaseTile() {
			_reducesMoveCount = false;
			_activateOnPass = true;
		}
		
		public override function activate(player:Player, onPass:Boolean=false):void {
			super.activate(player);
            GameEvent.addOneTimeEventListener(player, GameEvent.ACTION_COMPLETE, doneShopSelection);
            player.shopForFighter();
		}
		
		protected function doneShopSelection(e:GameEvent):void {
			activateDone(e.data as Player);
		}
	}
}