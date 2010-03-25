package septenary.duelparty.boardtiles {
    import septenary.duelparty.*;

    public class BankTile extends BoardTile {

        protected const BASE_COIN:int = 5;

        protected var _coinGather:int = BASE_COIN;
        protected var _coinStore:int = 0;


        public function get coinGather():int {
            return _coinGather;
        }
        public function set coinGather(value:int):void {
            _coinGather = value;
        }
        public function get coinStore():int {
            return _coinStore;
        }
        public function set coinStore(value:int):void {
            _coinStore = value;
        }

        public static function getParamFields():Array {
            return ["coinGather", "coinStore"];
        }

        public function BankTile() {
            super();
        }

        protected function collectMoney(player:Player):void {
            GameEvent.addOneTimeEventListener(player, GameEvent.PLAYER_COINS_MODIFIED, moneyCollected);
            player.takeCoins(_coinGather);
        }

        protected function moneyCollected(e:GameEvent):void {
            _coinStore += e.data.coinsTaken;
            activateDone(e.target as Player);
        }

        protected function payMoney(player:Player):void {
            GameEvent.addOneTimeEventListener(player, GameEvent.PLAYER_COINS_MODIFIED, moneyPaid);
            player.giveCoins(_coinStore);
            _coinStore = 0;
        }

        protected function moneyPaid(e:GameEvent):void {
            activateDone(e.target as Player);
        }

        public override function activate(player:Player, onPass:Boolean=false):void {
            super.activate(player);

            if (onPass) {
                collectMoney(player);
            } else {
                payMoney(player);
            }
        }
    }
}