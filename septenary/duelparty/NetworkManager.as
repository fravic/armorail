package septenary.duelparty {
    import septenary.duelparty.screens.*;

    import flash.events.EventDispatcher;

    import playerio.*;

    public class NetworkManager extends EventDispatcher {

        private static const SERVER_TYPE:String = "DuelParty";
        private static const ROOM_LIST_LIMIT:int = 50;

        protected var _localPlayerNetID:String;
        protected var _localPlayerName:String;

        protected var _activeConnection:Connection;
        protected var _activeClient:Client;

        protected var _messageQueue:Array = new Array();

        CONFIG::RELEASE {
            protected static const PLAYER_IO_GAME_ID:String = "armorail-yvvzcnzuue6on0gb458tgq";
        }
        CONFIG::DEBUG {
            protected static const PLAYER_IO_GAME_ID:String = "armorail-staging-gd2zgihntugoxgb985fdlq";
        }

        public function get localPlayerNetID():String {
            return _localPlayerNetID;
        }
        public function get localPlayerName():String {
            return _localPlayerName;
        }

        public function NetworkManager() {
            Singleton.init(this);

            //Register message types
            NetworkMessage.registerMessageTypeArgs(NetworkMessage.JOIN,
                [{playerNetID:String}, {name:String}, {playerNum:int}, {playersInRoom:int}, {playersExpected:int}]);
            NetworkMessage.registerMessageTypeArgs(NetworkMessage.LEFT,
                [{playerNetID:String}, {name:String}, {playerNum:int}, {playersInRoom:int}, {playersExpected:int}]);
            NetworkMessage.registerMessageTypeArgs(NetworkMessage.PLAYER_DATA_REQUEST,
                [{playersInRoom:int}, {playersExpected:int}, {playerNetIDs:Array}, {playerNames:Array}]);
            NetworkMessage.registerMessageTypeArgs(NetworkMessage.DICE_ROLL,
                [{playerNetID:String}, {roll:int}]);
            NetworkMessage.registerMessageTypeArgs(NetworkMessage.DIALOG_BOX, 
                [{playerNetID:String}, {type:String}, {tier:int}]);
            NetworkMessage.registerMessageTypeArgs(NetworkMessage.DIR_SELECT,
                [{playerNetID:String}, {dir:int}]);
            NetworkMessage.registerMessageTypeArgs(NetworkMessage.FOCUS_CHANGE,
                [{playerNetID:String}, {focusable:int}]);
        }

        /* LOGIN/ACCOUNT MANAGEMENT */

        protected function login(userID:String, authKey:String=""):void {
            PlayerIO.connect(
                DuelParty.stage,
                PLAYER_IO_GAME_ID,
                "public",
                userID,
                authKey,
                handleConnect,
                handleConnectError
            );
        }

        public function loginToFacebook(username:String, password:String):void {

        }

        public function loginAsGuest():void {
            var guestID:int = Math.round(Math.random() * 1000);
            _localPlayerName = _localPlayerNetID = "Guest "+guestID;

            login(_localPlayerNetID);
        }

        protected function handleConnect(client:Client):void {
            _activeClient = client;

            CONFIG::DEVSERVER {
                client.multiplayer.developmentServer = "localhost:8184";
            }

            trace("PLAYER.IO CONNECTED SUCCESSFULLY!");
            dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, {success:true}));
        }

        protected function handleConnectError(error:PlayerIOError):void {
            trace("PLAYER.IO ERROR: "+error);
            dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, {success:true}));
        }

        /* ROOM MANAGEMENT */

        protected function initConnection(connection:Connection):void {
            Utilities.assert(_activeConnection == null, "A connection has already been initialized!");
            _activeConnection = connection;
            _activeConnection.addMessageHandler("*", handleMessage);
        }

        public function createRoom(numPlayers:int, playerName:String):void {
            createJoinRoom("test"+Math.round(Math.random() * 1000), {numPlayers:numPlayers, onlineUsers:0},
                {name:playerName});
        }

        public function joinRoom(roomInfo:RoomInfo, playerName:String):void {
            createJoinRoom(roomInfo.id, {}, {name:playerName});
        }

        protected function createJoinRoom(roomID:String, roomData:Object, joinData:Object):void {
            Utilities.assert(_activeClient != null, "Cannot join room on inactive client!");

            for (var i:* in roomData) roomData[i] = roomData[i].toString();
            for (var j:* in joinData) joinData[j] = joinData[j].toString();

            _activeClient.multiplayer.createJoinRoom(
                roomID,
                SERVER_TYPE,
                true,
                roomData,
                joinData,
                handleRoomJoin,
                handleRoomJoinError
            );
        }

        protected function handleRoomJoin(connection:Connection):void {
            initConnection(connection);
        }

        protected function handleRoomJoinError(error:PlayerIOError):void {

        }

        public function pollRooms(type:String):void {
            _activeClient.multiplayer.listRooms(SERVER_TYPE, {}, ROOM_LIST_LIMIT, 0, roomPollComplete, handleConnectError);
        }

        public function roomPollComplete(rooms:Array):void {
            dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, {rooms:rooms}));
        }

        /* MESSAGE MANAGEMENT */

        public function dispatchQueuedMessages():void {
            var messageQueue:Array = _messageQueue.slice();
            for (var i:int = 0; i < messageQueue.length; i++) {
                var m:NetworkMessage = messageQueue[i];
                dispatchEvent(new GameEvent(GameEvent.NETWORK_MESSAGE, m));
            }
        }

        public function claimMessage(m:NetworkMessage):void {
            _messageQueue.splice(_messageQueue.indexOf(m));
        }

        public function sendMessage(type:String, data:Object=null):void {
            if (_activeConnection == null) {
                Utilities.logx("Warning: Cannot send message to an inactive connection.");
                return;
            }

            var argsArray:Array = [type];
            if (data != null) {
                var message:NetworkMessage = new NetworkMessage(type, data);
                argsArray = argsArray.concat(message.serializedData);
            }
            _activeConnection.send.apply(_activeConnection, argsArray);
        }

        protected function handleMessage(m:Message){
            Utilities.logx("PLAYER.IO RECIEVED MESSAGE:", m);

            CONFIG::DEBUG {
                if (Singleton.get(GameInterfaceScreen)) {
                    Singleton.get(GameInterfaceScreen).addChatMessage(m.toString(), "NetMessage", 0xFF0000);
                }
            }

            var netMessage:NetworkMessage = new NetworkMessage(m.type);
            netMessage.deserializeMessage(m);

            _messageQueue.push(netMessage);
            dispatchQueuedMessages();
        }

        protected function handleDisconnect():void{
        }
    }
}