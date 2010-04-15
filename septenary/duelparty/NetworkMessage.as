package septenary.duelparty {
    import flash.utils.Dictionary;
    import flash.utils.ByteArray;

    import playerio.*;

    public class NetworkMessage {

        //Message types defined by Player.IO
        public static const JOIN:String = "Join";

        //Game-specific message types
        public static const DICE_ROLL:String = "DiceRoll";
        public static const DIR_SELECT:String = "DirSelect";

        private static var _typeArgsDictionary:Dictionary = new Dictionary();

        protected var _data:Object;
        protected var _serializedData:Array;

        public static function registerMessageTypeArgs(type:String, args:Object):void {
            if (_typeArgsDictionary[type] == null) _typeArgsDictionary[type] = new Object();
            var i:int = 0;
            for (var s:String in args) {
                _typeArgsDictionary[type][s] = {index:i, type:args[s]};
                i++;
            }
        }

        public function get data():Object {
            return _data;
        }

        public function get serializedData():Array {
            return _serializedData;
        }

        public function NetworkMessage(type:String, data:Object=null) {
            Utilities.assert(_typeArgsDictionary[type] != null, 
                            "Types have not been registered for network message type '"+type+"'!");

            if (data != null) {
                serializeMessage(type, data);
            }
        }

        public function serializeMessage(type:String, data:Object):void {
            _data = data;
            _serializedData = new Array();

            for (var s:String in _typeArgsDictionary[type]) {
                var index:int = _typeArgsDictionary[type][s].index;

                if (data[s] != null) {
                    Utilities.assert(data[s] is _typeArgsDictionary[type][s].type,
                                 "Mismatched types for entry '"+s+"' in message type '"+type+"'!");
                    _serializedData[index] = data[s];
                } else {
                    _serializedData[index] = defaultValueForType(_typeArgsDictionary[type][s].type);
                }
            }
        }

        public function deserializeMessage(m:Message):void {
            _data = new Object();
            _serializedData = new Array();
            
            for (var s:String in _typeArgsDictionary[m.type]) {
                var index:int = _typeArgsDictionary[m.type][s].index;
                var type:Class = _typeArgsDictionary[m.type][s].type;
                _data[s] = valueAtMessageIndexForType(m, type, index);
                _serializedData[index] = _data[s];
            }
        }

        protected function valueAtMessageIndexForType(m:Message, type:Class, index:int):* {
            if (type == int) {
                return m.getInt(index);
            } else if (type == Number ) {
                return m.getNumber(index);
            } else if (type == uint) {
                return m.getUInt(index);
            } else if (type == String) {
                return m.getString(index);
            } else if (type == Boolean) {
                return m.getBoolean(index);
            } else if (type == ByteArray) {
                return m.getByteArray(index);
            }
        }

        protected function defaultValueForType(type:Class):* {
            if (type == int || type == Number || type == uint) {
                return 0;
            } else if (type == String) {
                return "";
            } else if (type == Boolean) {
                return false;
            } else if (type == ByteArray) {
                return null;
            }
            return null;
        }
    }
}