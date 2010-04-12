package septenary.duelparty {	import flash.display.Sprite;    import flash.geom.Point;	public class Screen extends Focusable {        private var _focusInitialized:Boolean = false;        private var _superScreenQueue:Array = new Array();		protected var _superScreens:Array = new Array();        protected var _alwaysOnTop:Boolean = false;        public function alwaysOnTop():Boolean {            return _alwaysOnTop;        }				public function Screen(screenData:Object=null) {		}        public function showDialogBox(type:String, data:Object, addCallback:Function=null):void {            var dB:DialogBox = new DialogBox(type, data);            pushSuperScreen(dB);            GameEvent.addOneTimeEventListener(dB, GameEvent.ACTION_COMPLETE, dismissDialogBox);            if (addCallback != null) {                GameEvent.addOneTimeEventListener(dB, GameEvent.ACTION_COMPLETE, addCallback);            }        }        public function dismissDialogBox(e:GameEvent):void {            dismissSuperScreen(e.target as DialogBox);        }				public function pushSuperScreen(screen:Screen):void {            _superScreens.push(screen);			addChild(screen);			            for (var i:int = 0; i < _superScreens.length; i++) {				if (_superScreens[i] == screen) continue;                _superScreens[i].newSiblingScreen(screen);                if (_superScreens[i].alwaysOnTop) {                    swapChildren(screen, _superScreens[i]);                }            }            //Giving a super screen before this screen itself has focus will cause errors...            if (!_focusInitialized) {                _superScreenQueue.push(screen);            } else {                focusSuperScreen(screen);                }		}        protected function focusSuperScreen(screen:Screen):void {            if (this.hasFocus) this.lostFocus();            screen.gainedFocus();        }        public function dismissSuperScreen(screen:Screen):void {            _superScreens.splice(_superScreens.indexOf(screen), 1);            screen.lostFocus();			//Attempt to set focus on next superscreen controlled by the same manager			var focusSet:Boolean = false;			for (var i:int = _superScreens.length - 1; i >= 0; i--) {						var nextScreen:Screen = _superScreens[i];				if (!nextScreen.hasFocus && nextScreen.getFocusManager() == screen.getFocusManager()) {					nextScreen.gainedFocus();					focusSet = true;					break;				}			}						//If no other superscreen gained focus, attempt to set focus on self...            if (!focusSet && getFocusManager() == screen.getFocusManager()) {                this.gainedFocus();            }			            removeChild(screen);        }				public function dismissAllSuperScreens():void {            while (_superScreens.length > 0) {                dismissSuperScreen(_superScreens[0]);            }		}        public function newSiblingScreen(screen:Screen):void {}        public function addGUIAnimation(anim:Sprite, data:Object):void {            addChild(anim);            }        public function positionForGUIAnimation(position:Point, data:Object):Point {            return position;         }		public function update():void {            for (var i:int = 0; i < _superScreens.length; i++) {                if (_superScreens[i]) {                    _superScreens[i].update();                }            }		}        protected function centerScreen():void {            x = DuelParty.stageWidth/2 - width/2;            y = DuelParty.stageHeight/2 - height/2;        }        private function processSuperScreenQueue():void {            while(_superScreenQueue.length > 0) {                var screen:Screen = _superScreenQueue.splice(0, 1)[0] as Screen;                focusSuperScreen(screen);            }        }				public override function gainedFocus():void {            super.gainedFocus();			getFocusManager().registerFocusables(this);            this.focusRect = false;            DuelParty.stage.focus = this;            _focusInitialized = true;            processSuperScreenQueue();		}        		public override function lostFocus():void {            getFocusManager().clearFocusablesInsideDisplay(this);            DuelParty.stage.focus = null;		    super.lostFocus();        }        public function getFocusManager():FocusManager {            return FocusManager.getManager();        }	}}