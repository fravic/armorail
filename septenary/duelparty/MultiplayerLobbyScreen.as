package septenary.duelparty {
    import flash.events.MouseEvent;

    import playerio.*;

    public class MultiplayerLobbyScreen extends Screen {

        public static const LOGOUT:String = "Logout";
        public static const START_GAME:String = "StartGame";

        private static const QUICKPLAY:String = "Quickplay";

        protected var _loadingScreen:NetLoadingScreen;

        protected var _playersInRoom:Array = new Array();
        protected var _localPlayerNum:int;

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

            GameEvent.addOneTimeEventListener(NetworkManager.getNetworkManager(), GameEvent.ACTION_COMPLETE,
                                              roomPollHandler);
            NetworkManager.getNetworkManager().pollRooms(QUICKPLAY);
        }

        protected function roomPollHandler(e:GameEvent):void {
            //Look for room to join
            for (var i:int = 0; i < e.data.rooms.length; i++) {
                var roomInfo:RoomInfo = e.data.rooms[i];
                if (roomInfo.onlineUsers < parseInt(roomInfo.data.numUsers)) {
                    NetworkManager.getNetworkManager().joinRoom(roomInfo);
                    return;
                }
            }

            //Couldn't find room, create own room
            NetworkManager.getNetworkManager().createRoom(2);
        }

        protected function netMessageHandler(e:GameEvent):void {
            if (e.data.type == NetworkMessage.JOIN) {
                NetworkManager.getNetworkManager().claimMessage(e.data.message);

                var name:String = NetworkManager.getNetworkManager().localPlayerName;
                var netID:String = NetworkManager.getNetworkManager().localPlayerNetID;

                _localPlayerNum = e.data.netData.numUsers;

                //Send out our player data so that the newly joined player knows who we are
                NetworkManager.getNetworkManager().sendMessage(NetworkMessage.PLAYER_DATA, {name:name,
                                          playerNetID:netID, playerNum:_localPlayerNum});
                
            } else if (e.data.type == NetworkMessage.PLAYER_DATA) {
                NetworkManager.getNetworkManager().claimMessage(e.data.message);

                //Don't double-add player datas
                for (var i:int = 0; i < _playersInRoom.length; i++) {
                    if (_playersInRoom[i].netID == e.data.netData.playerNetID) return;
                }

                var normPlayerNum:int = 0;
                for (i = 0; i < _playersInRoom.length; i++) {
                    if (_playersInRoom[i].playerNum < e.data.netData.playerNum) normPlayerNum++;
                    else _playersInRoom[i].playerNum++;
                }

                var inputSrc:int = e.data.netData.playerNetID ==
                                   NetworkManager.getNetworkManager().localPlayerNetID ?
                                   NetScreen.PLAYER_INPUT :
                                   NetScreen.NET_INPUT;
                var display:String = normPlayerNum ? "PlayerBlue" : "PlayerOrange";
                var color:int = normPlayerNum ? 0x0000FF : 0xFF6500;
                var newPlayerData:PlayerData = new PlayerData(normPlayerNum, display, e.data.netData.name,
                                                              inputSrc, e.data.netData.playerNetID, color, 0);
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
			NetworkManager.getNetworkManager().addEventListener(GameEvent.NETWORK_MESSAGE, netMessageHandler,
                                                                false, 0, true);
        }

        public override function screenWillExit():void {
			NetworkManager.getNetworkManager().removeEventListener(GameEvent.NETWORK_MESSAGE, netMessageHandler);
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