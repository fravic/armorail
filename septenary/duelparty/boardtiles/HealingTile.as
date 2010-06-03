package septenary.duelparty.boardtiles {
    import septenary.duelparty.*;
    import septenary.duelparty.screens.*;

    public class HealingTile extends BoardTile {

        protected const BASE_HEALTH:int = 3;

        public function HealingTile() {
            super();
        }

        public override function activate(player:Player, onPass:Boolean=false):void {
			super.activate(player);
            GameEvent.addOneTimeEventListener(player, GameEvent.ACTION_COMPLETE, healthRegenDone);
			var healthAdded:int = player.regenHealth(BASE_HEALTH);

            if (!healthAdded) {
                function dialogBoxDismissed(e:GameEvent):void {
                    activateDone(player);
                }
                Singleton.get(GameInterfaceScreen).showDialogBox(DialogScreen.DIALOG_ONLY,
                    {speaker:"Healing Tile", dialog:"This is a healing tile, but you are at maximum health!",
                     player:player}, 
                    dialogBoxDismissed);
            }
		}
        
        protected function healthRegenDone(e:GameEvent=null):void {
            activateDone(e.target as Player);
        }
    }
}