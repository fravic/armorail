package septenary.duelparty.boardtiles {
	import septenary.duelparty.*;

	public class TeleportationTile extends BoardTile {
		public function TeleportationTile() {
		    _reducesMoveCount = false;
			_activateOnPass = true;
        }

		public override function activate(player:Player, onPass:Boolean=false):void {
			super.activate(player);

            var tiles:Array = getTilesInDir(player.movement.moveDirForward);
            var randTile:BoardTile = tiles[Math.floor(Math.random() * tiles.length)];
            GameEvent.addOneTimeEventListener(player, GameEvent.ACTION_COMPLETE, playerTeleported);
            player.teleportToTile(randTile);
		}

        protected function playerTeleported(e:GameEvent):void {
            activateDone(e.target as Player);
        }

	}
}