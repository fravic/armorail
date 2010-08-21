package septenary.duelparty.ui {
    import septenary.duelparty.Focusable;

    import flash.text.TextField;

    public class DataButton extends Focusable {

        protected var _data:*;


        public function get data():* {
            return _data;
        }
        public function set data(value:*):void {
            _data = value;
        }

        public function DataButton(data:*=null) {
            super();
            _data = data;
            mouseChildren = false;
        }

        public function init(tFLabel:TextField, label:String, data:*=null, flash:int=Focusable.LONG_FLASH):void {
            tFLabel.text = label;
            _data = data;
            flashLevel = flash;
        }
    }
}