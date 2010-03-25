package septenary.duelparty {
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
            buttonMode = true;
            mouseChildren = false;
        }
    }
}