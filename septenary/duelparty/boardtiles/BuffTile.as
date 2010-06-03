package septenary.duelparty.boardtiles {
    import septenary.duelparty.*;
    import septenary.duelparty.screens.*;

    public class BuffTile extends BoardTile {

        protected const HEALTH_MULTIPLIER:Number = 1.35;
        protected const ATTACK_MULTIPLIER:Number = 1.35;
        protected const COUNTER_MULTIPLIER:Number = 1.35;
        protected const MAX_BUFF_TURNS:int = 3;
        protected const MIN_BUFF_TURNS:int = 2;

        protected static var buffedFighters:Array = new Array();

        public static function isFighterBuffed(fighter:Fighter):Boolean {
            return (buffedFighters.indexOf(fighter) >= 0);    
        }

        public function BuffTile() {
            super();
        }

        public override function activate(player:Player, onPass:Boolean=false):void {
            super.activate(player);

            var foreOrRearGuard:int = Math.round(Math.random());
            var fighter:Fighter = foreOrRearGuard ?
                                  (fighterValid(player.foreGuard) ? player.foreGuard : player.rearGuard) :
                                  (fighterValid(player.rearGuard) ? player.rearGuard : player.foreGuard);

            if (!fighterValid(fighter)) {
                function dialogBoxDismissed(e:GameEvent):void {
                    activateDone(player);
                }
                Singleton.get(GameInterfaceScreen).showDialogBox(DialogScreen.DIALOG_ONLY,
                    {speaker:"Buff Tile", dialog:"This is a buff tile, but you have no fighters to buff!",
                     player:player},
                    dialogBoxDismissed);
            } else {
                var numTurns:int = Math.round(Math.random() * (MAX_BUFF_TURNS - MIN_BUFF_TURNS) + MIN_BUFF_TURNS);
                var statBuff:int = Math.floor(Math.random() * 3);

                var origStats:Object = {attack:fighter.attack, counter:fighter.counter, health:fighter.health,
                                        player:player};
                if (statBuff == 0) fighter.health = Math.floor(fighter.health * HEALTH_MULTIPLIER);
                if (statBuff == 1) fighter.attack = Math.floor(fighter.attack * ATTACK_MULTIPLIER);
                if (statBuff == 2) fighter.counter = Math.floor(fighter.counter * COUNTER_MULTIPLIER);

                var gameBoard:GameBoard = Singleton.get(GameBoard);
                gameBoard.scheduleTurnEvent(debuffFighter, {fighter:fighter,  origStats:origStats},
                                            gameBoard.playerTurnsFromNow(player, numTurns), true);
                BuffTile.buffedFighters.push(fighter);

                buffAnimation(fighter, player);
                Singleton.get(GameInterfaceScreen).updatePlayerInterface(player);
            }
        }

        protected function fighterValid(fighter:Fighter):Boolean {
            return (fighter != null && BuffTile.buffedFighters.indexOf(fighter) < 0);
        }

        protected function buffAnimation(fighter:Fighter, player:Player):void {
            buffDialog(new GameEvent(GameEvent.ACTION_COMPLETE, {player:player}));
        }

        protected function buffDialog(e:GameEvent):void {
            Singleton.get(GameInterfaceScreen).showDialogBox(DialogScreen.DIALOG_ONLY,
                    {speaker:"Buff Tile", dialog:"Your weapon has been buffed!",
                     player:e.data.player},
                    buffDialogDismissed);
        }

        protected function buffDialogDismissed(e:GameEvent):void {
            activateDone(e.data.dialogBoxData.player);    
        }

        protected function debuffFighter(buffData:Object):void {
            buffData.fighter.attack = buffData.origStats.attack;
        }
    }
}