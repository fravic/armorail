package septenary.duelparty {
    import septenary.duelparty.screens.*;

    import flash.events.EventDispatcher;

    import playerio.*;

    public class NetworkManager extends EventDispatcher {

        private static const SERVER_TYPE:String = "bounce";
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

            //Player.IO-specific types, DO NOT EDIT
            NetworkMessage.registerMessageTypeArgs(NetworkMessage.JOIN, [{numUsers:int}, {playerNetID:String}]);
            NetworkMessage.registerMessageTypeArgs(NetworkMessage.LEFT, [{numUsers:int}, {playerNetID:String}]);

            //Custom types
            NetworkMessage.registerMessageTypeArgs(NetworkMessage.PLAYER_DATA, [{playerNetID:String}, {name:String},
                                                                                {playerNum:int}]);
            NetworkMessage.registerMessageTypeArgs(NetworkMessage.DICE_ROLL, [{playerNetID:String}, {roll:int}]);
            NetworkMessage.registerMessageTypeArgs(NetworkMessage.DIALOG_BOX, [{playerNetID:String}, {type:String},
                                                                               {tier:int}]);
            NetworkMessage.registerMessageTypeArgs(NetworkMessage.DIR_SELECT, [{playerNetID:String}, {dir:int}]);
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

        public function createRoom(numUsers:int):void {
            Utilities.assert(_activeClient != null, "Cannot create room on inactive client!");
            _activeClient.multiplayer.createJoinRoom(
                "test"+Math.round(Math.random() * 1000),
                SERVER_TYPE,
                true,
                {numUsers:numUsers.toString()},
                {},
                handleRoomCreate,
                handleRoomCreateError
            );
        }

        protected function handleRoomCreate(connection:Connection):void {
            initConnection(connection);
        }

        protected function handleRoomCreateError(error:PlayerIOError):void {

        }

        public function joinRoom(roomInfo:RoomInfo):void {
            Utilities.assert(_activeClient != null, "Cannot join room on inactive client!");
            _activeClient.multiplayer.createJoinRoom(
                roomInfo.id,
                SERVER_TYPE,
                true,
                {},
                {},
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
                dispatchEvent(new GameEvent(GameEvent.NETWORK_MESSAGE, {type:m.type, netData:m.data, message:m}));
            }
        }

        public function claimMessage(m:NetworkMessage):void {
            _messageQueue.splice(_messageQueue.indexOf(m));
        }

        public function sendMessage(type:String, data:Object):void {
            if (_activeConnection == null) {
                Utilities.logx("Warning: Cannot send message to an inactive connection.");
                return;
            }

            var message:NetworkMessage = new NetworkMessage(type, data);
            var argsArray:Array = [type].concat(message.serializedData);
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