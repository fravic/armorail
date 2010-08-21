package septenary.duelparty.screens {
    import septenary.duelparty.*;
    import septenary.duelparty.ui.*;

    import flash.events.MouseEvent;
    import flash.text.TextFormat;
    import flash.ui.Keyboard;

    public class MultiplayerLoginScreen extends Screen {

        private static const GUEST_LOGIN:String = "GuestLogin";
        private static const LOGIN:String = "Login";
        private static const REGISTER:String = "Register";

        public function MultiplayerLoginScreen(screenData:Object=null) {
            super();

            btnGuestLogin.init(btnGuestLogin.lbl, "Play as Guest", GUEST_LOGIN, Focusable.SHORT_FLASH);
            btnLogin.init(btnLogin.lbl, "Login", LOGIN, Focusable.SHORT_FLASH);
            btnRegister.init(btnRegister.lbl, "Register", REGISTER, Focusable.SHORT_FLASH);
            fldUsername.init(fldUsername.tF, fldUsername.tFPrompt, "Username", "Username");
            fldPassword.init(fldPassword.tF, fldPassword.tFPrompt, "Password", "Password", true);
        }

        protected function buttonAction(e:MouseEvent):void {
            var loadingScreen:NetLoadingScreen;

            if (e.target.data == GUEST_LOGIN) {
                loadingScreen = new NetLoadingScreen();
                loadingScreen.lbl.text = "Logging In As Guest";
                pushSuperScreen(loadingScreen);

                GameEvent.addOneTimeEventListener(Singleton.get(NetworkManager), GameEvent.ACTION_COMPLETE,
                                                  networkLoginHandler);
                Singleton.get(NetworkManager).loginAsGuest();
            } else if (e.target.data == LOGIN) {
                loginButtonPressed();
            } else if (e.target.data == REGISTER) {
                loadingScreen = new NetLoadingScreen();
                loadingScreen.lbl.text = "Registering As " + fldUsername.text;
                pushSuperScreen(loadingScreen);

                GameEvent.addOneTimeEventListener(Singleton.get(NetworkManager), GameEvent.ACTION_COMPLETE,
                                                  networkLoginHandler);
                Singleton.get(NetworkManager).register(fldUsername.text, fldPassword.text);
            }
        }

        protected function loginButtonPressed():void {
            var loadingScreen:NetLoadingScreen = new NetLoadingScreen();
            loadingScreen.lbl.text = "Logging In As " + fldUsername.tF.text;
            pushSuperScreen(loadingScreen);

            GameEvent.addOneTimeEventListener(Singleton.get(NetworkManager), GameEvent.ACTION_COMPLETE,
                                                  networkLoginHandler);
            Singleton.get(NetworkManager).login(fldUsername.text, fldPassword.text);
        }

        protected function networkLoginHandler(e:GameEvent):void {
            const errorColor:int = 0xFC8B8B;

            dismissAllSuperScreens();

            if (e.data.success) {
                dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE));
            } else {
                var format:TextFormat = tFErrorMessage.getTextFormat();
                tFErrorMessage.text = e.data.errorMessage;
                tFErrorMessage.setTextFormat(format);
                tFErrorMessage.textColor = errorColor;
            }
        }

        protected function enterButtonHandler():void {
            if (fldUsername.hasFocus || fldPassword.hasFocus) loginButtonPressed();
        }

        protected function tabButtonHandler():void {
            if (fldUsername.hasFocus) FocusManager.getManager().switchFocus(fldPassword);
            else if (fldPassword.hasFocus) FocusManager.getManager().switchFocus(fldUsername);
        }

        public override function gainedFocus():void {
            super.gainedFocus();
            getFocusManager().addFocusableListeners(btnGuestLogin, buttonAction);
            getFocusManager().addFocusableListeners(btnLogin, buttonAction);
            getFocusManager().addFocusableListeners(btnRegister, buttonAction);
            KeyActions.addEventListener(Keyboard.ENTER, enterButtonHandler);
            KeyActions.addEventListener(Keyboard.TAB, tabButtonHandler);
        }

		public override function lostFocus():void {
            super.lostFocus();
            getFocusManager().removeFocusableListeners(btnGuestLogin, buttonAction);
            getFocusManager().removeFocusableListeners(btnLogin, buttonAction);
            getFocusManager().removeFocusableListeners(btnRegister, buttonAction);
            KeyActions.removeEventListener(Keyboard.ENTER);
            KeyActions.removeEventListener(Keyboard.TAB);
		}
    }
}