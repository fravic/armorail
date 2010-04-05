package septenary.duelparty {
    import septenary.duelparty.boardtiles.*;

    /*
        Q:  WHAT IS THIS CLASS FOR?!
        A:  BoardTile classes are not directly referenced anywhere in the program.
            We must include references here so that they are recognized by the compiler.
     */

    public class ClassIncludes {

        private static var BANK_TILE:BankTile;
        private static var BASE_TILE:BaseTile;
        private static var BOOST_TILE:BoostTile;
        private static var BUFF_TILE:BuffTile;
        private static var DAMAGE_TRAP_TILE:DamageTrapTile;
        private static var GATE_TILE:GateTile;
        private static var HAPPENING_TILE:HappeningTile;
        private static var HEALING_TILE:HealingTile;
        private static var MINE_TILE:MineTile;
        private static var NEG_MINE_TILE:NegMineTile;
        private static var NEUTRAL_CREEP_SPAWN_TILE:NeutralCreepSpawnTile;
        private static var NODE_TILE:NodeTile;
        private static var PASS_SWAP_TILE:PassSwapTile;
        private static var RESOURCE_TRAP_TILE:ResourceTrapTile;
        private static var REVERSAL_TILE:ReversalTile;
        private static var REVOLVING_DOOR_TILE:RevolvingDoorTile;
        private static var TELEPORTATION_TILE:TeleportationTile;
        private static var TRAP_TILE:TrapTile;
        
    }
}