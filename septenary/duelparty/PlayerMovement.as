package septenary.duelparty {    import com.greensock.TweenLite;    import flash.display.Sprite;    import flash.geom.Point;    import flash.events.EventDispatcher;    public class PlayerMovement extends FightableMovement {        protected var _prevTile:BoardTile;        protected var _movesLeftCounter:MovesLeftCounter;        protected var _moveCount:int = 0;        protected var _moveDirForward:Boolean = true;        public function get moveDirForward():Boolean {			return _moveDirForward;		}        public function get moveCount():int {            return _moveCount;        }        public function set moveCount(value:int):void {            hideMovesLeftCounter();            _moveCount = value;        }        public function PlayerMovement(player:Player):void {            super(player);        }        public override function kill():void {            super.kill();            _moveDirForward = true;        }        public function reverseMovement():void {            //Switches movement direction, and rotates everyone to face it			_moveDirForward = !_moveDirForward;            _manager.reverseDirection();		}		public function move(moveCount:int):void {			_moveCount = moveCount;			progress();		}		public function progress():void {            showMovesLeftCounter();            GameEvent.addOneTimeEventListener(_currentTile, GameEvent.ACTION_COMPLETE, nextTileSelected);            dispatchEvent(new GameEvent(GameEvent.MOVEMENT_REQUEST_NEXT_TILE, {tile:_currentTile}));		}		protected function nextTileSelected(e:GameEvent):void {            var nextTile:BoardTile = e.data.tile;			_prevTile = _currentTile;			_currentTile = nextTile;			prepareForMovement();		}		protected function prepareForMovement():void {			//Back up train and move to new path if necessary (if next tile is not default)			if (_currentTile != _prevTile.getTilesInDir(_moveDirForward)[0]) {                _manager.moveTo(new Point(_currentTile.x, _currentTile.y), preparedToMove);			} else {				preparedToMove();			}		}		protected function preparedToMove():void {            const advanceFurther:Number = 20;			//Check for battle!			if (_currentTile.hasResidents()) {                hideMovesLeftCounter();                //Move partially along the path			    var rot:Number = Math.atan2(_currentTile.y - _prevTile.y, _currentTile.x - _prevTile.x);			    var pt:Point = new Point(_prevTile.x + (_tugDistBehind + advanceFurther) * Math.cos(rot),                                         _prevTile.y + (_tugDistBehind + advanceFurther) * Math.sin(rot));                _manager.moveTo(pt);                dispatchEvent(new GameEvent(GameEvent.MOVEMENT_ENEMY_ENCOUNTERED, {tile:_currentTile}));			} else {				progressMovementStart();			}		}		public function progressMovementStart(e:GameEvent=null):void {			super.arrivedAtNewTile(_currentTile);            showMovesLeftCounter();            _manager.pushPulleyFromFront();            _manager.moveTo(new Point(_currentTile.x, _currentTile.y), progressMovementAdvance);		}        protected function progressMovementAdvance(e:GameEvent=null):void {            const advanceFurther:Number = 7;            if (_carAhead != null) {    //Only if foreguard exists                _manager.pushPulleyFromFront();                _manager.moveTo(positionForForeGuard(advanceFurther), progressMovementEnd);            } else {                progressMovementEnd();            }        }		protected function progressMovementEnd():void {            super.departedCurrentTile(_prevTile);            if (_currentTile.reducesMoveCount) {				_moveCount--;                hideMovesLeftCounter();			}            GameEvent.addOneTimeEventListener(_currentTile, GameEvent.ACTION_COMPLETE, tileActivationComplete);            dispatchEvent(new GameEvent(GameEvent.MOVEMENT_TILE_ACTIVATION,                                       {player:_display, tile:_currentTile, onPass:(_moveCount > 0)}));		}		public function tileActivationComplete(e:GameEvent):void {			if (_moveCount > 0) {				progress();			} else {                dispatchEvent(new GameEvent(GameEvent.MOVEMENT_ENDED));			}		}        public override function update():void {            super.update();            if (_movesLeftCounter) {                var pos:Point = positionForMovesLeftCounter();                _movesLeftCounter.x = pos.x;                _movesLeftCounter.y = pos.y;            }        }        protected function showMovesLeftCounter():void {            if (!_movesLeftCounter) {                _movesLeftCounter = GUIAnimationFactory.createAndAddAnimation(GUIAnimationFactory.MOVES_LEFT_COUNTER,                                       positionForMovesLeftCounter(), {movesLeft:_moveCount}, null) as MovesLeftCounter;            }        }        protected function hideMovesLeftCounter():void {            if (!_movesLeftCounter) return;            Singleton.get(GameBoard).removeChildFromOverlay(_movesLeftCounter);            _movesLeftCounter = null;        }        protected function positionForMovesLeftCounter():Point {            const yOffset:Number = 40;            return new Point(_display.x, _display.y - yOffset);        }        public function positionForForeGuard(advanceFurther:Number=0):Point {			var defNextTile:BoardTile = _currentTile.getTilesInDir(_moveDirForward)[0];			var rot:Number = Math.atan2(defNextTile.y - _currentTile.y, defNextTile.x - _currentTile.x);			return new Point(_currentTile.x + (_tugDistBehind + advanceFurther) * Math.cos(rot),                             _currentTile.y + (_tugDistBehind + advanceFurther) * Math.sin(rot));		}		public function positionForRearGuard():Point {			var rot:Number = 0;            var prevTile:BoardTile = _prevTile;			if (!prevTile) {				prevTile = _currentTile.getTilesInDir(!_moveDirForward)[0];			}			if (!prevTile) {				prevTile = _currentTile.getTilesInDir(_moveDirForward)[0];				rot = Math.PI;			}			rot += Math.atan2(_currentTile.y - prevTile.y, _currentTile.x - prevTile.x);			return new Point(_currentTile.x + _tugDistBehind * Math.cos(rot + Math.PI),                             _currentTile.y + _tugDistBehind * Math.sin(rot + Math.PI));		}        public function setFighterMovement(fMovement:FightableMovement, onFront:Boolean):void {            var carRep:TrainCarMovement = onFront ? _carAhead : _carBehind;            if (carRep != null) manager.detatchCar(onFront);            if (fMovement != null) manager.attachCar(fMovement, onFront);        }    }}