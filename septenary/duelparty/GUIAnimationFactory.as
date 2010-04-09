package septenary.duelparty {
    import com.greensock.TweenLite;
    import com.greensock.easing.Bounce;
    import flash.display.MovieClip;
    import flash.geom.Point;
    import fl.motion.easing.Linear;

    public class GUIAnimationFactory {

        public static const COINS_GAIN_NOTIFICATION:String = "CoinsGainNotification";
        public static const COINS_LOSS_NOTIFICATION:String = "CoinsLossNotification";
        public static const DAMAGE_NOTIFICATION:String = "DamageNotification";
        public static const HEALING_NOTIFICATION:String = "HealingNotification";
        public static const BOOST_NOTIFICATION:String = "BoostNotification";
        public static const MOVES_LEFT_COUNTER:String = "MovesLeftCounter";
        public static const TELEPORT_OUT:String = "TeleportOut";
        public static const TELEPORT_IN:String = "TeleportIn";

        protected static var _activeScreen:Screen;

        public static function setActiveScreen(screen:Screen):void {
            _activeScreen = screen;
        }

        public static function createAnimation(type:String, position:Point, data:Object, callback:Function):MovieClip {
            var anim:MovieClip = GUIAnimationFactory["create" + type](position, data);
            anim.x = position.x;
            anim.y = position.y;
            if (callback != null) GameEvent.addOneTimeEventListener(anim, GameEvent.ACTION_COMPLETE, callback);
            return anim;
        }

        public static function createAndAddAnimation(type:String, position:Point, data:Object,
                                                     callback:Function):MovieClip {
            var anim:MovieClip = createAnimation(type, position, data, callback);
            _activeScreen.addGUIAnimation(anim);
            return anim;
        }

        protected static function createDamageNotification(position:Point, data:Object):MovieClip {
            const riseDuration:Number = 1;
            const riseDist:Number = 40;
            const fadeDuration:Number = 0.2;
            const fadeDist:Number = 8;

            var anim:DamageIndicator = new DamageIndicator();
            anim.lblDamage.text = "-"+data.damage;

            function fadedOut():void {
                anim.parent.removeChild(anim);
                anim.dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE));
            }
            function fadeOut():void {
                TweenLite.to(anim, fadeDuration, {alpha:0, y:(position.y - riseDist - fadeDist),
                                                  ease:Linear.easeNone, onComplete:fadedOut});
            }
            TweenLite.to(anim, riseDuration, {y:(position.y - riseDist), ease:Linear.easeNone, onComplete:fadeOut});
            return anim;
        }

        protected static function createHealingNotification(position:Point, data:Object):MovieClip {
            const fallDuration:Number = 1;
            const fallDist:Number = 40;
            const fadeDuration:Number = 0.2;
            const fadeDist:Number = 8;

            var anim:DamageIndicator = new DamageIndicator();
            anim.lblDamage.text = "+"+data.healing;

            function fadedOut():void {
                anim.parent.removeChild(anim);
                anim.dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE));
            }
            function fadeOut():void {
                TweenLite.to(anim, fadeDuration, {alpha:0, y:(position.y + fallDist + fadeDist),
                                                  ease:Linear.easeNone, onComplete:fadedOut});
            }
            TweenLite.to(anim, fallDuration, {y:(position.y + fallDist), ease:Linear.easeNone, onComplete:fadeOut});
            position.y -= fallDist;
            return anim;
        }

        protected static function createCoinsGainNotification(position:Point, data:Object):MovieClip {
            const fallDuration:Number = 1;
            const fallDist:Number = 40;
            const fadeDuration:Number = 0.2;
            const fadeDist:Number = 8;

            var anim:CoinsIndicator = new CoinsIndicator();
            anim.lblCoins.text = "+"+data.coinsGiven;

            function fadedOut():void {
                anim.parent.removeChild(anim);
                anim.dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, data));
            }
            function fadeOut():void {
                TweenLite.to(anim, fadeDuration, {alpha:0, y:(position.y + fallDist + fadeDist),
                                                  ease:Linear.easeNone, onComplete:fadedOut});
            }
            TweenLite.to(anim, fallDuration, {y:(position.y + fallDist), ease:Linear.easeNone, onComplete:fadeOut});
            position.y -= fallDist;
            return anim;
        }

        protected static function createCoinsLossNotification(position:Point, data:Object):MovieClip {
            const riseDuration:Number = 1;
            const riseDist:Number = 40;
            const fadeDuration:Number = 0.2;
            const fadeDist:Number = 8;

            var anim:CoinsIndicator = new CoinsIndicator();
            anim.lblCoins.text = "-"+data.coinsTaken;

            function fadedOut():void {
                anim.parent.removeChild(anim);
                anim.dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, data));
            }
            function fadeOut():void {
                TweenLite.to(anim, fadeDuration, {alpha:0, y:(position.y - riseDist - fadeDist),
                                                  ease:Linear.easeNone, onComplete:fadedOut});
            }
            TweenLite.to(anim, riseDuration, {y:(position.y - riseDist), ease:Linear.easeNone, onComplete:fadeOut});
            return anim;
        }

        protected static function createMovesLeftCounter(position:Point, data:Object):MovieClip {
            const scaleIn:Number = 3.5;
            const scaleDuration:Number = 0.3;

            var anim:MovesLeftCounter = new MovesLeftCounter();
            anim.scaleX = anim.scaleY = scaleIn;
            anim.lblMovesLeft.text = data.movesLeft.toString();
            TweenLite.to(anim, scaleDuration, {scaleX:1, scaleY:1, ease:Bounce.easeOut});
            return anim;
        }

        protected static function createTeleportOut(position:Point, data:Object):MovieClip {
            var anim:TeleportOutAnim = new TeleportOutAnim();
            function animComplete():void {
                anim.parent.removeChild(anim);
                anim.dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, data));
            }
            GameEvent.addAnimFrameListener(anim, animComplete);
            return anim;
        }

        protected static function createTeleportIn(position:Point, data:Object):MovieClip {
            var anim:TeleportInAnim = new TeleportInAnim();
            function doTeleport(e:GameEvent):void {
                data.teleportCallback(data.tile);
            }
            function animComplete():void {
                anim.parent.removeChild(anim);
                anim.dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, data));
            }
            GameEvent.addAnimFrameListener(anim, animComplete);
            GameEvent.addAnimFrameListener(anim, doTeleport, 20);
            return anim;
        }

        protected static function createBoostNotification(position:Point, data:Object):MovieClip {
            const scaleIn:Number = 3.5;
            const scaleDuration:Number = 0.3;

            var anim:MovesLeftCounter = new MovesLeftCounter();
            function animComplete():void {
                anim.parent.removeChild(anim);
                anim.dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, data));
            }

            anim.scaleX = anim.scaleY = scaleIn;
            anim.lblMovesLeft.text = "+"+data.boostAmount;
            TweenLite.to(anim, scaleDuration, {scaleX:1, scaleY:1, ease:Bounce.easeOut, onComplete:animComplete});
            return anim;
        }
    }
}