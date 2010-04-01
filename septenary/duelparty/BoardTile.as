package septenary.duelparty {    import com.greensock.TweenLite;    import com.greensock.easing.Bounce;	import flash.display.Sprite;	public class BoardTile extends Sprite {		//Tile properties		protected var _id:int = 0;		protected var _reducesMoveCount:Boolean = true;		protected var _activateOnPass:Boolean = false;		protected var _residents:Array = new Array();		protected var _activeResident:int = 0;		//Adjacent tile selection		protected var _tilesIn:Array = new Array();		protected var _tilesOut:Array = new Array();		public function get id():int {			return _id;		}		public function set id(id:int):void {			_id = id;		}        public function get reducesMoveCount():Boolean {			return _reducesMoveCount;		}		public function get tilesOut():Array {			return _tilesOut;		}		public function get tilesIn():Array {			return _tilesIn;		}		public function get residents():Array {			return _residents;		}        public static function getParamFields():Array {            return [];        }		public function BoardTile() {			super();		}        public function setup():void {}		public function hasResidents():Boolean {			return (Boolean)(_residents.length > 0);		}		public function arrive(fightable:Fightmaster):void {            dispatchEvent(new GameEvent(GameEvent.TILE_RESIDENT_ARRIVED, {fightable:fightable, tile:this}));			_residents.push(fightable);		}		public function depart(fightable:Fightmaster):void {			_residents.splice(_residents.indexOf(fightable), 1);            dispatchEvent(new GameEvent(GameEvent.TILE_RESIDENT_DEPARTED, {fightable:Player, tile:this}));		}		public function activate(player:Player, onPass:Boolean=false):void {            activateAnimation();			_activeResident = _residents.length - 1;		}		protected function activateDone(player:Player):void {			dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE));		}		public function attemptActivateOnPass(player:Player):void {			if (_activateOnPass) {				activate(player, true);			} else {                passAnimation();                dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE));            }		}		public function nextSequentialTile(player:Player):void {			var tilesRef:Array = getTilesInDir(player.movement.moveDirForward);			if (tilesRef.length > 1) {                var dirChoice:DirChoice = new DirChoice(player, this);                GameEvent.addOneTimeEventListener(dirChoice, GameEvent.ACTION_COMPLETE, nextTileSelected);				GameScreen.getGameScreen().pushAndSnapSuperScreen(dirChoice);			} else {				dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, {tile:tilesRef[0]}));			}		}		protected function nextTileSelected(e:GameEvent):void {            var player:Player = e.data.player;            var index:int = e.data.index;			GameScreen.getGameScreen().dismissSuperScreen(e.target as Screen);			var tilesRef:Array = getTilesInDir(player.movement.moveDirForward);            dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, {tile:tilesRef[index]}));		}		public function getTilesInDir(forward:Boolean):Array {			if (forward) {				return _tilesOut;			}			return _tilesIn;		}        protected function undoAnimation(anim:TweenLite):void {            anim.reverse();        }        protected function passAnimation():void {            const animDuration:Number = 0.2;            function reverseAnim():void {                anim.reverse();            }            var anim:TweenLite = TweenLite.to(this, animDuration, {scaleX:1.3, scaleY:1.3, ease:Bounce.easeOut, onComplete:reverseAnim});        }        protected function activateAnimation():void {            passAnimation();        }	}}