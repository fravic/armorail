package septenary.duelparty {
    import septenary.duelparty.screens.*;

    import flash.events.EventDispatcher;

    import playerio.*;

    public class NetworkManager extends EventDispatcher {

        private static const SERVER_TYPE:String = "DuelParty";
        private static const PLAYER_DATA_TABLE:String = "PlayerObjects";
        private static const ROOM_LIST_LIMIT:int = 50;

        protected var _localPlayerGuestID:String;
        protected var _localPlayerDatabase:DatabaseObject;
        protected var _localPlayerData:PlayerData;

        protected var _activeConnection:Connection;
        protected var _activeClient:Client;

        protected var _messageQueue:Array = new Array();

        CONFIG::RELEASE {
            protected static const PLAYER_IO_GAME_ID:String = "armorail-yvvzcnzuue6on0gb458tgq";
        }
        CONFIG::DEBUG {
            protected static const PLAYER_IO_GAME_ID:String = "armorail-staging-gd2zgihntugoxgb985fdlq";
        }

        public function get localPlayerData():PlayerData {
            return _localPlayerData;
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

        public function isLocalPlayerNetID(netID:String):Boolean {
            return isConnected() && netID == _localPlayerData.netID;
        }

        public function isConnected():Boolean {
            return _activeConnection != null;
        }

        /* LOGIN/ACCOUNT MANAGEMENT */

        public function login(username:String, password:String):void {
            _localPlayerData = new PlayerData();
            _localPlayerData.name = username;

            PlayerIO.quickConnect.simpleConnect(
                DuelParty.stage,
                PLAYER_IO_GAME_ID,
                username,
                password,
                handleConnect,
                handleConnectError
            );
        }

        public function register(username:String, password:String):void {
            _localPlayerData = new PlayerData();
            _localPlayerData.name = username;

            PlayerIO.quickConnect.simpleRegister(
                DuelParty.stage,
                PLAYER_IO_GAME_ID,
                username,
                password,
                null,                   //email
                null,                   //captcha key
                null,                   //captcha value
                null,                   //playerObject data, for storage in BigDB
                handleConnect,
                handleConnectError
            );
        }

        public function loginAsGuest():void {
            _localPlayerGuestID = Math.round(Math.random() * 99999).toString();
            _localPlayerData = new PlayerData();
            _localPlayerData.name = netIDForGuestID(_localPlayerGuestID);

            playerIOConnect(_localPlayerData.name);
        }

        protected function playerIOConnect(userID:String, authKey:String=""):void {
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

        protected function handleConnect(client:Client):void {
            _activeClient = client;
            _localPlayerData.netID = client.connectUserId;

            CONFIG::DEVSERVER {
                client.multiplayer.developmentServer = "localhost:8184";
            }

            if (_localPlayerGuestID != null) {
                //Manually create guest data in the player objects database
                client.bigDB.createObject(PLAYER_DATA_TABLE, client.connectUserId, _localPlayerData.getSavableObject(),
                    handlePlayerDatabaseLoad, handleConnectError);
            } else {
                //Load saved player object data first
                client.bigDB.loadMyPlayerObject(handlePlayerDatabaseLoad, handleConnectError);
            }
        }

        protected function handlePlayerDatabaseLoad(playerDatabase:DatabaseObject):void {
            _localPlayerDatabase = playerDatabase;
            _localPlayerData.loadFromDatabase(playerDatabase);

            //Synchronize by saving
            savePlayerDatabase();

            trace("PLAYER.IO CONNECTED SUCCESSFULLY!");
            dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, {success:true}));
        }

        protected function handleConnectError(error:PlayerIOError):void {
            trace("PLAYER.IO "+error.type+" "+error);

            var errorMessage:String = "Unable to connect to server.";
            if (error is PlayerIORegistrationError) {
                errorMessage = "This username has already been registered!  Please try another one.";
            } else if (error.type == PlayerIOError.InvalidPassword) {
                errorMessage = "The password you entered is incorrect.";
            } else if (error.type == PlayerIOError.UnknownUser) {
                errorMessage = "This user does not exist!";
            }
            dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, {success:false, errorMessage:errorMessage}));
        }

        public function savePlayerDatabase():void {
            Utilities.assert(_localPlayerDatabase != null, "There is no player database to save to!");
            Utilities.assert(_localPlayerData != null, "There is no data to save!");
            var saveData:Object = _localPlayerData.getSavableObject();
            for (var i:String in saveData) _localPlayerDatabase[i] = saveData[i];
            _localPlayerDatabase.save(false, false, handleSave, handleSaveError);
        }

        protected function handleSave():void {}

        protected function handleSaveError(error:PlayerIOError):void {}

        public function logout():void {
            savePlayerDatabase();
            _localPlayerGuestID = null;
            _localPlayerDatabase = null;
            _localPlayerData = null;
            _activeConnection = null;
            _activeClient = null;
        }

        protected function netIDForGuestID(guestID:String):String {
            Utilities.assert(guestID != null, "Cannot form netID for null guestID!");
            return "Guest "+guestID;
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

            for (var i:String in roomData) roomData[i] = roomData[i].toString();
            for (var j:String in joinData) joinData[j] = joinData[j].toString();

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

        public function pollRooms():void {
            _activeClient.multiplayer.listRooms(SERVER_TYPE, {}, ROOM_LIST_LIMIT, 0, roomPollComplete,
                handleConnectError);
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

        /* DATABASE MANAGEMENT */

        public function pollForPlayerData(netIDs:Array):void {
            pollDatabase(PLAYER_DATA_TABLE, netIDs);
        }

        public function pollDatabase(table:String, keys:Array):void {
            _activeClient.bigDB.loadKeys(table, keys, handleDatabasePoll, handleDatabaseError);
        }

        protected function handleDatabasePoll(dbArr:Array):void {
            dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, {vars:dbArr}))
        }

        protected function handleDatabaseError(error:PlayerIOError):void {
            trace("PLAYER.IO "+error.type+" "+error);
        }

        public function purgeGuestData():void {
            Utilities.assert(_localPlayerGuestID != null, "Cannot purge guest data; not a guest!");
            _activeClient.bigDB.deleteKeys(PLAYER_DATA_TABLE, [netIDForGuestID(_localPlayerGuestID)]);
            _localPlayerGuestID = null;
        }
    }
}