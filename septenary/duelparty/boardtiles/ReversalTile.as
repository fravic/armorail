package septenary.duelparty.boardtiles {
	import septenary.duelparty.*;

	public class ReversalTile extends BoardTile {
		public function ReversalTile() {
		}
		
		public override function activate(player:Player, onPass:Boolean=false):void {
			super.activate(player);
			player.reverseMovement();
            activateDone(player);
		}

	}
}