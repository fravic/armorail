package septenary.duelparty {    import com.greensock.TweenLite;    import flash.display.Sprite;    import flash.geom.Point;    import flash.events.EventDispatcher;    import fl.motion.easing.Linear;    public class PlayerMovement extends FightableMovement {        protected static const FIGHTER_SPACING:Number = 30;		protected static const MOVE_SPEED:Number = 180;        protected var _rearGuard:Fighter;        protected var _foreGuard:Fighter;        protected var _moveDirForward:Boolean = true;        protected var _prevTile:BoardTile;        protected var _movesLeftCounter:MovesLeftCounter;        protected var _moveCount:int = 0;        public function get moveDirForward():Boolean {			return _moveDirForward;		}        public function get moveCount():int {            return _moveCount;        }        public function set moveCount(value:int):void {            hideMovesLeftCounter();            _moveCount = value;        }        public function PlayerMovement(player:Player):void {            super(player);        }        public override function kill():void {            super.kill();            _moveDirForward = true;        }        public function updateFighters(foreGuard:Fighter, rearGuard:Fighter, reposition:Boolean=true):void {            _foreGuard = foreGuard;            _rearGuard = rearGuard;            if (reposition) {                positionForeGuard(false);                positionRearGuard(false);            }        }        public function reverseFighters(reposition:Boolean=true):void {            if (!_foreGuard && !_rearGuard) dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE));            updateFighters(_rearGuard, _foreGuard, false);            if (!reposition) return;            var fightersReversed:int = 0;            function fighterReversed():void {                fightersReversed++;                if (fightersReversed == 2 || !_foreGuard || !_rearGuard) {                    dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE));                }            }            positionForeGuard(true, fighterReversed);            positionRearGuard(true, fighterReversed);        }        public function reverseMovement():void {			_moveDirForward = !_moveDirForward;            var faceTile:BoardTile = _currentTile.getTilesInDir(_moveDirForward)[0];            rotateToFaceObject(_fightable, faceTile);            if (_foreGuard) rotateToFaceObject(_foreGuard, faceTile);            if (_rearGuard) rotateToFaceObject(_rearGuard, _currentTile);            trace("SWITCHED MOVEMENT");		}		public override function teleportToTile(tile:BoardTile):void {			super.teleportToTile(tile);			positionForeGuard(false);			positionRearGuard(false);		}        protected override function moveAside(fadeAlpha:Boolean=false):void {			const moveTime:Number = 0.25;			const asideMag:Number = 35;            if (fadeAlpha) moveAsideAlpha();            if (_movedAside) return;            super.moveAside(false);            var moveDir:Number = moveAsideDir();			var moveX:Number = asideMag * Math.cos(moveDir);			var moveY:Number = asideMag * Math.sin(moveDir);            if (_foreGuard) {				TweenLite.to(_foreGuard, moveTime, {x:_foreGuard.x + moveX, y:_foreGuard.y + moveY, overwrite:false});			}			if (_rearGuard) {				TweenLite.to(_rearGuard, moveTime, {x:_rearGuard.x + moveX, y:_rearGuard.y + moveY, overwrite:false});			}        }        protected override function moveAsideAlpha():void {            const alphaTime:Number = 0.25;			const asideAlpha:Number = .3;            super.moveAsideAlpha();            if (_foreGuard) {				TweenLite.to(_foreGuard, alphaTime, {alpha:asideAlpha, overwrite:false});			}			if (_rearGuard) {				TweenLite.to(_rearGuard, alphaTime, {alpha:asideAlpha, overwrite:false});			}        }        protected override function unMoveAside():void {			const moveTime:Number = 0.25;			if (!_movedAside) return;            super.unMoveAside();                        if (_foreGuard) {				var fGP:Point = positionForForeGuard();				TweenLite.to(_foreGuard, moveTime, {x:fGP.x, y:fGP.y, alpha:1, overwrite:false});			}			if (_rearGuard) {				var rGP:Point = positionForRearGuard();				TweenLite.to(_rearGuard, moveTime, {x:rGP.x, y:rGP.y, alpha:1, overwrite:false});			}        }        protected override function unMoveAsideAlpha():void {			const alphaTime:Number = 0.25;            super.unMoveAsideAlpha();			if (_foreGuard) {				TweenLite.to(_foreGuard, alphaTime, {alpha:1, overwrite:false});			}			if (_rearGuard) {				var rGP:Point = positionForRearGuard();				TweenLite.to(_rearGuard, alphaTime, {alpha:1, overwrite:false});			}		}		public function move(moveCount:int):void {			_moveCount = moveCount;			progress();		}		public function progress():void {            showMovesLeftCounter();            GameEvent.addOneTimeEventListener(_currentTile, GameEvent.ACTION_COMPLETE, nextTileSelected);            dispatchEvent(new GameEvent(GameEvent.MOVEMENT_REQUEST_NEXT_TILE, {tile:_currentTile}));		}		protected function nextTileSelected(e:GameEvent):void {            var nextTile:BoardTile = e.data.tile;			_prevTile = _currentTile;			_currentTile = nextTile;			prepareForMovement();		}        protected function rotateFighter(fighter:Sprite, centerTile:BoardTile, newAngle:Number,                                         onComplete:Function, rotateMonodir:Boolean=false):void {            const rotateSpeed:Number = 150;            trace("ROTATING FIGHTER");            var fGX:Number = centerTile.x + FIGHTER_SPACING * Math.cos(newAngle);            var fGY:Number = centerTile.y + FIGHTER_SPACING * Math.sin(newAngle);            //Don't collide with player while moving            var curRot:Number = Math.atan2(fighter.y - centerTile.y, fighter.x - centerTile.x);            var rotDiff:Number = Utilities.normalizeRadAngle(curRot - newAngle);            var pivotAngle:Number = curRot > newAngle ? curRot - rotDiff/2 : curRot + rotDiff/2;            if (rotateMonodir && pivotAngle > curRot && pivotAngle < newAngle) {                pivotAngle = Utilities.normalizeRadAngle(newAngle - curRot);            }            var pivotX:Number = centerTile.x + FIGHTER_SPACING * Math.cos(pivotAngle);            var pivotY:Number = centerTile.y + FIGHTER_SPACING * Math.sin(pivotAngle);            var dx1:Number = pivotX - fighter.x, dy1 = pivotY - fighter.y, dx2 = fGX - pivotX, dy2 = fGY - pivotY;            var dist:Number = Math.sqrt(dx1 * dx1 + dy1 * dy1) + Math.sqrt(dx2 * dx2 + dy2 * dy2);            tweenTo(fighter, dist / rotateSpeed, {bezierThrough:[{x:pivotX, y:pivotY}, {x:fGX, y:fGY}],                             orientToBezier:true, onComplete:onComplete});        }		protected function prepareForMovement():void {			//Re-position foreGuard, unless the next tile is the default			if (_foreGuard && _currentTile != _prevTile.getTilesInDir(_moveDirForward)[0]) {                var rot:Number = Math.atan2(_currentTile.y - _prevTile.y, _currentTile.x - _prevTile.x);				rotateFighter(_foreGuard, _prevTile, rot, preparedToMove);			} else {				preparedToMove();			}		}		protected function preparedToMove():void {			//Check for battle!			if (_currentTile.hasResidents()) {                hideMovesLeftCounter();                GameEvent.addOneTimeEventListener(_fightable, GameEvent.BATTLE_FINISHED, progressMovementStart);                dispatchEvent(new GameEvent(GameEvent.MOVEMENT_ENEMY_ENCOUNTERED, {tile:_currentTile}));			} else {				progressMovementStart();			}		}		protected function progressMovementStart(e:GameEvent=null):void {			const fighterPrepTime:Number = .15;            super.arrivedAtNewTile(_currentTile);            showMovesLeftCounter();			//Tween takes different time depending on distance			var dx:Number = _currentTile.x - _prevTile.x;			var dy:Number = _currentTile.y - _prevTile.y;			var dist:Number = Math.sqrt(dx * dx + dy * dy);			var time:Number = dist / MOVE_SPEED;			var fighterTime:Number = time - FIGHTER_SPACING / MOVE_SPEED;			if (_foreGuard) {				rotateThenMoveTo(_foreGuard, fighterTime, {x:_currentTile.x, y:_currentTile.y, ease:Linear.easeNone,                                 onComplete:foreGuardMovement});			}			rotateThenMoveTo(_fightable, time + fighterPrepTime, {x:_currentTile.x, y:_currentTile.y,                             ease:Linear.easeNone, onComplete:progressMovementEnd});			//Rear guard still has to catch up to prev tile			if (_rearGuard) {				rotateThenMoveTo(_rearGuard, FIGHTER_SPACING / MOVE_SPEED, {x:_prevTile.x, y:_prevTile.y,                                 ease:Linear.easeNone, onComplete:rearGuardMovement,                                 onCompleteParams:[fighterTime]});			}		}		protected function foreGuardMovement():void {			//Move foreGuard slightly past tile in default direction			var pos:Point = positionForForeGuard();			rotateThenMoveTo(_foreGuard, FIGHTER_SPACING / MOVE_SPEED, {x:pos.x, y:pos.y, ease:Linear.easeNone});		}		protected function rearGuardMovement(time:Number):void {			//Move rearGuard almost to tile			var pos:Point = positionForRearGuard();			rotateThenMoveTo(_rearGuard, time, {x:pos.x, y:pos.y, ease:Linear.easeNone});		}		protected function progressMovementEnd():void {            super.departedCurrentTile(_prevTile);            if (_currentTile.reducesMoveCount) {				_moveCount--;                hideMovesLeftCounter();			}            GameEvent.addOneTimeEventListener(_currentTile, GameEvent.ACTION_COMPLETE, tileActivationComplete);            dispatchEvent(new GameEvent(GameEvent.MOVEMENT_TILE_ACTIVATION,                                       {player:_fightable, tile:_currentTile, onPass:(_moveCount > 0)}));		}		public function tileActivationComplete(e:GameEvent):void {			if (_moveCount > 0) {				progress();			} else {                dispatchEvent(new GameEvent(GameEvent.MOVEMENT_ENDED));			}		}		protected function positionForForeGuard():Point {			var defNextTile:BoardTile = _currentTile.getTilesInDir(_moveDirForward)[0];			var rot:Number = Math.atan2(defNextTile.y - _currentTile.y, defNextTile.x - _currentTile.x);			return new Point(_currentTile.x + FIGHTER_SPACING * Math.cos(rot), _currentTile.y + FIGHTER_SPACING * Math.sin(rot));		}		protected function positionForRearGuard():Point {			var rot:Number = 0;            var prevTile:BoardTile = _prevTile;			if (!prevTile) {				prevTile = _currentTile.getTilesInDir(!_moveDirForward)[0];			}			if (!prevTile) {				prevTile = _currentTile.getTilesInDir(_moveDirForward)[0];				rot = Math.PI;			}			rot += Math.atan2(_currentTile.y - prevTile.y, _currentTile.x - prevTile.x);			return new Point(_currentTile.x + FIGHTER_SPACING * Math.cos(rot + Math.PI),                              _currentTile.y + FIGHTER_SPACING * Math.sin(rot + Math.PI));		}		public function positionForeGuard(rotateMotion:Boolean=false, callback:Function=null):void {			if (_foreGuard) {				var pos:Point = positionForForeGuard();                if (!rotateMotion) {				    _foreGuard.x = pos.x;				    _foreGuard.y = pos.y;                } else {                    var rot:Number = Math.atan2(pos.y - _currentTile.y, pos.x - _currentTile.x);                    rotateFighter(_foreGuard, _currentTile, rot, callback, (_foreGuard != null && _rearGuard != null));                }			}		}		public function positionRearGuard(rotateMotion:Boolean=false, callback:Function=null):void {			if (_rearGuard) {				var pos:Point = positionForRearGuard();                if (!rotateMotion) {				    _rearGuard.x = pos.x;				    _rearGuard.y = pos.y;                } else {                    var rot:Number = Math.atan2(pos.y - _currentTile.y, pos.x - _currentTile.x);                    rotateFighter(_rearGuard, _currentTile, rot, callback, (_foreGuard != null && _rearGuard != null));                }			}		}        protected function rotateToFaceObject(obj:Object, obj2:Object):void {           	const prepRotTime:Number = .15;            var rot:Number = Math.atan2(obj2.y - obj.y, obj2.x - obj.x);			TweenLite.to(obj, prepRotTime, {shortRotation:{rotation:(rot * 180 / Math.PI)}});        }		protected function rotateThenMoveTo(obj:Sprite, time:Number, args:Object):void {			const prepRotSpeed:Number = 2*Math.PI;            var endPt:Point = new Point(args.x, args.y);            if (args.bezierThrough != null) {                endPt.x = args.bezierThrough[1].x;                endPt.y = args.bezierThrough[1].y;            }			var rot:Number = Math.atan2(endPt.y - obj.y, endPt.x - obj.x);            var rotDiff:Number = Utilities.angleDiff(obj.rotation*Math.PI/180, rot);            Utilities.assert(rotDiff >= 0, "Rotation difference cannot be negative.  (Value of "+rotDiff+".)");            if (rotDiff == 0) {                tweenTo(obj, time, args);                return;            }            TweenLite.to(obj, rotDiff/prepRotSpeed, {shortRotation:{rotation:(rot * 180 / Math.PI)}, onComplete:tweenTo,                                            onCompleteParams:[obj, time, args]}); 		}		protected function tweenTo(obj:Sprite, time:Number, args:Object):void {			TweenLite.to(obj, time, args);		}        public function update():void {            if (_movesLeftCounter) {                var pos:Point = positionForMovesLeftCounter();                _movesLeftCounter.x = pos.x;                _movesLeftCounter.y = pos.y;            }        }        protected function showMovesLeftCounter():void {            if (!_movesLeftCounter) {                _movesLeftCounter = GUIAnimationFactory.createAndAddAnimation(GUIAnimationFactory.MOVES_LEFT_COUNTER,                                       positionForMovesLeftCounter(), {movesLeft:_moveCount}, null) as MovesLeftCounter;            }        }        protected function hideMovesLeftCounter():void {            if (!_movesLeftCounter) return;            GameBoard.getGameBoard().removeChildFromOverlay(_movesLeftCounter);            _movesLeftCounter = null;        }        protected function positionForMovesLeftCounter():Point {            const yOffset:Number = 40;            return new Point(_fightable.x, _fightable.y - yOffset);        }    }}