package septenary.duelparty {

	public class PlayerData {
		
		protected var _display:String;
		protected var _name:String;
		protected var _inputSource:int;
		protected var _netID:int;       // Note: NetID '0' is RESERVED for the local player!
		protected var _color:int;
		protected var _rank:int;
		
		public function get display():String {
			return _display;
		}
		public function get name():String {
			return _name;
		}
		public function get inputSource():int {
			return _inputSource;
		}
		public function get netID():int {
			return _netID;
		}
		public function get color():int {
			return _color;
		}
		public function get rank():int {
			return _rank;
		}
		
		public function PlayerData(display:String, name:String, inputSource:int, netID:int, color:int, rank:int) {
			_display = display;
			_name = name;
			_inputSource = inputSource;
			_netID = netID;
			_color = color;
			_rank = rank;

            Utilities.assert(!(_netID == 0 && _inputSource != NetScreen.PLAYER_INPUT),
                             "NetID '0' is RESERVED for the local player!");
            Utilities.assert(!(_netID != 0 && _inputSource == NetScreen.PLAYER_INPUT),
                             "The local player MUST have a NetID of 0!");
		}

	}
}