package septenary.duelparty.boardtiles {
    import flash.display.MovieClip;

    import septenary.duelparty.*;
    import com.greensock.TweenLite;

    public class RevolvingDoorTile extends BoardTile {

        protected var _revolveIndex:int = 0;
        protected var _revolveInterval:int = 1;
        protected var _doorDirForward:Boolean = true;
        protected var _nextRevolve:int = 0;
        protected var _doorAnim:MovieClip;

        public function get revolveInterval():int {
            return _revolveInterval;
        }
        public function set revolveInterval(value:int):void {
            _revolveInterval = value;
        }
        public function get revolveIndex():int {
            return _revolveIndex;
        }
        public function set revolveIndex(value:int):void {
            _revolveIndex = value;
        }
        public function get doorDirForward():Boolean {
            return _doorDirForward;
        }
        public function set doorDirForward(value:Boolean):void {
            _doorDirForward = value;
        }

        public static function getParamFields():Array {
            return ["revolveInterval", "revolveIndex", "doorDirForward"];
        }

        public function RevolvingDoorTile() {
            super();
            _activateOnPass = true;
            _reducesMoveCount = false;
        }

        public override function setup():void {
            //Sort tilesOut by angle

            GameBoard.getGameBoard().addEventListener(GameEvent.START_TURN, attemptMoveDoor);
            setupDoorAnim();
        }

        protected function attemptMoveDoor(e:GameEvent):void {
            _nextRevolve--;
            if (_nextRevolve <= 0) {
                _revolveIndex = (_revolveIndex + 1) % (_doorDirForward ? _tilesOut.length : _tilesIn.length);
                _nextRevolve = _revolveInterval;
                repositionDoor();
            }
        }

        public override function activate(player:Player, onPass:Boolean=false):void {
            super.activate(player);
            activateDone(player);
        }

        public override function getTilesInDir(forward:Boolean):Array {
			if (forward) {
                return _doorDirForward ? [getDooredTile()] : _tilesOut;
			} else {
			    return !_doorDirForward ? [getDooredTile()] : _tilesIn;
            }
		}

        public override function arrive(fightable:Fightable):void {
            super.arrive(fightable);

            var dooredTile:BoardTile = getDooredTile();
            var dooredTileRot:Number = Math.atan2(dooredTile.y - y, dooredTile.x - x);
            var playerRot:Number = Math.atan2((fightable as MovieClip).y - y, (fightable as MovieClip).x - x);

            if ((fightable as Player).movement.moveDirForward != _doorDirForward && dooredTileRot != playerRot) {
                repositionDoor(playerRot);
            }
        }

        protected function getDooredTile():BoardTile {
            return _doorDirForward ? _tilesOut[_revolveIndex] : _tilesIn[_revolveIndex];
        }

        protected function setupDoorAnim():void {
            _doorAnim = new RevolvingDoorAnim();
            _doorAnim.x = x;
            _doorAnim.y = y;
            GameBoard.getGameBoard().addChildToBackground(_doorAnim);
            repositionDoor();
        }

        protected function repositionDoor(angle:Number=Number.MIN_VALUE):void {
            const rotSpeed:Number = 150;

            function doorRepositioned():void {
                _doorAnim.dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE));
            }

            var newRot:Number = angle;
            if (angle == Number.MIN_VALUE) {
                var doorTile:BoardTile = getDooredTile();
                newRot = Math.atan2(doorTile.y - y, doorTile.x - x);
            }
            var rotDist:Number = Utilities.angleDiff(_doorAnim.rotation * Math.PI/180, newRot)*180/Math.PI;
            TweenLite.to(_doorAnim, rotDist/rotSpeed, {rotation:newRot*180/Math.PI, onComplete:doorRepositioned});
        }
    }
}