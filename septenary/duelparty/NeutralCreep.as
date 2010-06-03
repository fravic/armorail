package septenary.duelparty {
    import septenary.duelparty.ui.*;

    import flash.geom.Point;
    import flash.display.Sprite;

    public class NeutralCreep extends Fighter implements IFightmaster {

        protected var _bountyPayable:Object = null;
        
        protected var _display:Sprite3D;

        public function setDisplay(value:Sprite3D):void {
            if (_display != null) removeChild(_display);
            _display = value;
            addChild(_display);
        }

        public function getDisplay():Sprite {
            return _display;
        }

        public function NeutralCreep() {
            super();
            _counter = 3;
            _health = 5;

            _attackBehaviour = BattleBehaviours.mortarAttackBehaviour;
            
            _movement.addEventListener(GameEvent.MOVEMENT_ARRIVED_AT_TILE, arrivedAtTile, false, 0, true);
            _movement.addEventListener(GameEvent.MOVEMENT_DEPARTED_TILE, departedTile, false, 0, true);
        }

        public function getForeGuard():Fighter {
            return this;
        }

        public function getRearGuard():Fighter {
            return this;
        }

        public function isFacingForward():Boolean {
            return true;
        }

        public function damage(damage:int, fromFront:Boolean, fromCounter:Boolean):void {
            damageFighter(damage);
        }

        public override function kill():void {
            _bountyPayable = {coins:_bountyCoins, creepKills:1};

            super.kill();
            _movement.kill();
		}

        public function payoutBounty():Object {
            return _bountyPayable;
        }

        public function teleportToTile(tile:BoardTile) {
            if (this.stage) {
                GUIAnimationFactory.createAndAddAnimation(GUIAnimationFactory.TELEPORT_OUT, new Point(this.x, this.y),
                                                         {tile:tile}, readyToTeleportHandler);
            } else {
                readyToTeleport(tile);
            }
        }

        protected function readyToTeleportHandler(e:GameEvent):void {
            readyToTeleport(e.data.tile);
        }

        protected function teleportMovement(tile:BoardTile):void {
            if (!this.stage) {
                Singleton.get(GameBoard).addChildToField(this);
            }
            _movement.teleportToTile(tile);
        }

        protected function readyToTeleport(tile:BoardTile):void {
            GUIAnimationFactory.createAndAddAnimation(GUIAnimationFactory.TELEPORT_IN, new Point(tile.x, tile.y),
                                                     {teleportCallback:teleportMovement, tile:tile}, null);
        }

        protected function arrivedAtTile(e:GameEvent):void {
            e.data.tile.arrive(this);
        }

        protected function departedTile(e:GameEvent):void {
            e.data.tile.depart(this);
        }
    }
}