package septenary.duelparty {
import flash.display.MovieClip;
import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class BoardLoader extends EventDispatcher {
		
		public static const BOARD_LOAD_URL:String = "boards/";
		public static const TILE_CLASS_PREFIX:String = "septenary.duelparty.boardtiles.";

        protected static var activeBoardLoader:BoardLoader;

		protected var _loadedBoards:Object = new Object();
		protected var _loadingBoard:String;

		protected var _boardOutConnections = new Array();

        public static function getBoardLoader():BoardLoader {
            if (!activeBoardLoader) {
                activeBoardLoader = new BoardLoader();
            }
			return activeBoardLoader;
		}

        public function BoardLoader() {
            Utilities.assert(activeBoardLoader == null, "Double instantiation of singleton BoardLoader.");
        }
		
		public function loadBoard(boardDef:String):void {
			_loadingBoard = boardDef;

			//Attempt load from cache
			if (_loadedBoards[boardDef] != null) {
				parseBoardXML(_loadedBoards[boardDef]);
				return;
			}
			
			var loadURL:URLLoader = new URLLoader(new URLRequest(BOARD_LOAD_URL + boardDef + ".xml"));
			loadURL.addEventListener(Event.COMPLETE, loadBoardComplete, false, 0, true);
            loadURL.addEventListener(IOErrorEvent.IO_ERROR, loadBoardError, false, 0, true);
		}
		
		protected function loadBoardComplete(e:Event):void {
			_loadedBoards[_loadingBoard] = XML(e.target.data);
			parseBoardXML(_loadedBoards[_loadingBoard]);
		}

        protected function loadBoardError(e:IOErrorEvent):void {
            trace("INVALID BOARD FILE");
        }

		protected function parseBoardXML(boardDef:XML):void {
			var envVars:Object = parseAttributes(boardDef);
            dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE,
                                       {boardTiles:parseBoardTiles(boardDef["boardTiles"].children(), envVars),
                                        embellishments:parseEmbellishments(boardDef["embellishments"].children()),
                                        envVars:envVars}));
		}
		
		protected function parseBoardTiles(tilesList:XMLList, envVars:Object):Array {
			var boardTiles:Array = new Array();
			envVars.startPositions = new Array();
			
			for (var i:int = 0; i < tilesList.length(); i++) {
				var newBoardTile:BoardTile = parseBoardTile(tilesList[i], envVars);
				boardTiles[newBoardTile.id] = newBoardTile;
			}
			formTileGraph(boardTiles);
			
			return boardTiles;
		}
		
		protected function parseBoardTile(boardTile:XML, envVars:Object):BoardTile {
			//Parse tile propterites 
			var tileType:String = boardTile["type"];
			var tilesOutList:XMLList = boardTile["tilesOut"].children();
			var tilesOut:Array = new Array();
			for (var i:int = 0; i < tilesOutList.length(); i++) {
				tilesOut.push(parseInt(tilesOutList[i]));
			}
		
			//Create new tile
			var newBoardTile:BoardTile = Utilities.classInstanceFromString(TILE_CLASS_PREFIX + tileType + "Tile");
			newBoardTile.setDisplay(tileType);

			//Start tile?
			if (boardTile["startPlayer"]) {
				envVars.startPositions[parseInt(boardTile["startPlayer"])] = newBoardTile;
			}
			
			//Direct tile attributes
			var tileAttrs:Object = parseAttributes(boardTile);
			for (var j:String in tileAttrs) {
				newBoardTile[j] = tileAttrs[j];
			}

            //Direct tile nodes
            var tileNodes:XMLList = boardTile.children();
            for (i = 0; i < tileNodes.length(); i++) {
                var nodeName:String = tileNodes[i].name();
                if (nodeName == "type" || nodeName == "tilesOut" || nodeName == "tilesIn"
                    || nodeName == "startPlayer") continue;
                newBoardTile[nodeName] = Utilities.parseXMLValue(tileNodes[i]);           
            }
			
			_boardOutConnections[newBoardTile.id] = tilesOut;
			
			return newBoardTile;
		}
		
		protected function formTileGraph(boardTiles:Array):void {
			//Form the "tilesIn" and "tilesOut" properties of each board tile
			for (var i:int = 0; i < boardTiles.length; i++) {
				if (boardTiles[i] == null) {
					continue;
				}
				for (var j:int = 0; j < _boardOutConnections[i].length; j++) {
					try {
						boardTiles[i].tilesOut.push(boardTiles[_boardOutConnections[i][j]]);
						boardTiles[_boardOutConnections[i][j]].tilesIn.push(boardTiles[i]);
					} catch(ex:Error) {
						trace("INVALID TILE ID REFERENCE: " + _boardOutConnections[i][j]);
					}
				}
			}
			for (i = 0; i < boardTiles.length; i++) {
				if (boardTiles[i] == null) {
					boardTiles.splice(i--, 1);
				}
			}
		}

        protected function parseEmbellishments(embList:XMLList):Array {
            var embs:Array = new Array();

            for (var i:int = 0; i < embList.length(); i++) {
                var embAttrs:Object = parseAttributes(embList[i]);
                var newEmb:MovieClip = Utilities.classInstanceFromString(Utilities.parseXMLValue(embList[i]));
                newEmb.x = embAttrs.x;
                newEmb.y = embAttrs.y;
                embs.push(newEmb);
            }
            
            return embs;
        }
		
		protected function parseAttributes(val:XML):Object {
			var attrs:XMLList = val.attributes();
			var ret:Object = new Object();
			
			for (var i:int = 0; i < attrs.length(); i++){
                ret[attrs[i].name().toString()] = parseXMLValue(attrs[i]);
            }
            
            return ret;
		}
		
		protected function parseXMLValue(val:XML):* {
            //Parse string
            var str:String = val.toString();

            //Parse numeric
            var num:Number = Number(str);
            if (!isNaN(num)) return num;

            //Parse boolean
            if (str == "true") return true;
            if (str == "false") return false;

            return str;
        }

	}
}