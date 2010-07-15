package septenary.duelparty.screens {
    import septenary.duelparty.*;

    import flash.events.MouseEvent;

    import playerio.*;

    public class MultiplayerLobbyScreen extends Screen {

        //Actions
        public static const LOGOUT:String = "Logout";
        public static const START_GAME:String = "StartGame";

        //Button text
        private static const QUICKPLAY:String = "Quickplay";

        protected var _loadingScreen:NetLoadingScreen;

        protected var _playersInRoom:Array = new Array();

        public function MultiplayerLobbyScreen(screenData:Object=null) {
            super();

            btnQuickplay.lbl.text = "Quickplay";
            btnQuickplay.data = QUICKPLAY;
            btnQuickplay.flashLevel = Focusable.SHORT_FLASH;
        }

        protected function buttonAction(e:MouseEvent):void {
            if (e.target.data == QUICKPLAY) {
                startQuickplay();
            }
        }

        protected function startQuickplay():void {
            _loadingScreen = new NetLoadingScreen();
            _loadingScreen.lbl.text = "Searching For Players... 0/2";
            pushSuperScreen(_loadingScreen);

            GameEvent.addOneTimeEventListener(Singleton.get(NetworkManager), GameEvent.ACTION_COMPLETE,
                                              roomPollHandler);
            Singleton.get(NetworkManager).pollRooms(QUICKPLAY);
        }

        protected function roomPollHandler(e:GameEvent):void {
            //Look for room to join
            for (var i:int = 0; i < e.data.rooms.length; i++) {
                var roomInfo:RoomInfo = e.data.rooms[i];
                if (roomInfo.onlineUsers < parseInt(roomInfo.data.numUsers)) {
                    Singleton.get(NetworkManager).joinRoom(roomInfo, "NewPlayer");
                    return;
                }
            }

            //Couldn't find room, create own room
            Singleton.get(NetworkManager).createRoom(2);
        }

        protected function netMessageHandler(e:GameEvent):void {
            if (e.data.type == NetworkMessage.JOIN) {
                Singleton.get(NetworkManager).claimMessage(e.data.message);

                //Construct new player data
                var inputSrc:int = e.data.vars.playerNetID ==
                                   Singleton.get(NetworkManager).localPlayerNetID ?
                                   NetScreen.PLAYER_INPUT :
                                   NetScreen.NET_INPUT;
                var display:String = e.data.vars.playerNum ? "PlayerBlue" : "PlayerOrange";
                var color:int = e.data.vars.playerNum ? 0x0000FF : 0xFF6500;
                var newPlayerData:PlayerData = new PlayerData(e.data.vars.playerNum, display, e.data.vars.name,
                                                              inputSrc, e.data.vars.playerNetID, color, 0);
                _playersInRoom.push(newPlayerData);

                _loadingScreen.lbl.text = _loadingScreen.lbl.text = "Searching For Players... "
                                          + _playersInRoom.length + "/2";

                if (_playersInRoom.length >= 2) {
                    dismissAllSuperScreens();

                    var sortedPlayers:Array = _playersInRoom.sortOn("playerNum");
                    dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, {action:START_GAME,
                                                gameData:{boardType:"default", playerDatas:sortedPlayers}}));
                }
            }
        }

        public override function screenWillEnter():void {
			Singleton.get(NetworkManager).addEventListener(GameEvent.NETWORK_MESSAGE, netMessageHandler,
                                                                false, 0, true);
        }

        public override function screenWillExit():void {
			Singleton.get(NetworkManager).removeEventListener(GameEvent.NETWORK_MESSAGE, netMessageHandler);
        }

        public override function gainedFocus():void {
            super.gainedFocus();
            getFocusManager().addGeneralFocusableListener(this, buttonAction);
        }

        public override function lostFocus():void {
            super.lostFocus();
            getFocusManager().removeGeneralFocusableListener(this, buttonAction);
        }
    }
}