package septenary.duelparty {

    import flash.utils.setTimeout;

	/* 	NetScreens are Screens that can be controlled by
		the player, the AI, or a networked player.		*/
		
	public class NetScreen extends Screen {
		
		public static const PLAYER_INPUT:int = 0;
		public static const AI_INPUT:int = 1;
		public static const NET_INPUT:int = 2;

        protected var _player:Player;

        public function get inputSource():int {
            return _player ? _player.playerData.inputSource : PLAYER_INPUT;
        }

        public function NetScreen(player:Player=null) {
			_player = player;
		}

        public override function newSiblingScreen(screen:Screen):void {
            Utilities.assert(!(this.inputSource == PLAYER_INPUT && screen is NetScreen &&
                              (screen as NetScreen).inputSource == PLAYER_INPUT), 
                              "Cannot have more than one locally controlled net screen at once!  "+screen.toString()
                              +" ... "+this.toString());
        }
		
		public override function gainedFocus():void {
			execInputFunction(gainedPlayerFocus, gainedAIFocus, gainedNetFocus);
		}
		
		protected function gainedPlayerFocus():void {
            super.gainedFocus();
        }
		protected function gainedAIFocus():void {
            getFocusManager().disablePlayerInput(this);
            getFocusManager().registerFocusables(this);
        }
		protected function gainedNetFocus():void {}
		
		public override function lostFocus():void {
			execInputFunction(lostPlayerFocus, lostAIFocus, lostNetFocus);
		}
		
		protected function lostPlayerFocus():void {
            super.lostFocus();
        }
		protected function lostAIFocus():void {
            getFocusManager().clearFocusablesInsideDisplay(this);
            getFocusManager().enablePlayerInput(this);
        }
		protected function lostNetFocus():void {}
		
		protected function execInputFunction(inpPl:Function, inpAI:Function, inpNet:Function):void {
			switch (this.inputSource) {
				case PLAYER_INPUT:
					inpPl();
					break;
				case AI_INPUT:
					inpAI();
					break;
				case NET_INPUT:
					inpNet();
					break;
			}
		}

        protected function navigateToAndSelectFocusable(f:Focusable):void {
            const stepInterval:Number = 500;
            const selectInterval:Number = 200;

            function selectFocusable():void {
                f.focusAction();
            }
            function navigateStep():void {
                if (getFocusManager().curFocusable == f) {
                    setTimeout(selectFocusable, selectInterval);
                } else {
                    var curF:Focusable = getFocusManager().curFocusable;
                    var angle:Number = Utilities.normalizeRadAngle(Math.atan2(f.y - curF.y, f.x - curF.x));
                    if (angle <= Math.PI/4) {
                        getFocusManager().focusableRight();
                    } else if (Math.PI/4 < angle && angle <= 3 * Math.PI/4) {
                        getFocusManager().focusableDown();
                    } else if (3 * Math.PI/4 < angle && angle <= 5 * Math.PI/4) {
                        getFocusManager().focusableLeft();
                    } else {
                        getFocusManager().focusableUp();
                    }

                    //If AI requires finer control over selection, enable this line instead...
                    //getFocusManager().switchFocusToNearestInDirection(angle);

                    setTimeout(navigateStep, stepInterval);
                }
            }
            navigateStep();
        }

        public override function getFocusManager():FocusManager {
            if (_player == null) return FocusManager.getManager();
            return FocusManager.getManagerByID(_player.playerData.netID);
        }
	}
}