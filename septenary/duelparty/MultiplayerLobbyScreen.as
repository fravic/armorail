package septenary.duelparty {
    import flash.events.MouseEvent;

    import playerio.*;

    public class MultiplayerLobbyScreen extends Screen {

        public static const LOGOUT:String = "Logout";
        public static const START_GAME:String = "StartGame";

        private static const QUICKPLAY:String = "Quickplay";


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
            var loadingScreen:NetLoadingScreen = new NetLoadingScreen();
            loadingScreen.lbl.text = "Searching For Players";
            pushSuperScreen(loadingScreen);

            GameEvent.addOneTimeEventListener(NetworkManager.getNetworkManager(), GameEvent.ACTION_COMPLETE,
                                              roomPollHandler);
            NetworkManager.getNetworkManager().pollRooms(QUICKPLAY);
        }

        protected function roomPollHandler(e:GameEvent):void {
            trace("ROOMS POLLED", e.data.rooms);

            //Look for room to join
            for (var i:int = 0; i < e.data.rooms.length; i++) {
                var roomInfo:RoomInfo = e.data.rooms[i];
                if (roomInfo.onlineUsers < roomInfo.data.numUsers) {
                    NetworkManager.getNetworkManager().joinRoom(roomInfo);
                    return;
                }
            }

            //Couldn't find room, create own room
            NetworkManager.getNetworkManager().createRoom(2);
        }

        protected function netMessageHandler(e:GameEvent):void {
            trace("PARSING NET MESSAGE...");
            if (e.data.type == NetworkMessage.JOIN) {
                trace("RECIEVED JOIN MESSAGE:", e.data.netData.numUsers, e.data.netData.playerNetID);
            }
        }

        public override function gainedFocus():void {
            super.gainedFocus();
            getFocusManager().addGeneralFocusableListener(this, buttonAction);
			NetworkManager.getNetworkManager().addEventListener(GameEvent.NETWORK_MESSAGE, netMessageHandler,
                                                                false, 0, true);
        }

        public override function lostFocus():void {
            super.lostFocus();
            getFocusManager().removeGeneralFocusableListener(this, buttonAction);
			NetworkManager.getNetworkManager().removeEventListener(GameEvent.NETWORK_MESSAGE, netMessageHandler);
        }
    }
}