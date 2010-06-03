package septenary.duelparty {    import flash.display.MovieClip;    import flash.events.MouseEvent;    public class Focusable extends MovieClip {        public static const NO_FLASH:int = 0;        public static const SHORT_FLASH:int = 1;        public static const LONG_FLASH:int = 2;    	protected var _hasFocus:Boolean = false;        protected var _focusEnabled:Boolean = true;        protected var _flashLevel:int = LONG_FLASH;        public function get focusEnabled():Boolean {            return _focusEnabled;        }        public function set focusEnabled(value:Boolean):void {            _focusEnabled = value;        }        public function get hasFocus():Boolean {    		return _hasFocus;    	}        public function set flashLevel(value:int):void {            _flashLevel = value;        }        public function set delayAfterFlash(value:Boolean):void {        }        public function Focusable() {             }    	        public function gainedFocus():void {        	//Do the same thing as a mouse over            if (!_focusEnabled) return;			Utilities.assert(!_hasFocus, "Double focus gain on object " + this + "!");        	_hasFocus = true;        	dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OVER));        }        public function lostFocus():void {        	//Do the same thing as a mouse out        	if (!_focusEnabled) return;			Utilities.assert(_hasFocus, "Double focus loss on object " + this + "!");            _hasFocus = false;        	dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT));        }                public function focusAction():void {            if (!_focusEnabled) return;            function flashDone():void {                //Do the same thing as a mouse up                dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));            }            if (_flashLevel) {                Graphics.flashObject(this, flashDone, (_flashLevel == LONG_FLASH ? 200 : 0));            } else {                flashDone();            }        }    }}