package septenary.duelparty {    import com.greensock.TweenLite;	import flash.display.MovieClip;    import flash.events.MouseEvent;	import flash.geom.ColorTransform;    import flash.geom.Point;	import flash.utils.Dictionary;    import flash.display.BlendMode;    import flash.display.Sprite;    import flash.text.TextFieldAutoSize;    import flash.utils.setTimeout;    import fl.containers.ScrollPane;    import com.greensock.easing.Quad;    import org.flintparticles.common.counters.*;    import org.flintparticles.common.initializers.*;    import org.flintparticles.twoD.actions.*;    import org.flintparticles.twoD.emitters.Emitter2D;    import org.flintparticles.twoD.initializers.*;    import org.flintparticles.twoD.renderers.*;    import org.flintparticles.twoD.zones.*;    import septenary.duelparty.boardtiles.BuffTile;	public class GameInterface extends Screen {		protected var _interfaceForPlayer:Dictionary = new Dictionary();        protected var _fighterForInfo:Dictionary = new Dictionary();		protected var _numPlayerInterfaces:int = 0;        protected var _activeFighterInfo:FighterInfo;        protected var _chatPane:ScrollPane;        public function get interfaceForPlayer():Dictionary {            return _interfaceForPlayer;        }        public function GameInterface() {            Singleton.init(this);            _alwaysOnTop = true;            constructChatPane();            super();		}        protected function constructChatPane():void {            const chatPaneWidth:Number = 450;            const chatPaneHeight:Number = 60;            const chatPaneX:Number = 0;            const chatPaneY:Number = DuelParty.stageHeight - chatPaneHeight;            _chatPane = new ScrollPane();            _chatPane.source = new Sprite();            _chatPane.setSize(chatPaneWidth, chatPaneHeight);            _chatPane.move(chatPaneX, chatPaneY);            addChild(_chatPane);        }        public override function update():void {            var players:Array = Singleton.get(GameBoard).players;            for (var i:int = 0; i < players.length; i++) {                updateHealthBarForPlayer(players[i]);            }            super.update();        }        public function hidePlayerInterfaces():void {            const fadeTime:Number = 0.5;            for each (var i:MovieClip in _interfaceForPlayer) {                TweenLite.to(i, fadeTime, {alpha:0});            }        }        public function showPlayerInterfaces():void {            const fadeTime:Number = 0.5;            for each (var i:MovieClip in _interfaceForPlayer) {                TweenLite.to(i, fadeTime, {alpha:1});            }        }        protected function updateHealthBarForPlayer(player:Player):void {            const colorWeight:Number = 0.9;            const barCatchupRatio:Number = 6;            var pInt:PlayerInterface = _interfaceForPlayer[player];            if (pInt == null) return;            var targBarRatio:Number = player.health/player.maxHealth;            pInt.player.healthBar.scaleX += (targBarRatio - pInt.player.healthBar.scaleX) / barCatchupRatio;            var healthCT:ColorTransform = pInt.player.healthBar.transform.colorTransform;            var rgb:Object = healthBarColorInterpolation(pInt.player.healthBar.scaleX);            healthCT.redOffset = rgb.red * colorWeight;            healthCT.greenOffset = rgb.green * colorWeight;            healthCT.blueOffset = rgb.blue * colorWeight;            pInt.player.healthBar.transform.colorTransform = healthCT;        }        public function placementsForPlayers(players:Array):Array {            var placements:Array = new Array();            var orderedPlayers:Array = players.slice();            orderedPlayers.sortOn("health", Array.DESCENDING | Array.NUMERIC);            for (var i:int = 0; i < orderedPlayers.length; i++) {                if (i > 0 && orderedPlayers[i].health == orderedPlayers[i - 1].health) {                    placements[players.indexOf(orderedPlayers[i])] = placements[players.indexOf(orderedPlayers[i - 1])];                } else {                    placements[players.indexOf(orderedPlayers[i])] = i + 1;                }            }            return placements;        }        protected function healthBarColorInterpolation(scale:Number):Object {            const colors:Array = [0xD50000, 0xD50000, 0xD58000, 0x6AB520, 0x32C80D];            const positions:Array = [0, 0.2, 0.3, 0.6, 1];            var btmColor:int = 0;            var topColor:int = 0;            var ratio:Number = 0;            for (var i:int = 0; i < positions.length - 1; i++) {                if (scale > positions[i] && scale <= positions[i + 1]) {                    btmColor = colors[i];                    topColor = colors[i + 1];                    ratio = (scale - positions[i]) / (positions[i + 1] - positions[i]);                }            }            var btmRGB:Object = Utilities.hexToRGB(btmColor);            var topRGB:Object = Utilities.hexToRGB(topColor);            var redOffset:Number = btmRGB.red + (topRGB.red - btmRGB.red) * ratio;            var blueOffset:Number = btmRGB.blue + (topRGB.blue - btmRGB.blue) * ratio;            var greenOffset:Number = btmRGB.green + (topRGB.green - btmRGB.green) * ratio;            return {red:redOffset, green:greenOffset, blue:blueOffset};        }		public function addPlayerInterface(player:Player):void {            var newPlayerInt:PlayerInterface = new PlayerInterface();            positionPlayerInterface(newPlayerInt);			var pCT:ColorTransform = newPlayerInt.color.transform.colorTransform;			pCT.color = player.playerData.color;			newPlayerInt.color.core.transform.colorTransform = pCT;			newPlayerInt.dead.visible = false;            newPlayerInt.player.healthBar.mask = newPlayerInt.player.healthBarMask;            //Set text fields to be alpha enabled            newPlayerInt.player.lblName.blendMode = newPlayerInt.player.lblCoins.blendMode =                                                    newPlayerInt.player.lblLives.blendMode = BlendMode.LAYER;            setupFighterInfo(newPlayerInt.fighterFront);            setupFighterInfo(newPlayerInt.fighterBack);            //We no longer want fighter overlays, since they are mouse-dependant            //setupFighterOverlays(newPlayerInt.fighterFront);            //setupFighterOverlays(newPlayerInt.fighterBack);			addChild(newPlayerInt);            _fighterForInfo[newPlayerInt.fighterFront] = player.foreGuard;            _fighterForInfo[newPlayerInt.fighterBack] = player.rearGuard;			_interfaceForPlayer[player] = newPlayerInt;			updatePlayerInterface(player);            moveFighterInfoOut(newPlayerInt.fighterFront, true);            moveFighterInfoOut(newPlayerInt.fighterBack, true);            _numPlayerInterfaces++;		}        protected function setupFighterInfo(fInt:MovieClip):void {            fInt.lblName.blendMode = fInt.lblAttack.blendMode = fInt.lblHealth.blendMode = fInt.lblCounter.blendMode =                                                                                           BlendMode.LAYER;        }        protected function positionPlayerInterface(newInt:PlayerInterface):void {            const playerIntOffScreenX:Number = 225;            const playerIntX:Number = 127;            const playerIntY:Number = 80;            const moveTime:Number = 1;            var position:int;       // 0 is top left, 3 is bottom left, counter-clockwise            var numPlayers:int = Singleton.get(GameBoard).players.length;            if (numPlayers <= 2) position = _numPlayerInterfaces != numPlayers - 1 ? 0 : 2;            else position = _numPlayerInterfaces;            var moveTo:Point = new Point();            if (position == 1 || position == 2) {                newInt.gotoAndStop("standard");                moveTo.x = DuelParty.stageWidth - playerIntX;                newInt.x = moveTo.x + playerIntOffScreenX;            } else {                newInt.gotoAndStop("reversed");                moveTo.x = playerIntX;                newInt.x = moveTo.x - playerIntOffScreenX;            }            if (position >= 2) newInt.y = DuelParty.stageHeight - playerIntY;            else newInt.y = playerIntY;            TweenLite.to(newInt, moveTime, {x:moveTo.x});        }        public function updatePlayerInterface(player:Player):void {            const deathFadeTime:Number = 5;			var inter:PlayerInterface = _interfaceForPlayer[player];			if (!inter) return;						inter.player.lblName.text = player.playerData.name;			inter.player.lblCoins.text = "x" + player.coins;			inter.player.lblLives.text = player.health;			if (player.dead && !inter.dead.visible) {                inter.dead.visible = true;                inter.dead.alpha = 0;                TweenLite.to(inter.dead, deathFadeTime, {alpha:1});			}            refreshFighterForInfo(inter.fighterFront, player.foreGuard);            refreshFighterForInfo(inter.fighterBack, player.rearGuard);			updatePlayerFighter(inter.fighterFront, player.foreGuard);			updatePlayerFighter(inter.fighterBack, player.rearGuard);            updatePlacements();		}        protected function refreshFighterForInfo(intObj:MovieClip, fighter:Fighter):void {            var oldFighter:Fighter = _fighterForInfo[intObj];            if (_fighterForInfo[intObj] == fighter) return;            _fighterForInfo[intObj] = fighter;            if (fighter == null) moveFighterInfoOut(intObj);            else moveFighterInfoIn(intObj);            if (_activeFighterInfo && _activeFighterInfo.fighter == oldFighter) {                removeChild(_activeFighterInfo);                fighterInfoOverlay(intObj);            }        }        protected function updatePlacements():void {            var players:Array = Singleton.get(GameBoard).players;            var placements:Array = placementsForPlayers(players);            for (var i:int = 0; i < players.length; i++) {                if (!_interfaceForPlayer[players[i]]) continue;                _interfaceForPlayer[players[i]].placement.gotoAndStop(placements[i]);            }        }        protected function setupFighterOverlays(obj:MovieClip):void {            obj.mouseChildren = false;            obj.addEventListener(MouseEvent.MOUSE_OVER, fighterInfoOverlayHandler, false, 0, true);            obj.addEventListener(MouseEvent.MOUSE_OUT, fighterInfoOut, false, 0, true);        }        protected function fighterInfoOverlayHandler(e:MouseEvent):void {            fighterInfoOverlay(e.target);        }        protected function fighterInfoOverlay(intObj:Object):void {           const fighterInfoYOffset:Number = -30;           const fighterInfoXOffset:Number = 0;           var fighterInfo:FighterInfo = new FighterInfo();           fighterInfo.setFighterInfo(_fighterForInfo[intObj], true);           fighterInfo.mouseEnabled = false;           fighterInfo.mouseChildren = false;           fighterInfo.x = intObj.parent.x + fighterInfoXOffset;           fighterInfo.y = intObj.parent.y + fighterInfoYOffset;           if (fighterInfo.x + fighterInfo.width > DuelParty.stageWidth)               fighterInfo.x = DuelParty.stageWidth - fighterInfo.width;           if (fighterInfo.y + fighterInfo.height > DuelParty.stageHeight)               fighterInfo.y = DuelParty.stageHeight - fighterInfo.height;           addChild(fighterInfo);           _activeFighterInfo = fighterInfo;        }        protected function fighterInfoOut(e:MouseEvent):void {            if (_activeFighterInfo.stage) removeChild(_activeFighterInfo);            _activeFighterInfo = null;        }		protected function updatePlayerFighter(fInt:MovieClip, fighter:Fighter):void {			if (fighter) {				fInt.lblName.text = fighter.fighterName;                fInt.lblAttack.text = fighter.attack;                fInt.lblHealth.text = fighter.health;                fInt.lblCounter.text = fighter.counter;                if (BuffTile.isFighterBuffed(fighter)) {                    //TODO: Display buff icon                }			} else {				fInt.lblName.text = "No Fighter";                fInt.lblAttack.text = fInt.lblHealth.text = fInt.lblCounter.text = "0";			}		}        protected function moveFighterInfoIn(intObj:MovieClip):void {            const inYTop:Number = -83.0;            const inYBottom:Number = 26.7;            const moveTime:Number = 0.5;                        if (intObj is FighterInterface) TweenLite.to(intObj, moveTime, {y:inYTop});            else TweenLite.to(intObj, moveTime, {y:inYBottom});            intObj.visible = intObj.mouseEnabled = true;        }        protected function moveFighterInfoOut(intObj:MovieClip, instant:Boolean=false):void {            const outY:Number = -25;            const moveTime:Number = 0.5;            function makeInvisible():void {                intObj.visible = false;            }            if (!instant) TweenLite.to(intObj, moveTime, {y:outY, onComplete:makeInvisible});            else intObj.y = outY;            intObj.mouseEnabled = false;        }        public function addChatMessage(speaker:String, message:String, color:int):void {            if (!_chatPane.stage) {                setTimeout(addChatMessage, 1000, speaker, message, color);                return;            }            var chatArea:Sprite = _chatPane.source as Sprite;            var chatMessage:ChatMessage = new ChatMessage();            chatMessage.lbl.htmlText = "<font color='#" + color.toString(16)+"'>"+speaker+"</font>: "+message;            chatMessage.lbl.autoSize = TextFieldAutoSize.LEFT;            chatMessage.lbl.wordWrap = true;            chatMessage.y = chatArea.height;            chatArea.addChild(chatMessage);            _chatPane.verticalScrollPosition = chatArea.height;        }        public function playBoardIntro(boardInfo:Object):void {            var boardIntro:BoardIntro = new BoardIntro(boardInfo);            function boardIntroComplete():void {                dismissSuperScreen(boardIntro);                dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE));            }            GameEvent.addOneTimeEventListener(boardIntro, GameEvent.ACTION_COMPLETE, boardIntroComplete);            pushSuperScreen(boardIntro);        }        public function playTurnStartNotice(playerName:String, color:int):void {            const inTime:Number = 0.2;            const outTime:Number = 0.2;            const showDelay:Number = 1;            const inScale:Number = 0.5;            const outScale:Number = 1.5;            var turnStart:PlayerTurnStart = new PlayerTurnStart();            turnStart.lblPlayerName.text = playerName;            var colorCT:ColorTransform = turnStart.color.core.transform.colorTransform;            colorCT.color = color;            turnStart.color.core.transform.colorTransform = colorCT;            turnStart.x = DuelParty.stageWidth/2;            turnStart.y = DuelParty.stageHeight/2;			addChild(turnStart);            function turnStartIn():void {                TweenLite.to(turnStart, outTime, {delay:showDelay, scaleX:outScale, scaleY:outScale, alpha:0,                                                  ease:Quad.easeOut, onComplete:turnStartDone})            }            function turnStartDone():void {                removeChild(turnStart);                dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE));            }            turnStart.alpha = 0;            turnStart.scaleX = turnStart.scaleY = inScale;            TweenLite.to(turnStart, inTime, {scaleX:1, scaleY:1, alpha:1,                                             ease:Quad.easeIn, onComplete:turnStartIn});        }				public function playBattleNotice():void {            const textTransTime:Number = 0.2;            const bgTransTime:Number = 0.5;            const bgTransDelay:Number = 1;            const textInScale:Number = 1.5;            const textOutScale:Number = 0.5;			var battleAnim:BattleNotice = new BattleNotice();            battleAnim.bg.x = 0;            battleAnim.bg.y = DuelParty.stageHeight/2;            battleAnim.text.x = DuelParty.stageWidth/2;            battleAnim.text.y = DuelParty.stageHeight/2;			addChild(battleAnim);            var particleRender:DisplayObjectRenderer = new DisplayObjectRenderer();            var emitter:Emitter2D = battleAnimParticles();            particleRender.addEmitter(emitter);            particleRender.y = DuelParty.stageHeight/2;            battleAnim.addChild(particleRender);            battleAnim.setChildIndex(particleRender, 1);            function bgInDone():void {                TweenLite.to(battleAnim.bg, bgTransTime, {width:1, x:DuelParty.stageWidth,                                                          delay:bgTransDelay, onComplete:battleNoticeDone});                TweenLite.to(battleAnim.text, textTransTime, {alpha:0, delay:bgTransDelay,                                                          scaleX:textOutScale, scaleY:textOutScale});                TweenLite.to(particleRender, textTransTime, {alpha:0, delay:bgTransDelay});            }            function battleNoticeDone():void {                emitter.stop();                removeChild(battleAnim);                dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE));            }            battleAnim.text.alpha = 0;            battleAnim.text.scaleX = battleAnim.text.scaleY = textInScale;            particleRender.alpha = 0;            TweenLite.to(battleAnim.text, textTransTime, {alpha:1, scaleX:1, scaleY:1, onComplete:bgInDone});            TweenLite.to(battleAnim.bg, bgTransTime, {width:DuelParty.stageWidth*2, x:0});            TweenLite.to(particleRender, textTransTime, {alpha:1});		}        protected function battleAnimParticles():Emitter2D {            const particlesPerSecond:int = 20;            const particleZoneTop:Number = -30;            const particleZoneBottom:Number = 30;            const particleVelocity:Number = -1500;                        var emitter:Emitter2D = new Emitter2D();            emitter.counter = new Steady(particlesPerSecond);            emitter.addInitializer(new ImageClass(BattleAnimParticle));            emitter.addInitializer(new Position(new LineZone(new Point(DuelParty.stageWidth, particleZoneTop),                                                             new Point(DuelParty.stageWidth, particleZoneBottom))));            emitter.addInitializer(new Velocity(new PointZone(new Point(particleVelocity, 0))));            emitter.addAction(new Move());            emitter.addAction(new DeathZone(new RectangleZone(0, particleZoneTop, DuelParty.stageWidth,                                                             (particleZoneBottom - particleZoneTop)), true));            emitter.start();            emitter.runAhead(5);            return emitter;        }	}}