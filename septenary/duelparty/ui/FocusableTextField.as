package septenary.duelparty.ui {
    import septenary.duelparty.*;

    import flash.text.TextField;
    import flash.events.FocusEvent;
    import flash.events.Event;

    public class FocusableTextField extends Focusable {

        protected var _textField:TextField;
        protected var _prompt:String;
        protected var _password:Boolean = false;

        public static function createFocusableTextField(textField:TextField, prompt:String=null):void {
            textField.parent.addChild(new FocusableTextField(textField, prompt));
        }

        public function FocusableTextField(textField:TextField, prompt:String):void {
            super();

            _textField = textField;
            x = _textField.x + _textField.width/2;
            y = _textField.y + _textField.height/2;

            if (_textField.displayAsPassword) {
                _textField.displayAsPassword = false;
                _password = true;
            }

            if (prompt != null) {
                _textField.text = prompt;
                _prompt = prompt;
            } else {
                _prompt = _textField.text;
            }

            _textField.addEventListener(FocusEvent.FOCUS_IN, onGainedFocus, false, 0, true);
            _textField.addEventListener(FocusEvent.FOCUS_OUT, onLostFocus, false, 0, true);
            _textField.addEventListener(Event.REMOVED_FROM_STAGE, tFRemovedFromStage, false, 0, true);
        }

        protected function tFRemovedFromStage(e:Event):void {
            _textField.removeEventListener(FocusEvent.FOCUS_IN, onGainedFocus);
            _textField.removeEventListener(FocusEvent.FOCUS_OUT, onLostFocus);
            _textField.removeEventListener(Event.REMOVED_FROM_STAGE, tFRemovedFromStage);
        }

        public override function gainedFocus():void {
            super.gainedFocus();
            DuelParty.stage.focus = _textField;
            onGainedFocus();
        }

        public override function lostFocus():void {
            DuelParty.stage.focus = null;
            super.lostFocus();
            onLostFocus();
        }

        protected function onGainedFocus(e:FocusEvent=null):void {
            if (_textField.text == _prompt) {
                _textField.text = "";
                _textField.displayAsPassword = _password;
            }
        }

        protected function onLostFocus(e:FocusEvent=null):void {
            if (_textField.text == "") {
                _textField.text = _prompt;
                _textField.displayAsPassword = false;
            }
        }
    }
}