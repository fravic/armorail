package septenary.duelparty {
    import flash.text.TextField;

    public class FocusableTextField extends Focusable {

        protected var _textField:TextField;

        public static function createFocusableTextField(textField:TextField):void {
            textField.parent.addChild(new FocusableTextField(textField));
        }

        public function FocusableTextField(textField:TextField):void {
            super();

            _textField = textField;
            x = _textField.x + _textField.width/2;
            y = _textField.y + _textField.height/2;
        }

        public override function gainedFocus():void {
            super.gainedFocus();
            DuelParty.stage.focus = _textField;
            _textField.text = "";
        }

        public override function lostFocus():void {
            DuelParty.stage.focus = null;
            super.lostFocus();    
        }
    }
}