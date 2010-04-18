package septenary.duelparty {

	public class PlayerData {

        protected var _playerNum:int;
		protected var _display:String;
		protected var _name:String;
		protected var _inputSource:int;
		protected var _netID:String;
		protected var _color:int;
		protected var _rank:int;

        public function get playerNum():int {
            return _playerNum;
        }
        public function get display():String {
			return _display;
		}
		public function get name():String {
			return _name;
		}
		public function get inputSource():int {
			return _inputSource;
		}
		public function get netID():String {
			return _netID;
		}
		public function get color():int {
			return _color;
		}
		public function get rank():int {
			return _rank;
		}
		
		public function PlayerData(num:int, display:String, name:String, inputSource:int, netID:String, color:int,
                                   rank:int) {
            _playerNum = num;
			_display = display;
			_name = name;
			_inputSource = inputSource;
			_netID = netID;
			_color = color;
			_rank = rank;
		}

	}
}