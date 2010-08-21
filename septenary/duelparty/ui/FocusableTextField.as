package septenary.duelparty.ui {
    import septenary.duelparty.*;

    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.events.FocusEvent;
    import flash.events.Event;
    import flash.display.BlendMode;

    public class FocusableTextField extends Focusable {

        protected var _textField:TextField;
        protected var _prompt:String;
        protected var _password:Boolean = false;

        public static function createFocusableTextField(textField:TextField, prompt:String=null):void {
            var fld:FocusableTextField = new FocusableTextField();
            fld.init(textField);
            fld.x = textField.x + textField.width/2;
            fld.y = textField.y + textField.height/2;
            textField.parent.addChild(fld);
        }

        public function init(textField:TextField, promptField:TextField=null, majorPrompt:String="",
            minorPrompt:String="", displayAsPassword:Boolean=false):void {
            _textField = textField;
            _password = displayAsPassword;

            flashLevel = Focusable.NO_FLASH;

            if (majorPrompt != null) {
                _textField.text = majorPrompt;
                _prompt = majorPrompt;
            } else {
                _prompt = _textField.text;
            }

            if (promptField != null) {
                var format:TextFormat = promptField.getTextFormat();
                promptField.text = minorPrompt;
                promptField.setTextFormat(format);
                promptField.blendMode = BlendMode.LAYER;
                promptField.alpha = .30;
            }

            _textField.addEventListener(FocusEvent.FOCUS_IN, onGainedFocus, false, 0, true);
            _textField.addEventListener(FocusEvent.FOCUS_OUT, onLostFocus, false, 0, true);
            _textField.addEventListener(Event.REMOVED_FROM_STAGE, tFRemovedFromStage, false, 0, true);
        }

        public function get text():String {
            return _textField.text;    
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