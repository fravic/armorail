package septenary.duelparty {
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
    import flash.utils.ByteArray;
    import com.hurlant.crypto.Crypto;
	import com.hurlant.crypto.prng.Random;
    import com.hurlant.crypto.symmetric.*;
    import com.hurlant.util.*;

	public class NetworkManager {
		
		protected static const GAME_RECIEVE_URL:String = "http://www.anchat.com/duelparty/game/recv";
		protected static const GAME_SEND_URL:String = "http://www.anchat.com/duelparty/game/send";
		
		protected static var activeManager:NetworkManager;
		
		protected var netListenerQueue:Array = new Array();
		
		public static function getNetworkManager():NetworkManager {
            if (!activeManager) {
                activeManager = new NetworkManager();
            }
			return activeManager;
		}
		
		public function NetworkManager() {
            if (activeManager) Utilities.assert(false, "Double instantiation of singleton NetworkManager.");
		}
		
		public function startNetGame():void {
			longPoll();
		}
		
		public function pushNetData(netObject:Object):void {
			var urlLoader = new URLLoader();
			var urlRequest = new URLRequest(GAME_SEND_URL);
			urlRequest.data = {dataType:netObject.dataType, data:netObject.data};
			urlRequest.method = URLRequestMethod.GET;
			
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, netSendError, false, 0, true);
			urlLoader.load(urlRequest);
		}
		
		public function queueNetListener(listenFor:String, callback:Function):void {
			netListenerQueue.push({listenFor:listenFor, callback:callback});	
		}
		
		protected function longPoll():void {
			var urlLoader = new URLLoader();
			var urlRequest = new URLRequest(GAME_RECIEVE_URL);
			
			urlLoader.addEventListener(Event.COMPLETE, netDataReceived, false, 0, true);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, netRecieveError, false, 0, true);
			urlLoader.load(urlRequest);
		}
		
		protected function netDataReceived(e:Event):void {
			var nextListener:Object = netListenerQueue[0];
			var netObject:Object = decodeNetData(e.target.data);
			if (nextListener.listenFor == netObject.dataType) {
				nextListener.callback(netObject);
			}
			
			longPoll();
		}
		
		protected function decodeNetData(data:String):Object {
			var netObject = new Object();
			return {dataType:netObject.dataType, data:netObject.data};
		}
		
		protected function netRecieveError(e:IOErrorEvent):void {
		}
		
		protected function netSendError(e:IOErrorEvent):void {
		}

        function getAESKey():String {
            var r:Random = new Random;
            var pk:ByteArray = Hex.toArray("12345678901234567890");
            return Base64.encodeByteArray(pk);
        }

        function encrypt(input:String, key:String, algorithm:String =
                  "aes-128-ecb", padding:String = "None"):String {
            var kdata:ByteArray = Base64.decodeToByteArray(key);
            var data:ByteArray = Hex.toArray(Hex.fromString(input));
            var pad:IPad = padding == "pkcs5" ? new PKCS5 : new NullPad;
            var mode:ICipher = Crypto.getCipher(algorithm, kdata, pad);
            pad.setBlockSize (mode.getBlockSize());
            mode.encrypt (data);
            return Base64.encodeByteArray(data);
        }
	}
}