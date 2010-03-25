package septenary.duelparty.boardtiles {
    import septenary.duelparty.*;

    public class NeutralCreepSpawnTile extends BoardTile {

        protected const CREEP_SPAWN_INTERVAL:int = 0;

        protected var _neutralCreep:NeutralCreep;
        protected var _nextCreepSpawn:int;

        public function NeutralCreepSpawnTile() {
            _reducesMoveCount = false;
            _nextCreepSpawn = Math.round(Math.random() * CREEP_SPAWN_INTERVAL);

            GameBoard.getGameBoard().addEventListener(GameEvent.START_TURN, attemptSpawnNewCreep);
        }

        public override function activate(player:Player, onPass:Boolean=false):void {
            super.activate(player);
            activateDone(player);
        }

        public function attemptSpawnNewCreep(e:GameEvent):void {
            if (_neutralCreep != null) return;
            _nextCreepSpawn--;
            if (_nextCreepSpawn <= 0) {
                _neutralCreep = new NeutralCreep();
                _neutralCreep.addEventListener(GameEvent.FIGHTER_DIED, creepKilled, false, 0, true);
                _neutralCreep.teleportToTile(this);
            }
        }

        protected function creepKilled(e:GameEvent):void {
            GameBoard.getGameBoard().removeChildFromField(_neutralCreep);
            _neutralCreep = null;
            _nextCreepSpawn = CREEP_SPAWN_INTERVAL;
        }
    }
}