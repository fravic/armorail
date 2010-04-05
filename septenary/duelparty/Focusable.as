package septenary.duelparty {    import flash.display.MovieClip;    import flash.events.MouseEvent;    public class Focusable extends MovieClip {    	    	protected var _hasFocus:Boolean = false;        protected var _focusEnabled:Boolean = true;        protected var _flashOnSelect:Boolean = true;        public function get focusEnabled():Boolean {            return _focusEnabled;        }        public function set focusEnabled(value:Boolean):void {            _focusEnabled = value;        }        public function get hasFocus():Boolean {    		return _hasFocus;    	}        public function set flashOnSelect(value:Boolean):void {            _flashOnSelect = value;        }        public function Focusable() {             }    	        public function gainedFocus():void {        	//Do the same thing as a mouse over            if (!_focusEnabled) return;			Utilities.assert(!_hasFocus, "Double focus gain on object " + this + "!");        	_hasFocus = true;        	dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OVER));        }        public function lostFocus():void {        	//Do the same thing as a mouse out        	if (!_focusEnabled) return;			Utilities.assert(_hasFocus, "Double focus loss on object " + this + "!");            _hasFocus = false;        	dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT));        }                public function focusAction():void {            if (!_focusEnabled) return;            function flashDone():void {                //Do the same thing as a mouse down                dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));            }            if (_flashOnSelect) {                Utilities.flashObject(this, flashDone);            } else {                flashDone();            }        }    }}