package septenary.duelparty {    import flash.display.Sprite;    import flash.display.MovieClip;    import flash.geom.Point;    import flash.utils.setTimeout;    import flash.utils.getQualifiedClassName;    import flash.utils.Dictionary;    import com.greensock.TweenLite;    import com.greensock.easing.Quad;    import org.flintparticles.common.counters.*;    import org.flintparticles.common.initializers.*;    import org.flintparticles.twoD.actions.*;    import org.flintparticles.twoD.emitters.Emitter2D;    import org.flintparticles.twoD.initializers.*;    import org.flintparticles.twoD.renderers.*;    import org.flintparticles.twoD.zones.*;    public class BattleScreen extends Screen {        protected static const AXIS_OF_EVIL:Number = 0;        protected static const ZOOM_SCALE:Number = 2.0;        protected var _battleManager:BattleManager;        protected var _fightContainer:Sprite = new Sprite();        protected var _rails:ContinuousRailway;        protected var _dupForActual:Dictionary = new Dictionary();        protected var _attackerDups:Object = new Object();        protected var _defenderDups:Object = new Object();        protected var _facingOppositeDirs:Boolean = true;        public function BattleScreen(battleManager:BattleManager) {            super();            _battleManager = battleManager;            GUIAnimationFactory.setActiveScreen(this);            this.visible = false;//            var particleRender:DisplayObjectRenderer = new DisplayObjectRenderer();//            var emitter:Emitter2D = battleAnimParticles();//            particleRender.addEmitter(emitter);//            addChild(particleRender);            var railsWidth:Number = Math.sqrt(DuelParty.stageWidth * DuelParty.stageWidth +                                              DuelParty.stageHeight * DuelParty.stageHeight) + 100;            _rails = new ContinuousRailway(railsWidth, 1, 28);            _rails.rotation = AXIS_OF_EVIL * 180/Math.PI;            _rails.x = DuelParty.stageWidth;            _rails.y = DuelParty.stageHeight/2 + 22;            _rails.scaleX = -1;            addChild(_rails);            addChild(_fightContainer);        }        public override function update():void {            _rails.update();            }        public function closeBattleScreen():void {                              GUIAnimationFactory.setActiveScreen(GameScreen.getGameScreen());            transitionFromBattleScreen();        }        public function setupBattle(attacker:Fightmaster, defender:Fightmaster, defenderOnFront:Boolean):void {            const transitionDelay:Number = 0.7 * 1000;            _facingOppositeDirs = defenderOnFront;            //Duplicate and add both the attacker and defender            duplicateMaster(attacker, true);            duplicateMaster(defender, false);            addDuplicateMaster(true);            addDuplicateMaster(false);            setTimeout(transitionFromGameBoard, transitionDelay);        }        protected function duplicateMaster(master:Fightmaster, asAttacker:Boolean):void {            var masterClassName:String = getQualifiedClassName(master.getDisplay());            var newMasterClassName:String = masterClassName + "Side";            var newMaster:Sprite = Utilities.classInstanceFromString(newMasterClassName);            newMaster.cacheAsBitmap = true;            newMaster.scaleX = newMaster.scaleY = ZOOM_SCALE;            if (asAttacker) _attackerDups.master = newMaster;            else _defenderDups.master = newMaster;            _dupForActual[master] = newMaster;            //Set rotating wheels to visible            //Utilities.setChildrenVisiblity(newMaster, true);            if (master.getForeGuard() != null) {                duplicateFighter(master.getForeGuard(), asAttacker, true);            }            if (master.getRearGuard() != null) {                duplicateFighter(master.getRearGuard(), asAttacker, false);            }        }        protected function duplicateFighter(fighter:Fighter, asAttacker:Boolean, inFront:Boolean):void {            var newFighter:Fighter = FighterFactory["new" + getQualifiedClassName(fighter)]();            newFighter.field = _fightContainer;            newFighter.scaleX = newFighter.scaleY = ZOOM_SCALE;            _dupForActual[fighter] = newFighter;            //Set rotating wheels            var wheelClassName:String = getQualifiedClassName(newFighter.wheels);            var newWheelClassName:String = wheelClassName.slice(0, -6) + "Side";            var newWheels:Sprite = Utilities.classInstanceFromString(newWheelClassName);            newWheels.x = newFighter.wheels.x;            newWheels.y = newFighter.wheels.y;            newWheels.cacheAsBitmap = true;            newFighter.wheels = newWheels;            var dups:Object = asAttacker ? _attackerDups : _defenderDups;            if (inFront) dups.foreGuard = newFighter;            else dups.rearGuard = newFighter;        }        protected function addDuplicateMaster(asAttacker:Boolean):void {            const masterAxisOffset:Number = asAttacker ? -330 : 330;            Utilities.assert(_attackerDups.master != null, "Attack master cannot be null!");            Utilities.assert(_defenderDups.master != null, "Defender master cannot be null!");            var dups:Object = asAttacker ? _attackerDups : _defenderDups;            dups.master.x = DuelParty.stageWidth/2 + masterAxisOffset * Math.cos(AXIS_OF_EVIL);            dups.master.y = DuelParty.stageHeight/2 + masterAxisOffset * Math.sin(AXIS_OF_EVIL);            //Face opposite direction?            if (!asAttacker && _facingOppositeDirs) {                dups.master.scaleX *= -1;                //Make wheels still face forward                for (var i:int = 0; i < dups.master.numChildren; i++) {                    if (dups.master.getChildAt(i) is MovieClip) {                        dups.master.getChildAt(i).scaleX *= -1;                    }                }            }            _fightContainer.addChild(dups.master);            if (dups.foreGuard) addDuplicateFighter(asAttacker, true);            if (dups.rearGuard) addDuplicateFighter(asAttacker, false);        }        protected function addDuplicateFighter(asAttacker:Boolean, inFront:Boolean):void {            const fighterAxisOffsetFromMaster:Number = 155;            var dups:Object = asAttacker ? _attackerDups : _defenderDups;            var fighter:Fighter = inFront ? dups.foreGuard : dups.rearGuard;            var rightOfMaster:Boolean;            if (asAttacker){                rightOfMaster = inFront;            } else {                rightOfMaster = (!_facingOppositeDirs) == inFront;            }            var xOffset:Number = fighterAxisOffsetFromMaster * Math.cos(AXIS_OF_EVIL);            var yOffset:Number = fighterAxisOffsetFromMaster * Math.sin(AXIS_OF_EVIL);            fighter.x =  (asAttacker ? _attackerDups.master.x : _defenderDups.master.x)                       + (rightOfMaster ? xOffset : -xOffset);            fighter.y =  (asAttacker ? _attackerDups.master.y : _defenderDups.master.y)                       + (rightOfMaster ? yOffset : -yOffset);            if (!asAttacker && _facingOppositeDirs) fighter.weapon.rotation = 180 + AXIS_OF_EVIL;            addChild(fighter);        }        protected function tweenGroupIn(group:Object, asAttacker:Boolean):void {            const startAxisOffset:Number = asAttacker ? -160 : 160;            const tweenTime:Number = 1;            function offsetGroupMember(member:Sprite):void {                member.x += startAxisOffset * Math.cos(AXIS_OF_EVIL);                member.y += startAxisOffset * Math.sin(AXIS_OF_EVIL);            }            var finalMasterPos:Point = new Point(group.master.x, group.master.y);            offsetGroupMember(group.master);            TweenLite.to(group.master, tweenTime, {x:finalMasterPos.x, y:finalMasterPos.y, ease:Quad.easeOut});            if (group.foreGuard != null) {                var finalForePos:Point = new Point(group.foreGuard.x, group.foreGuard.y);                offsetGroupMember(group.foreGuard);                TweenLite.to(group.foreGuard, tweenTime, {x:finalForePos.x, y:finalForePos.y, ease:Quad.easeOut});            }            if (group.rearGuard != null) {                var finalRearPos:Point = new Point(group.rearGuard.x, group.rearGuard.y);                offsetGroupMember(group.rearGuard);                TweenLite.to(group.foreGuard, tweenTime, {x:finalRearPos.x, y:finalRearPos.y, ease:Quad.easeOut});            }        }        protected function battleAnimParticles():Emitter2D {            const particlesPerSecond:int = 20;            const particleVelocity:Number = -1500;            var emitter:Emitter2D = new Emitter2D();            emitter.counter = new Steady(particlesPerSecond);            emitter.addInitializer(new ImageClass(BattleAnimParticle));            emitter.addInitializer(new Position(new LineZone(new Point(0, DuelParty.stageHeight),                                                             new Point(DuelParty.stageWidth, DuelParty.stageHeight))));            emitter.addInitializer(new Velocity(new PointZone(new Point(0, particleVelocity))));            emitter.addInitializer(new Rotation(Math.PI/2));            emitter.addAction(new Move());            emitter.addAction(new DeathZone(new RectangleZone(0, 0, DuelParty.stageWidth,                                                             DuelParty.stageHeight), true));            emitter.start();            emitter.runAhead(5);            return emitter;        }        protected function transitionFromGameBoard():void {            this.visible = false;            BlackTransition.getBlackTransition().setMasked(GameBoard.getGameBoard());            GameEvent.addOneTimeEventListener(BlackTransition.getBlackTransition(), GameEvent.SCREEN_TRANSITIONED,                                              transitionToBattleScreen);            GameEvent.addOneTimeEventListener(BlackTransition.getBlackTransition(), GameEvent.ACTION_COMPLETE,                                              battleSetupDone);            BlackTransition.getBlackTransition().transition(BlackTransition.TRANSITION_SHAPE_CIRCLE,                                                            BlackTransition.TRANSITION_SHAPE_CIRCLE, 10, 350);            GameInterface.getGameInterface().hidePlayerInterfaces();        }        protected function transitionToBattleScreen(e:GameEvent):void {            BlackTransition.getBlackTransition().setMasked(this);            this.visible = true;            GameBoard.getGameBoard().visible = false;            tweenGroupIn(_attackerDups, true);        }        protected function transitionFromBattleScreen():void {            BlackTransition.getBlackTransition().setMasked(this);            GameEvent.addOneTimeEventListener(BlackTransition.getBlackTransition(), GameEvent.SCREEN_TRANSITIONED,                                              transitionToGameBoard);            GameEvent.addOneTimeEventListener(BlackTransition.getBlackTransition(), GameEvent.ACTION_COMPLETE,                                              battleScreenClosed);            BlackTransition.getBlackTransition().transition(BlackTransition.TRANSITION_SHAPE_CIRCLE,                                                            BlackTransition.TRANSITION_SHAPE_CIRCLE, 10, 350);        }        protected function transitionToGameBoard(e:GameEvent):void {            BlackTransition.getBlackTransition().setMasked(GameBoard.getGameBoard());            GameInterface.getGameInterface().showPlayerInterfaces();            this.visible = false;            GameBoard.getGameBoard().visible = true;        }        protected function battleSetupDone(e:GameEvent=null):void {            dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE));        }        protected function battleScreenClosed(e:GameEvent=null):void {            dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE));        }        public function startFight(attacker:Fighter, defenseMaster:Fightmaster, counterStage:Boolean):void {            //TODO: Make it so that the fighters only attack when player commands them to            var defGroup:Object;            var masterDup:Sprite = _dupForActual[defenseMaster];            if (masterDup == _attackerDups.master) defGroup = _attackerDups;            else defGroup = _defenderDups;            fighterAttack(_dupForActual[attacker], defGroup, counterStage != _facingOppositeDirs);        }        protected function fighterAttack(dup:Fighter, targGroup:Object, defenderOnFront:Boolean):void {            GameEvent.addOneTimeEventListener(dup, GameEvent.ACTION_COMPLETE, fighterAttackEnded);			dup.attackAnim(targGroup, defenderOnFront);        }        protected function fighterAttackEnded(e:GameEvent=null):void {            dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE));        }        public override function addGUIAnimation(anim:Sprite, data:Object):void {            super.addGUIAnimation(anim, data);        }        public override function positionForGUIAnimation(position:Point, data:Object):Point {            //Convert real player/fighter coords to duplicate coords            var actual:Object = data.source;            var dup:Sprite = _dupForActual[actual];            Utilities.assert(dup != null, "Could not get duplicate fighter/player for GUI animation!");            return new Point(dup.x, dup.y);        }        public override function gainedFocus():void {			super.gainedFocus();		}				public override function lostFocus():void {			super.lostFocus();		}    }}