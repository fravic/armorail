package septenary.duelparty.boardtiles {
    import septenary.duelparty.*;

    public class HappeningTile extends BoardTile {
        public function HappeningTile() {
            super();
        }

        public override function activate(player:Player, onPass:Boolean=false):void {
            super.activate(player);
            activateDone(player);
        }
    }
}