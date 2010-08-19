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
        private static const HOST_GAME:String = "Host a Game";
        private static const JOIN_GAME:String = "Join Game";

        protected var _loadingScreen:NetLoadingScreen;

        public function MultiplayerLobbyScreen(screenData:Object=null) {
            super();

            btnQuickplay.lbl.text = QUICKPLAY;
            btnQuickplay.data = QUICKPLAY;
            btnQuickplay.flashLevel = Focusable.SHORT_FLASH;

            displayUserInfo();
        }

        protected function displayUserInfo():void {
            var userInfo:PlayerData = Singleton.get(NetworkManager).localPlayerData;
            tFUsername.text = userInfo.name;
            tFWins.text = userInfo.numWins.toString();
            tFLosses.text = userInfo.numLosses.toString();
            tFRating.text = userInfo.rating.toString();
            tFExperience.text = userInfo.experience.toString();
        }

        protected function buttonAction(e:MouseEvent):void {
            if (e.target.data == QUICKPLAY) {
                startQuickplay();
            } else if (e.target.data == HOST_GAME) {

            } else if (e.target.data == JOIN_GAME) {

            }
        }

        protected function startQuickplay():void {
            _loadingScreen = new NetLoadingScreen();
            _loadingScreen.lbl.text = "Searching For Players... 0/2";
            pushSuperScreen(_loadingScreen);

            GameEvent.addOneTimeEventListener(Singleton.get(NetworkManager), GameEvent.ACTION_COMPLETE,
                                              roomPollHandler);
            Singleton.get(NetworkManager).pollRooms();
        }

        protected function roomPollHandler(e:GameEvent):void {
            //Look for room to join
            for (var i:int = 0; i < e.data.rooms.length; i++) {
                var roomInfo:RoomInfo = e.data.rooms[i];
                trace("ROOM INFO " + i +" ... NUM PLAYERS: " + roomInfo.data.numPlayers + "  " + parseInt(roomInfo.data.numPlayers) + " ... ONLINE USERS: " + roomInfo.data.onlineUsers + "  " + parseInt(roomInfo.data.onlineUsers) +"  JOINING?  " + (roomInfo.onlineUsers < parseInt(roomInfo.data.numPlayers)));
                if (parseInt(roomInfo.data.onlineUsers) < parseInt(roomInfo.data.numPlayers)) {
                    Singleton.get(NetworkManager).joinRoom(roomInfo, "NewPlayer");
                    return;
                }
            }

            //Couldn't find room, create own room
            Singleton.get(NetworkManager).createRoom(2, "NewPlayer");
        }

        protected function netMessageHandler(e:GameEvent):void {
            if (e.data.type == NetworkMessage.JOIN) {
                Singleton.get(NetworkManager).claimMessage(e.data);

                _loadingScreen.lbl.text = _loadingScreen.lbl.text = "Searching For Players... "
                                          + e.data.vars.playersInRoom + "/" + e.data.vars.playersExpected;

                //Request updated player data...
                Singleton.get(NetworkManager).sendMessage(NetworkMessage.PLAYER_DATA_REQUEST);
            } else if (e.data.type == NetworkMessage.LEFT) {
                Singleton.get(NetworkManager).claimMessage(e.data);

                _loadingScreen.lbl.text = _loadingScreen.lbl.text = "Searching For Players... "
                                          + e.data.vars.playersInRoom + "/" + e.data.vars.playersExpected;
                
                //Request updated player data...
                Singleton.get(NetworkManager).sendMessage(NetworkMessage.PLAYER_DATA_REQUEST);
            } else if (e.data.type == NetworkMessage.PLAYER_DATA_REQUEST) {
                //If we have enough players, start the game
                if (e.data.vars.playersInRoom >= e.data.vars.playersExpected) {
                    dismissAllSuperScreens();
                    buildPlayersAndStartGame(e.data.vars);
                }
            }
        }

        protected function buildPlayersAndStartGame(playerDataRequest:Object):void {

            function fullPlayerDataRecieved(e:GameEvent):void {
                const playerDisplays:Array = ["PlayerBlue", "PlayerOrange", "PlayerGreen", "PlayerYellow"];
                const playerColours:Array = [0x0000FF, 0xFF6500, 0x009900, 0xFFFF00];

                var playerDatabases:Array = e.data.vars;
                
                //Construct player data objects
                var playerDatas:Array = new Array();
                for (var i:int = 0; i < playerDataRequest.playersInRoom; i++) {
                    var inputSrc:int =
                        Singleton.get(NetworkManager).isLocalPlayerNetID(playerDataRequest.playerNetIDs[i]) ?
                        NetScreen.PLAYER_INPUT : NetScreen.NET_INPUT;

                    var newPlayerData:PlayerData = new PlayerData();
                    newPlayerData.loadFromDatabase(playerDatabases[i]);
                    newPlayerData.playerNum = i;
                    newPlayerData.display = playerDisplays[i];
                    newPlayerData.color = playerColours[i];
                    newPlayerData.inputSource = inputSrc;

                    playerDatas.push(newPlayerData);
                }

                dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, {action:START_GAME,
                        gameData:{boardType:"default", playerDatas:playerDatas}}));
            }

            GameEvent.addOneTimeEventListener(Singleton.get(NetworkManager), GameEvent.ACTION_COMPLETE,
                fullPlayerDataRecieved);
            Singleton.get(NetworkManager).pollForPlayerData(playerDataRequest.playerNetIDs);
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