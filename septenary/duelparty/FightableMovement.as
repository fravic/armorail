package septenary.duelparty {
    import com.greensock.TweenLite;
    import flash.events.EventDispatcher;
    import flash.display.Sprite;
    import flash.geom.Point;

    public class FightableMovement extends EventDispatcher {

        protected var _fightable:Sprite;
        protected var _currentTile:BoardTile;
        protected var _movedAside:Boolean = false;
        protected var _movedAsideDir:Number = 0;

		public function get currentTile():BoardTile {
			return _currentTile;
		}
        public function get movedAside():Boolean {
            return _movedAside;
        }
        public function get movedAsideDir():Number {
            return _movedAsideDir;
        }

        public function FightableMovement(fightable:Sprite) {
            _fightable = fightable;

            GameBoard.getGameBoard().addEventListener(GameEvent.START_TURN, turnStartHandler, false, 0, true);
        }

        public function kill():void {
            departedCurrentTile(_currentTile);
        }

        protected function turnStartHandler(e:GameEvent):void {
            if (_fightable == e.data.player) {
                unMoveAside();
            } else if ((e.data.player.movement as FightableMovement).currentTile == _currentTile) {
                moveAside(true);
            }
        }

        public function teleportToTile(tile:BoardTile):void {
			if (_currentTile) {
                departedCurrentTile(_currentTile);
			}
			_currentTile = tile;
			_fightable.x = _currentTile.x;
			_fightable.y = _currentTile.y;
            arrivedAtNewTile(_currentTile);
		}

        protected function moveAside(fadeAlpha:Boolean=false):void {
			const asideMag:Number = 25;
			const moveTime:Number = 0.25;

            if (fadeAlpha) moveAsideAlpha();
            if (_movedAside) return;

			var moveDir:Number = moveAsideDir();
			var moveX:Number = asideMag * Math.cos(moveDir);
			var moveY:Number = asideMag * Math.sin(moveDir);
            _movedAsideDir = moveDir;

			TweenLite.to(_fightable, moveTime, {x:_fightable.x + moveX, y:_fightable.y + moveY, overwrite:false});

			_movedAside = true;
		}

        protected function moveAsideAlpha():void {
            const alphaTime:Number = 0.25;
			const asideAlpha:Number = .3;

			TweenLite.to(_fightable, alphaTime, {alpha:asideAlpha, overwrite:false});
        }

		protected function unMoveAside():void {
			const moveTime:Number = 0.25;
			if (!_movedAside) return;

			TweenLite.to(_fightable, moveTime, {x:_currentTile.x, y:_currentTile.y, overwrite:false});
            unMoveAsideAlpha();

            _movedAside = false;
		}

        protected function unMoveAsideAlpha():void {
            const alphaTime:Number = 0.25;
			TweenLite.to(_fightable, alphaTime, {alpha:1, overwrite:false});    
        }

        protected function appendPathDirsFromTileArray(pathDirs:Array, objs:Array):void {
            for (var i:int = 0; i < objs.length; i++) {
                var dx:Number = objs[i].x - _currentTile.x, dy:Number = objs[i].y - _currentTile.y;
				pathDirs.push({dir:Utilities.normalizeRadAngle(Math.atan2(dy, dx)), isPlayer:false});
			}
        }

        protected function appendPathDirsFromFightableArray(pathDirs:Array, fightables:Array):void {
            const minMag:Number = 3;
            for (var i:int = 0; i < fightables.length; i++) {
                var movement:FightableMovement = fightables[i].movement as FightableMovement;
                if (movement == this || !movement.movedAside) continue;
				pathDirs.push({dir:movement.movedAsideDir, isPlayer:true});
			}
        }

		protected function moveAsideDir():Number {
            const isPlayerDirWeight:Number = Math.PI/3;

			var pathDirs:Array = new Array();
            appendPathDirsFromTileArray(pathDirs, _currentTile.tilesIn);
            appendPathDirsFromTileArray(pathDirs, _currentTile.tilesOut);
            appendPathDirsFromFightableArray(pathDirs, _currentTile.residents);

			var maxDiff:Number = 0;
			var optDir:Number = 0;
			pathDirs.sortOn("dir", Array.NUMERIC);
			for (var i:int = 0; i < pathDirs.length; i++){
				var diff:Number;
                var weighting:Number = 0;
                //Take the difference all the way around the circle
				if (i + 1 == pathDirs.length) {
					diff = 2 * Math.PI - (pathDirs[i].dir - pathDirs[0].dir);
                    if (pathDirs[0].isPlayer || pathDirs[i].isPlayer) weighting += isPlayerDirWeight;
				} else {
					diff = pathDirs[i + 1].dir - pathDirs[i].dir;
                    if (pathDirs[i + 1].isPlayer || pathDirs[i].isPlayer) weighting += isPlayerDirWeight;
				}
                var factor:Number = Math.abs(diff) - weighting;
				if (factor > maxDiff) {
					maxDiff = factor;
					optDir = pathDirs[i].dir + diff / 2;
				}
			}
			return optDir;
		}

        protected function arrivedAtNewTile(newTile:BoardTile):void {
	        dispatchEvent(new GameEvent(GameEvent.MOVEMENT_ARRIVED_AT_TILE, {fightable:_fightable, tile:newTile}));
            newTile.addEventListener(GameEvent.TILE_RESIDENT_ARRIVED, newNeighbourHandler, false, 0, true);
            newTile.addEventListener(GameEvent.TILE_RESIDENT_DEPARTED, neighbourGoneHandler, false, 0, true);
        }

        protected function departedCurrentTile(prevTile:BoardTile):void {
            prevTile.removeEventListener(GameEvent.TILE_RESIDENT_ARRIVED, newNeighbourHandler);
            prevTile.removeEventListener(GameEvent.TILE_RESIDENT_DEPARTED, neighbourGoneHandler);
			dispatchEvent(new GameEvent(GameEvent.MOVEMENT_DEPARTED_TILE, {fightable:_fightable, tile:prevTile}));
        }

        protected function newNeighbourHandler(e:GameEvent):void {
            if (_fightable == GameBoard.getGameBoard().curTurnPlayer()) {
                (e.data.fightable.movement as FightableMovement).moveAside(true);
            } else {
                moveAside(e.data.fightable == GameBoard.getGameBoard().curTurnPlayer());
            }
        }

        protected function neighbourGoneHandler(e:GameEvent):void {
            if (_currentTile.residents.length == 1 || _fightable == _currentTile.residents[0]) {
                unMoveAside();
            } else {
                unMoveAsideAlpha();
            }
        }
    }
}