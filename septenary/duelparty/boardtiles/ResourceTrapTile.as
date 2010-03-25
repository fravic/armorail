package septenary.duelparty.boardtiles {
    import septenary.duelparty.*;
    import septenary.duelparty.boardtiles.TrapTile;

    public class ResourceTrapTile extends TrapTile {

        protected const BASE_COINS:int = 10;

        public function ResourceTrapTile() {
            super();
        }

        protected override function trapEffect(player:Player):void {
            function coinsPaid(e:GameEvent):void {
                activateDone(player);
            }
            function coinsTaken(e:GameEvent):void {
                GameEvent.addOneTimeEventListener(_owner, GameEvent.PLAYER_COINS_MODIFIED, coinsPaid);
                _owner.giveCoins(e.data.coinsTaken);
            }

            GameEvent.addOneTimeEventListener(player, GameEvent.PLAYER_COINS_MODIFIED, coinsTaken);
            player.takeCoins(BASE_COINS);
        }
    }
}