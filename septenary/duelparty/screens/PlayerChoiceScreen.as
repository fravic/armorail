package septenary.duelparty.screens {
    import septenary.duelparty.*;

    import flash.utils.Dictionary;
    import flash.events.MouseEvent;
    import flash.display.DisplayObject;

    public class PlayerChoiceScreen extends NetScreen {

        protected var _focusableSet:Array = new Array();
        protected var _playersForFocusables:Dictionary = new Dictionary();

        public function PlayerChoiceScreen(player:Player, playerSet:Array, message:String) {
            super(player);

            for (var i:int = 0; i < playerSet.length; i++) {
                var focusable:Focusable = new Focusable();
                _focusableSet.push(focusable);
                _playersForFocusables[focusable] = playerSet[i];
                addChild(focusable);
            }

            lblSelect.text = message;
            lblSelect.x = DuelParty.stageWidth/2 - lblSelect.width/2;
            lblSelect.y = DuelParty.stageHeight - lblSelect.height;
        }

        protected function highlightPlayerForFocusable(e:MouseEvent):void {
            var player:DisplayObject = _playersForFocusables[e.target];
            selectArrow.x = player.x + Singleton.get(GameBoard).x;
            selectArrow.y = player.y + Singleton.get(GameBoard).y;
            Graphics.highlightObject(player);

            var inter:DisplayObject = Singleton.get(GameInterfaceScreen).interfaceForPlayer[player];
            if (inter) {
                Graphics.highlightObject(inter);
            }
        }

        protected function unHighlightPlayerForFocusable(e:MouseEvent):void {
            var player:DisplayObject = _playersForFocusables[e.target];
            Graphics.unHighlightObject(player);
            var inter:DisplayObject = Singleton.get(GameInterfaceScreen).interfaceForPlayer[player];
            if (inter) {
                Graphics.unHighlightObject(inter);
            }
        }

        protected function playerFocusableSelected(e:MouseEvent):void {
            unHighlightPlayerForFocusable(e);
            dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, {player:_playersForFocusables[e.target]}));
        }

        protected override function gainedPlayerFocus():void {
            super.gainedPlayerFocus();
            for (var i:int = 0; i < _focusableSet.length; i++) {
                getFocusManager()
                        .addFocusableListeners(_focusableSet[i], playerFocusableSelected);
                _focusableSet[i].addEventListener(MouseEvent.MOUSE_OVER, highlightPlayerForFocusable, false, 0, true);
                _focusableSet[i].addEventListener(MouseEvent.MOUSE_OUT, unHighlightPlayerForFocusable, false, 0, true);
            }
            getFocusManager().switchFocus(_focusableSet[0]);
		}

		protected override function lostPlayerFocus():void {
            super.lostPlayerFocus();
            for (var i:int = 0; i < _focusableSet.length; i++) {
                getFocusManager()
                        .removeFocusableListeners(_focusableSet[i], playerFocusableSelected);
                _focusableSet[i].removeEventListener(MouseEvent.MOUSE_OVER, highlightPlayerForFocusable);
                _focusableSet[i].removeEventListener(MouseEvent.MOUSE_OUT, unHighlightPlayerForFocusable);
            }
		}
    }
}