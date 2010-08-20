package septenary.duelparty {

	public class PlayerData {

        public var playerNum:int;
		public var display:String;
		public var name:String;
		public var inputSource:int;
		public var netID:String;
        public var databaseID:String;
		public var color:int;
		public var rating:int;
        public var experience:int;
        public var numWins:int;
        public var numLosses:int;

        public function PlayerData() {
            //Set default values.  THESE VALUES WILL BE USED IN GAME TO SETUP A NEW PLAYER!
            playerNum =    0;
			display =      "PlayerBlue";
			name =         "Guest";
			inputSource =  NetScreen.PLAYER_INPUT;
			netID =        "Guest";
            databaseID =   "Guest";
			color =        0xFF0000;
			rating =       0;
            numWins =      0;
            numLosses =    0;
            experience =   0;
		}

        public function getSavableObject():Object {
            return {name:name, rating:rating, numWins:numWins, numLosses:numLosses, experience:experience};
        }

        public function loadFromDatabase(database:Object):void {
            name =         nn(database.name, name);
            rating =       nn(database.rating, rating);
            numWins =      nn(database.numWins, numWins);
            numLosses =    nn(database.numLosses, numLosses);
            experience =   nn(database.experience, experience);
        }

        protected function nn(value:*, defaultVal:*):* {
            return value != null ? value : defaultVal;
        }
    }
}