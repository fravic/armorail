package septenary.duelparty {
    import flash.utils.setTimeout;
    import flash.events.EventDispatcher;

    public class AIBehaviour extends EventDispatcher {

        //Dice roll
        public static const AI_DICE_ROLL:String = "DiceRoll";

        //Dialog box
        public static const AI_CLOSE_DIALOG:String = "CloseDialog";
        public static const AI_SHOP_YES:String = "ShopYes";
        public static const AI_SHOP_TIER:String = "ShopTier";

        //Fighter selection
        public static const AI_REPLACE_FRONT_WEAPON:String = "ReplaceFrontWeapon";
        public static const AI_REPLACE_BACK_WEAPON:String = "ReplaceBackWeapon";

        //Direction choice
        public static const AI_DIR_CHOICE:String = "DirChoice";

        protected var _player:Player;
        
        public function AIBehaviour(player:Player) {
            _player = player;
        }

        public function think(options:Array):void {
            const defaultThinkDelay:int = 1000;
            const defaultPts:Number = 0;

            Utilities.assert(options.length > 0, "Empty options array passed to AI!");

            var maxPts:Number = -Number.MAX_VALUE;
            var selection:Object, thinkDelay:int;
            for (var i:int = 0; i < options.length; i++) {
                Utilities.assert(options[i].type, "Invalid option type (" + options[i].type +") passed to AI!");
                var evaluation:Object = this["evaluate" + options[i].type](options[i]);
                if (evaluation.pts > maxPts) {
                    maxPts = evaluation.pts ? evaluation.pts : defaultPts;
                    thinkDelay = evaluation.thinkDelay ? evaluation.thinkDelay : defaultThinkDelay;
                    selection = options[i];
                }
            }

            function select():void {
                dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, {action:selection}));
            }
            setTimeout(select, thinkDelay);
        }

        protected function evaluateCloseDialog(option:Object):Object {
            var evaluation:Object = {pts:0, thinkDelay:1000};
            return evaluation;
        }

        protected function evaluateShopYes(option:Object):Object {
            var evaluation:Object = {pts:0, thinkDelay:1000};

            //TODO: Implement this...
            evaluation.pts = Math.random();

            return evaluation;
        }

        protected function evaluateShopTier(option:Object):Object {
            var evaluation:Object = {pts:0, thinkDelay:1000};

            //TODO: Implement this...
            evaluation.pts = Math.random();

            return evaluation;
        }

        protected function evaluateReplaceFrontWeapon(option:Object):Object {
            var evaluation:Object = {pts:0, thinkDelay:1000};

            //TODO: Implement this...
            evaluation.pts = Math.random();

            return evaluation;
        }

        protected function evaluateReplaceBackWeapon(option:Object):Object {
            var evaluation:Object = {pts:0, thinkDelay:1000};

            //TODO: Implement this...
            evaluation.pts = Math.random();

            return evaluation;
        }

        protected function evaluateDirChoice(option:Object):Object {
            var evaluation:Object = {pts:0, thinkDelay:1000};

            //TODO: Implement this...
            evaluation.pts = Math.random();

            return evaluation;
        }

        protected function evaluateDiceRoll(option:Object):Object {
            var evaluation:Object = {pts:0, thinkDelay:1000};

            //TODO: Implement this...
            evaluation.pts = Math.random();

            return evaluation;
        }
    }
}