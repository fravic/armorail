package septenary.duelparty {

    public class MainMenuScreen extends Screen {

        protected static const _activeButtons:Array = new Array();

        public function MainMenuScreen(screenData:Object=null) {
            super();
            openLoginScreen();
        }

        protected function openLoginScreen():void {
            var loginScreen:MultiplayerLoginScreen = new MultiplayerLoginScreen();
            GameEvent.addOneTimeEventListener(loginScreen, GameEvent.ACTION_COMPLETE, loginComplete);
            pushSuperScreen(loginScreen);
        }

        protected function goToGameScreen(gameData:Object):void {
            DuelParty.getGame().switchState(GameScreen, gameData);
        }

        protected function loginComplete(e:GameEvent):void {
            dismissSuperScreen(e.target as Screen);

            var lobbyScreen:MultiplayerLobbyScreen = new MultiplayerLobbyScreen();
            GameEvent.addOneTimeEventListener(lobbyScreen, GameEvent.ACTION_COMPLETE, lobbyComplete);
            pushSuperScreen(lobbyScreen);
        }

        protected function lobbyComplete(e:GameEvent):void {
            dismissSuperScreen(e.target as Screen);

            if (e.data.action == MultiplayerLobbyScreen.LOGOUT) {
                openLoginScreen();
            } else if (e.data.action == MultiplayerLobbyScreen.START_GAME) {
                goToGameScreen(e.data.gameData);
            }
        }

        public override function gainedFocus():void {
            super.gainedFocus();
        }

        public override function lostFocus():void {
            super.lostFocus();
        }
    }
}