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

        public function MultiplayerLobbyScreen(screenData:Object=null) {
            super();

            btnQuickplay.lbl.text = QUICKPLAY;
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
            const playerDisplays:Array = ["PlayerBlue", "PlayerOrange", "PlayerGreen", "PlayerYellow"];
            const playerColours:Array = [0x0000FF, 0xFF6500, 0x009900, 0xFFFF00];

            //Construct player data objects
            var playerDatas:Array = new Array();
            for (var i:int = 0; i < playerDataRequest.playersInRoom; i++) {
                var inputSrc:int = playerDataRequest.playerNetIDs[i] ==
                                   Singleton.get(NetworkManager).localPlayerNetID ?
                                   NetScreen.PLAYER_INPUT :
                                   NetScreen.NET_INPUT;
                var display:String = playerDisplays[i];
                var color:int = playerColours[i];
                var newPlayerData:PlayerData = new PlayerData(i, display, playerDataRequest.playerNames[i], inputSrc,
                        playerDataRequest.playerNetIDs[i], color, 0);

                trace("ADDED PLAYER DATA: " + newPlayerData.display);

                playerDatas.push(newPlayerData);
            }

            dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, {action:START_GAME,
                    gameData:{boardType:"default", playerDatas:playerDatas}}));   
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