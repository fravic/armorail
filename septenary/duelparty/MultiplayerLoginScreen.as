package septenary.duelparty {
    import flash.events.MouseEvent;

    public class MultiplayerLoginScreen extends Screen {

        private static const GUEST_LOGIN:String = "GuestLogin";

        public function MultiplayerLoginScreen(screenData:Object=null) {
            super();

            btnGuestLogin.lbl.text = "Play as Guest";
            btnGuestLogin.data = GUEST_LOGIN;
            btnGuestLogin.flashLevel = Focusable.SHORT_FLASH;
        }

        protected function buttonAction(e:MouseEvent):void {
            if (e.target.data == GUEST_LOGIN) {
                var loadingScreen:NetLoadingScreen = new NetLoadingScreen();
                loadingScreen.lbl.text = "Logging In";
                pushSuperScreen(loadingScreen);

                GameEvent.addOneTimeEventListener(NetworkManager.getNetworkManager(), GameEvent.ACTION_COMPLETE, 
                                                  networkLoginHandler);
                NetworkManager.getNetworkManager().loginAsGuest();          
            }
        }

        protected function networkLoginHandler(e:GameEvent):void {
            dismissAllSuperScreens();

            if (e.data.success) {
                dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE));
            } else {
                //TODO: Display login error message
            }
        }

        public override function gainedFocus():void {
            super.gainedFocus();
            getFocusManager().addGeneralFocusableListener(this, buttonAction);
        }

		public override function lostFocus():void {
            super.lostFocus();
            getFocusManager().removeGeneralFocusableListener(this, buttonAction);
		}
    }
}