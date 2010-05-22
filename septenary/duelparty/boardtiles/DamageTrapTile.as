package septenary.duelparty.boardtiles {
    import septenary.duelparty.*;
    import septenary.duelparty.boardtiles.TrapTile;

    public class DamageTrapTile extends TrapTile {

        protected var _damage:int = 3;

        public function get damage():int {
            return _damage;
        }
        public function set damage(value:int):void {
            _damage = value;
        }

        public static function getParamFields():Array {
            return ["damage"];
        }

        public function DamageTrapTile() {
            super();
        }

        protected override function trapEffect(player:Player):void {
            var damageFront:Boolean;
            if (player.foreGuard && player.rearGuard) {
                var rand:int = Math.round(Math.random());
                damageFront = rand != 0;
            } else damageFront = (player.foreGuard != null);

            GameEvent.addOneTimeEventListener(player, GameEvent.ACTION_COMPLETE, damageDone);
            player.damage(_damage, damageFront, true);
        }

        protected function damageDone(e:GameEvent):void {
            GameEvent.addOneTimeEventListener(Singleton.get(GameBoard), GameEvent.GAME_NOT_OVER, gameNotOver);
            Singleton.get(GameBoard).checkForGameEnd();
        }

        protected function gameNotOver(e:GameEvent):void {
            activateDone(e.target as Player);
        }
    }
}