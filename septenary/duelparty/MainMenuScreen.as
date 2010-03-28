package septenary.duelparty {
    import flash.events.MouseEvent;

    public class MainMenuScreen extends Screen {

        private static const PLAY:String = "Play";
        private static const CAMPAIGN:String = "Campaign";
        private static const SINGLE_MATCH:String = "Single Match";
        private static const ONLINE_MULTIPLAYER:String = "Online Multiplayer";

        protected static const _activeButtons:Array = new Array();

        public function MainMenuScreen(screenData:Object=null) {
            super();

            var menuButtons:Array = [PLAY, CAMPAIGN, SINGLE_MATCH, ONLINE_MULTIPLAYER];
            for (var i:int = 0; i < menuButtons.length; i++) {
                addButton(menuButtons[i]);    
            }
        }

        protected function addButton(text:String):void {
            const buttonSpacing:Number = 30;
            const buttonX:Number = 400;

            var newBtn:OptionButtonSmall = new OptionButtonSmall();
            newBtn.lbl.text = newBtn.data = text;

            newBtn.x = buttonX;
            newBtn.y = (_activeButtons.length + 1) * buttonSpacing;
            addChild(newBtn);

            _activeButtons.push(newBtn);
        }

        protected function buttonAction(e:MouseEvent):void {
            if (e.target.data == PLAY) {
                DuelParty.getGame().switchState(GameScreen, {});
            } else if (e.target.data == CAMPAIGN) {
                DuelParty.getGame().switchState(CampaignScreen, {});
            } else if (e.target.data == SINGLE_MATCH) {
            } else if (e.target.data == ONLINE_MULTIPLAYER) {
            }
        }

        public override function gainedFocus():void {
            super.gainedFocus();
            FocusManager.getManager().addGeneralFocusableListener(this, buttonAction);
        }

        public override function lostFocus():void {
            super.lostFocus();
            FocusManager.getManager().removeGeneralFocusableListener(this, buttonAction);
        }
    }
}