package septenary.duelparty {
	import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.display.Sprite;
	import flash.ui.Keyboard;

    import com.greensock.TweenLite;

	public class GameScreen extends Screen {
		
		protected const CAMERA_CENTER:Point = new Point(DuelParty.stageWidth/2, DuelParty.stageHeight/2);

		protected var _boardDefs:Array = new Array();
        protected var _darkOverlay:Sprite;

        protected var _cameraTarget:Point = new Point(0, 0);
        protected var _cameraZoom:Number = 1;
		protected var _scrollCoords:Point = new Point(0, 0);
		protected var _snapCoordinates:Array = new Array();
        protected var _superScreenIsSnapped:Array = new Array();

		public function GameScreen(screenData:Object=null) {
            Singleton.init(this);
            GUIAnimationFactory.setActiveScreen(this);
			
			//Initialize game board
			Singleton.get(GameBoard).initBoard(screenData.boardType, screenData.playerDatas);
			addChild(Singleton.get(GameBoard));
			
			//Initialize game interface
			pushSuperScreen(Singleton.get(GameInterface));
		}
		
		public override function update():void {
			Singleton.get(GameBoard).update();
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
                            keepTargetZoomInRange(targ, Singleton.get(GameBoard).width, DuelParty.stageWidth,
                            Singleton.get(GameBoard).scaleX), Singleton.get(GameBoard).height, DuelParty.stageHeight,
                            Singleton.get(GameBoard).scaleY);
            if (instant) {
                Singleton.get(GameBoard).scaleX = Singleton.get(GameBoard).scaleY = _cameraZoom;
                updateCamera(true);
            }
        }

        public function darken(alpha:Number=0.5, fadeDuration:Number=1):void {
            _darkOverlay = new Sprite();
            _darkOverlay.graphics.beginFill(0x0, alpha);
            _darkOverlay.graphics.drawRect(0, 0, DuelParty.stageWidth, DuelParty.stageHeight);
            _darkOverlay.alpha = 0;
            addChildAt(_darkOverlay, getChildIndex(Singleton.get(GameBoard)) + 1);

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
			if (!Singleton.get(GameBoard).background) return;

            const camZoom:Number = 15;
            Singleton.get(GameBoard).scaleX += (_cameraZoom - Singleton.get(GameBoard).scaleX) / camZoom;
            Singleton.get(GameBoard).scaleY = Singleton.get(GameBoard).scaleX;
			
			const camMove:Number = 15;
			var targPoint:Point = new Point(-_cameraTarget.x * _cameraZoom + CAMERA_CENTER.x,
											-_cameraTarget.y * _cameraZoom + CAMERA_CENTER.y);
			targPoint.x -= _scrollCoords.x;
			targPoint.y -= _scrollCoords.y;
			Utilities.keepPointInBounds(targPoint, new Rectangle(-Singleton.get(GameBoard).background.width *
                                                                 _cameraZoom + DuelParty.stageWidth,
                                                                 -Singleton.get(GameBoard).background.height *
                                                                 _cameraZoom + DuelParty.stageHeight,
                                                                 0, 0));
			if (instantZoom) {
                Singleton.get(GameBoard).x = targPoint.x;
                Singleton.get(GameBoard).y = targPoint.y;
            } else {
                Singleton.get(GameBoard).x += (targPoint.x - Singleton.get(GameBoard).x) / camMove;
			    Singleton.get(GameBoard).y += (targPoint.y - Singleton.get(GameBoard).y) / camMove;
            }
		}
		
		protected function updateSuperScreenSnaps():void {
            Utilities.assert(_snapCoordinates.length == _superScreens.length, "Sync error in snap coordinates array.");
            for (var i:int = 0; i < _snapCoordinates.length; i++) {
                if (!_superScreenIsSnapped[i]) continue;
                _superScreens[i].x = (Singleton.get(GameBoard).x + _snapCoordinates[i].x) * _cameraZoom;
                _superScreens[i].y = (Singleton.get(GameBoard).y + _snapCoordinates[i].y) * _cameraZoom;
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
            screen.x += Singleton.get(GameBoard).x;
            screen.y += Singleton.get(GameBoard).y;
            screen.x *= _cameraZoom;
            screen.y *= _cameraZoom;
        }

        public override function dismissSuperScreen(screen:Screen):void {
            _snapCoordinates.splice(_superScreens.indexOf(screen), 1);
            _superScreenIsSnapped.splice(_superScreens.indexOf(screen), 1);
            super.dismissSuperScreen(screen);
        }

        public override function addGUIAnimation(anim:Sprite, data:Object):void {
            Singleton.get(GameBoard).addChildToOverlay(anim);
        }
		
		public override function gainedFocus():void {
			Singleton.get(GameBoard).gainedFocus();	
			super.gainedFocus();
		}
		
		public override function lostFocus():void {
			Singleton.get(GameBoard).lostFocus();
			super.lostFocus();
		}

	}
}