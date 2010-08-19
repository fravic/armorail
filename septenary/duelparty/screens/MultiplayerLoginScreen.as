package septenary.duelparty.screens {
    import septenary.duelparty.*;
    import septenary.duelparty.ui.*;

    import flash.events.MouseEvent;

    public class MultiplayerLoginScreen extends Screen {

        private static const GUEST_LOGIN:String = "GuestLogin";
        private static const LOGIN:String = "Login";
        private static const REGISTER:String = "Register";

        public function MultiplayerLoginScreen(screenData:Object=null) {
            super();

            btnGuestLogin.lbl.text = "Play as Guest";
            btnGuestLogin.data = GUEST_LOGIN;
            btnGuestLogin.flashLevel = Focusable.SHORT_FLASH;

            btnLogin.lbl.text = "Login";
            btnLogin.data = LOGIN;
            btnLogin.flashLevel = Focusable.SHORT_FLASH;

            btnRegister.lbl.text = "Register";
            btnRegister.data = REGISTER;
            btnRegister.flashLevel = Focusable.SHORT_FLASH;

            FocusableTextField.createFocusableTextField(tFUsername);
            FocusableTextField.createFocusableTextField(tFPassword);
        }

        protected function buttonAction(e:MouseEvent):void {
            var loadingScreen:NetLoadingScreen = new NetLoadingScreen();

            if (e.target.data == GUEST_LOGIN) {
                loadingScreen.lbl.text = "Logging In As Guest";
                pushSuperScreen(loadingScreen);

                GameEvent.addOneTimeEventListener(Singleton.get(NetworkManager), GameEvent.ACTION_COMPLETE,
                                                  networkLoginHandler);
                Singleton.get(NetworkManager).loginAsGuest();
            } else if (e.target.data == LOGIN) {
                loadingScreen.lbl.text = "Logging In As " + tFUsername.text;
                pushSuperScreen(loadingScreen);

                GameEvent.addOneTimeEventListener(Singleton.get(NetworkManager), GameEvent.ACTION_COMPLETE,
                                                  networkLoginHandler);
                Singleton.get(NetworkManager).login(tFUsername.text, tFPassword.text);
            } else if (e.target.data == REGISTER) {
                loadingScreen.lbl.text = "Registering As " + tFUsername.text;
                pushSuperScreen(loadingScreen);

                GameEvent.addOneTimeEventListener(Singleton.get(NetworkManager), GameEvent.ACTION_COMPLETE,
                                                  networkLoginHandler);
                Singleton.get(NetworkManager).register(tFUsername.text, tFPassword.text);
            }
        }

        protected function networkLoginHandler(e:GameEvent):void {
            dismissAllSuperScreens();

            if (e.data.success) {
                dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE));
            } else {
                tFErrorMessage.text = e.data.errorMessage;
            }
        }

        public override function gainedFocus():void {
            super.gainedFocus();
            getFocusManager().addFocusableListeners(btnGuestLogin, buttonAction);
            getFocusManager().addFocusableListeners(btnLogin, buttonAction);
            getFocusManager().addFocusableListeners(btnRegister, buttonAction);
        }

		public override function lostFocus():void {
            super.lostFocus();
            getFocusManager().removeFocusableListeners(btnGuestLogin, buttonAction);
            getFocusManager().removeFocusableListeners(btnLogin, buttonAction);
            getFocusManager().removeFocusableListeners(btnRegister, buttonAction);
		}
    }
}