package septenary.duelparty {
	import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.display.Sprite;
	import flash.ui.Keyboard;

    import com.greensock.TweenLite;

	public class GameScreen extends Screen {
		
		protected static var activeScreen:GameScreen;
		
		protected const CAMERA_CENTER:Point = new Point(DuelParty.stageWidth/2, DuelParty.stageHeight/2);

		protected var _gameBoard:GameBoard;
		protected var _gameInterface:GameInterface;
		protected var _boardDefs:Array = new Array();
        protected var _darkOverlay:Sprite;

        protected var _cameraTarget:Point = new Point(0, 0);
        protected var _cameraZoom:Number = 1;
		protected var _scrollCoords:Point = new Point(0, 0);
		protected var _snapCoordinates:Array = new Array();
        protected var _superScreenIsSnapped:Array = new Array();

		public static function getGameScreen():GameScreen {
			return activeScreen;
		}
		
		public function GameScreen(screenData:Object=null) {
			GameScreen.activeScreen = this;
            GUIAnimationFactory.setActiveScreen(this);

			screenData.boardType = "default";
			screenData.playerDatas = [new PlayerData("PlayerBlue", "Player 1", NetScreen.PLAYER_INPUT, 0, 0xFF0000, 2),
                                      new PlayerData("PlayerOrange", "Player 2", NetScreen.AI_INPUT, 1, 0x00FF00, 0)];
			
			//Initialize game board
			_gameBoard = new GameBoard(this);
			_gameBoard.initBoard(screenData.boardType, screenData.playerDatas);
			addChild(_gameBoard);
			
			//Initialize game interface
			_gameInterface = new GameInterface(this);
			_gameInterface.initInterface(screenData.playerDatas);
			pushSuperScreen(_gameInterface);
		}
		
		public override function update():void {
			_gameBoard.update();
			scrollCamera();
			updateCamera();
			updateSuperScreenSnaps();
			super.update();
		}

        public function setCameraTarget(targ:Point):void {
            _cameraTarget = targ;
        }

        public function setCameraZoom(targ:Number, instant:Boolean=false):void {
            _cameraZoom = keepTargetZoomInRange(
                            keepTargetZoomInRange(targ, _gameBoard.width, DuelParty.stageWidth, _gameBoard.scaleX),
                            _gameBoard.height, DuelParty.stageHeight, _gameBoard.scaleY);
            if (instant) {
                _gameBoard.scaleX = _gameBoard.scaleY = _cameraZoom;
                updateCamera(true);
            }
        }

        public function darken(alpha:Number=0.5, fadeDuration:Number=1):void {
            _darkOverlay = new Sprite();
            _darkOverlay.graphics.beginFill(0x0, alpha);
            _darkOverlay.graphics.drawRect(0, 0, DuelParty.stageWidth, DuelParty.stageHeight);
            _darkOverlay.alpha = 0;
            addChildAt(_darkOverlay, getChildIndex(_gameBoard) + 1);

            function darkened():void {
                dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE));
            }
            TweenLite.to(_darkOverlay, fadeDuration, {alpha:1, onComplete:darkened});
        }

        public function unDarken():void {
            const fadeDuration:Number = 1;

            function unDarkened():void {
                removeChild(_darkOverlay);
                _darkOverlay = null;
                dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE));
            }
            TweenLite.to(_darkOverlay, fadeDuration, {alpha:0, onComplete:unDarkened});
        }

        protected function keepTargetZoomInRange(targ:Number, boardParam:Number, screenParam:Number,
                                                 boardScale:Number):Number {
            var maxParam:Number = boardParam / boardScale;
            if (maxParam * targ < screenParam) {
                targ = screenParam / maxParam;
            }
            return targ;
        }
		
		protected function updateCamera(instantZoom:Boolean=false):void {
			if (!_gameBoard.background) return;

            const camZoom:Number = 15;
            _gameBoard.scaleX += (_cameraZoom - _gameBoard.scaleX) / camZoom;
            _gameBoard.scaleY = _gameBoard.scaleX;
			
			const camMove:Number = 15;
			var targPoint:Point = new Point(-_cameraTarget.x * _cameraZoom + CAMERA_CENTER.x,
											-_cameraTarget.y * _cameraZoom + CAMERA_CENTER.y);
			targPoint.x -= _scrollCoords.x;
			targPoint.y -= _scrollCoords.y;
			Utilities.keepPointInBounds(targPoint, new Rectangle(-_gameBoard.background.width * _cameraZoom
                                                                 + DuelParty.stageWidth,
                                                                 -_gameBoard.background.height * _cameraZoom
                                                                 + DuelParty.stageHeight,
                                                                 0, 0));
			if (instantZoom) {
                _gameBoard.x = targPoint.x;
                _gameBoard.y = targPoint.y;
            } else {
                _gameBoard.x += (targPoint.x - _gameBoard.x) / camMove;
			    _gameBoard.y += (targPoint.y - _gameBoard.y) / camMove;
            }
		}
		
		protected function updateSuperScreenSnaps():void {
            Utilities.assert(_snapCoordinates.length == _superScreens.length, "Sync error in snap coordinates array.");
            for (var i:int = 0; i < _snapCoordinates.length; i++) {
                if (!_superScreenIsSnapped[i]) continue;
                _superScreens[i].x = (_gameBoard.x + _snapCoordinates[i].x) * _cameraZoom;
                _superScreens[i].y = (_gameBoard.y + _snapCoordinates[i].y) * _cameraZoom;
            }
		}
		
		protected function scrollCamera():void {
			const scrollSpd:Number = 30;
			var resetScroll:Boolean = true;
			if (_hasFocus) {
				if (KeyActions.keyIsDown(Keyboard.LEFT)) {
					_scrollCoords.x -= scrollSpd;
					resetScroll = false;
				} else if (KeyActions.keyIsDown(Keyboard.RIGHT)) {
					_scrollCoords.x += scrollSpd;
					resetScroll = false;
				} 
				if (KeyActions.keyIsDown(Keyboard.DOWN)) {
					_scrollCoords.y += scrollSpd;
					resetScroll = false;
				} else if (KeyActions.keyIsDown(Keyboard.UP)) {
					_scrollCoords.y -= scrollSpd;
					resetScroll = false;
				}  
			}
			if (resetScroll) {
				_scrollCoords.x = _scrollCoords.y = 0;
			}
		}
		
		public override function pushSuperScreen(screen:Screen):void {
			super.pushSuperScreen(screen);
            _snapCoordinates.push(new Point(0, 0));
            _superScreenIsSnapped.push(false);
		}

        public function pushAndSnapSuperScreen(screen:Screen):void {
            pushSuperScreen(screen);
            _snapCoordinates[_snapCoordinates.length-1] = new Point(screen.x, screen.y);
            _superScreenIsSnapped[_superScreenIsSnapped.length-1] = true;
            screen.x += _gameBoard.x;
            screen.y += _gameBoard.y;
            screen.x *= _cameraZoom;
            screen.y *= _cameraZoom;
        }

        public override function dismissSuperScreen(screen:Screen):void {
            _snapCoordinates.splice(_superScreens.indexOf(screen), 1);
            _superScreenIsSnapped.splice(_superScreens.indexOf(screen), 1);
            super.dismissSuperScreen(screen);
        }

        public override function addGUIAnimation(anim:Sprite, data:Object):void {
            _gameBoard.addChildToOverlay(anim);
        }
		
		public override function gainedFocus():void {
			_gameBoard.gainedFocus();	
			super.gainedFocus();
		}
		
		public override function lostFocus():void {
			_gameBoard.lostFocus();
			super.lostFocus();
		}

	}
}