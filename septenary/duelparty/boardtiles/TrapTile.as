package septenary.duelparty.boardtiles {
    import septenary.duelparty.*;

    public class TrapTile extends BoardTile {

        protected var _owner:Player;

        public function TrapTile() {
            super();
        }

        public override function activate(player:Player, onPass:Boolean=false):void {
            super.activate(player);
            if (!_owner) {
                _owner = player;
                activateDone(player);
            } else {
                trapEffect(player);
            }
        }

        protected function trapEffect(player:Player):void {}
    }
}