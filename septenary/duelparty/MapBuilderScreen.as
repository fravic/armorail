package septenary.duelparty {
    import septenary.duelparty.boardtiles.*;

    import flash.geom.Point;
    import flash.display.Sprite;
    import flash.ui.Keyboard;
    import flash.filters.GlowFilter;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;

    public class MapBuilderScreen extends Screen {

        protected const MIN_TILE_DISTANCE:Number = 60;
        protected const CURSOR_WITH_PROXTILE:int = 0xCC2222;
        protected const CURSOR_NORMAL:int = 0x22CC22;

        protected var _contentArea:Sprite = new Sprite();
        protected var _tileConnections:Sprite = new Sprite();
        protected var _background:Sprite;

        protected var _cursor:Sprite = new Sprite();
        protected var _cursorSpeed:Point = new Point(0, 0);
        protected var _backgroundName:String = "";
        protected var _embellishments:Array = new Array();

        protected var _boardTiles:Array = new Array();
        protected var _modifiedParamsForBoardTile:Dictionary = new Dictionary();
        protected var _selectedTile:BoardTile;
        protected var _proxTile:BoardTile;
        protected var _baseTilesAdded:int = 0;

        public function MapBuilderScreen(screenData:Object=null) {
            _contentArea.addChild(_cursor);
            redrawCursor(CURSOR_WITH_PROXTILE);
            redrawBackground();
            addChild(_contentArea);

            super(screenData);
        }

        protected function redrawBackground():void {
            graphics.beginFill(0x555555, 1);
            graphics.drawRect(0, 0, DuelParty.stageWidth, DuelParty.stageHeight);

            _contentArea.addChild(_tileConnections);
        }

        protected function redrawCursor(color:int):void {
            const cursorRadius:Number = 15;
            const crosshairRadius:Number = 25;

            _cursor.graphics.lineStyle(1.5, color, 1);
            _cursor.graphics.drawCircle(0, 0, cursorRadius);
            _cursor.graphics.moveTo(0, -crosshairRadius);
            _cursor.graphics.lineTo(0, crosshairRadius);
            _cursor.graphics.moveTo(-crosshairRadius, 0);
            _cursor.graphics.lineTo(crosshairRadius, 0);
        }

        protected function cursorMove(key:int, down:Boolean):void {
            const cursorSpeed:Number = 30;
            
            switch(key) {
                case Keyboard.DOWN:
                    _cursorSpeed.y = down ? cursorSpeed : 0;
                    break;
                case Keyboard.UP:
                    _cursorSpeed.y = down ? -cursorSpeed : 0;
                    break;
                case Keyboard.LEFT:
                    _cursorSpeed.x = down ? -cursorSpeed : 0;
                    break;
                case Keyboard.RIGHT:
                    _cursorSpeed.x = down ? cursorSpeed : 0;
                    break;
            }
        }

        protected function cursorClick():void {
            if (_proxTile) {
                if (_selectedTile) {
                    if (_selectedTile == _proxTile) {
                        deselectTile();
                    } else if (_selectedTile.tilesOut.indexOf(_proxTile) >= 0 ||
                        _selectedTile.tilesIn.indexOf(_proxTile) >= 0) {
                        disconnectTileFromSelected(_proxTile);
                    } else {
                        connectTileToSelected(_proxTile);
                    }
                    return;
                } else {
                    selectTile(_proxTile);
                    return;
                }
            }
            showMapBuilderMenu();
        }

        protected function deselectTile():void {
            if (!_selectedTile) return;
            _selectedTile.filters = [];
            _selectedTile = null;
        }

        protected function selectTile(tile:BoardTile):void {
            if (_selectedTile) deselectTile();

            _selectedTile = tile;
            var filters:Array = [new GlowFilter(0xAAAA00)];
            _selectedTile.filters = filters;
        }

        protected function showMapBuilderMenu():void {
            var tileSelect:MapBuilderMenu = new MapBuilderMenu();
            GameEvent.addOneTimeEventListener(tileSelect, GameEvent.ACTION_COMPLETE, mapBuilderMenuAction);
            pushSuperScreen(tileSelect);

            _cursorSpeed = new Point(0, 0);
        }

        protected function mapBuilderMenuAction(e:GameEvent):void {
            dismissAllSuperScreens();

            switch(e.data.action) {
                case MapBuilderMenu.ACTION_ADD_TILE:
                    addNewTile(e);
                    break;
                case MapBuilderMenu.ACTION_COMPILE_MAP:
                    compileMap();
                    break;
                case MapBuilderMenu.ACTION_LOAD_MAP:
                    loadMap();
                    break;
                case MapBuilderMenu.ACTION_LOAD_BG:
                    loadBackground();
                    break;
                case MapBuilderMenu.ACTION_TILE_PARAMS:
                    setSelectedTileParams();
                    break;
                case MapBuilderMenu.ACTION_ADD_EMB:
                    addNewEmb(e);
                    break;
            }
        }

        protected function addNewTile(e:GameEvent):void {
            var tileName:String = e.data.tileName;

			var newTile:BoardTile = Utilities.classInstanceFromString(BoardLoader.TILE_CLASS_PREFIX + tileName);
            newTile.x = _cursor.x;
            newTile.y = _cursor.y;

            connectTileToSelected(newTile);
            addBoardTile(newTile);
        }

        protected function addNewEmb(e:GameEvent):void {
            var embName:String = e.data.embName;
            var newEmb:Sprite = Utilities.classInstanceFromString(embName);
            newEmb.x = _cursor.x;
            newEmb.y = _cursor.y;
            _contentArea.addChild(newEmb);
            _embellishments.push(newEmb);
        }

        protected function addBoardTile(newTile:BoardTile):void {
            _contentArea.addChild(newTile);
            _boardTiles.push(newTile);
            selectTile(newTile);
            setInstantTileParams(newTile);
        }

        protected function setInstantTileParams(tile:BoardTile):void {
            var tileType:String = getShortQualifiedName(tile, "Tile".length);
            if (tileType == "Base") {
                setParamOnTile(tile, "startPlayer", _baseTilesAdded++);
            }
        }

        protected function getShortQualifiedName(obj:Sprite, parseEnd:int=0):String {
            var tileClassName:String = getQualifiedClassName(obj);
            var classNameSplit:Array = tileClassName.split("::");
            var tileName:String = classNameSplit[classNameSplit.length-1];
            return tileName.substr(0, tileName.length-parseEnd);
        }

        protected function setParamOnTile(tile:BoardTile, param:String, paramValue:*) {
            if (_selectedTile[param] != paramValue) {
                if (_modifiedParamsForBoardTile[_selectedTile] == null) {
                    _modifiedParamsForBoardTile[_selectedTile] = new Array();
                }
                _modifiedParamsForBoardTile[_selectedTile].push(param);
            }
            _selectedTile[param] = paramValue;    
        }

        protected function removeFromArray(obj:Object, a:Array):void {
            if (a.indexOf(obj) >= 0) {
                a.splice(a.indexOf(obj), 1);
            }
        }

        protected function removeProxTile():void {
            if (!_proxTile) return;

            for (var i:int = 0; i < _boardTiles.length; i++) {
                removeFromArray(_proxTile, _boardTiles[i].tilesIn);
                removeFromArray(_proxTile, _boardTiles[i].tilesOut);
            }

            _contentArea.removeChild(_proxTile);
            removeFromArray(_proxTile, _boardTiles);
            deselectTile();
            redrawTileConnections();
        }

        protected function redrawTileConnections():void {
            const arrowAngle:Number = Math.PI/5;
            const arrowLength:Number = 20;

            formTileGraph();

            _tileConnections.graphics.clear();
            _tileConnections.graphics.lineStyle(2, 0x444444, 1);

            for (var i:int = 0; i < _boardTiles.length; i++) {
                var thisTile:BoardTile = _boardTiles[i];

                for (var j:int = 0; j < thisTile.tilesOut.length; j++) {
                    var outTile:BoardTile = thisTile.tilesOut[j];
                    _tileConnections.graphics.moveTo(thisTile.x, thisTile.y);
                    _tileConnections.graphics.lineTo(outTile.x, outTile.y);

                    var diffDist:Point = new Point((thisTile.x - outTile.x), (thisTile.y - outTile.y));
                    var midPoint:Point = new Point(outTile.x + diffDist.x/2, outTile.y + diffDist.y/2);
                    var angle:Number = Math.atan2(diffDist.y, diffDist.x);
                    var pt1:Point = new Point(midPoint.x + arrowLength * Math.cos(angle + arrowAngle),
                                              midPoint.y + arrowLength * Math.sin(angle + arrowAngle));
                    var pt2:Point = new Point(midPoint.x + arrowLength * Math.cos(angle - arrowAngle),
                                              midPoint.y + arrowLength * Math.sin(angle - arrowAngle));

                    _tileConnections.graphics.moveTo(midPoint.x, midPoint.y);
                    _tileConnections.graphics.lineTo(pt1.x, pt1.y);
                    _tileConnections.graphics.moveTo(midPoint.x, midPoint.y);
                    _tileConnections.graphics.lineTo(pt2.x, pt2.y);
                }
            }
        }

        protected function connectTileToSelected(tile:BoardTile):void {
            if (!_selectedTile) return;
            if (_selectedTile.tilesOut.indexOf(tile) >= 0 || _selectedTile.tilesIn.indexOf(tile) >= 0) return; 
            _selectedTile.tilesOut.push(tile);
            attemptAngleNormalization(tile);
            attemptAngleNormalization(_selectedTile);
            redrawTileConnections();
        }

        protected function disconnectTileFromSelected(tile:BoardTile):void {
            if (!_selectedTile) return;
            removeFromArray(tile, _selectedTile.tilesOut);
            removeFromArray(tile, _selectedTile.tilesIn);
            removeFromArray(_selectedTile, tile.tilesOut);
            removeFromArray(_selectedTile, tile.tilesIn);
            redrawTileConnections();
        }

        protected function attemptAngleNormalization(tile:BoardTile):void {
            const rotStep:Number = 30;
            const moveConstraint:Number = 10;

            //Attempt to make tile angles as close to standard fighter rotation step as possible
            var allTiles:Array = tile.tilesOut.concat(tile.tilesIn);
            for (var i:int = 0; i < allTiles.length; i++) {
                var tileNow:BoardTile = allTiles[i];
                var angleNow:Number = Math.atan2(tileNow.y-tile.y, tileNow.x-tile.x);
                var optAngle1:Number = angleNow % rotStep;
                var optAngle2:Number = optAngle1 > angleNow ? optAngle1 - rotStep : optAngle1 + rotStep;
                var optAngle = Math.abs(optAngle1 - angleNow) < Math.abs(optAngle2 - angleNow) ? optAngle1 : optAngle2;
            }
        }

        protected function selectProxTile(tile:BoardTile):void {
            if (_proxTile == tile) return;
            if (_proxTile) deselectProxTile();
            _proxTile = tile;
            redrawCursor(CURSOR_WITH_PROXTILE);

            if (_selectedTile != _proxTile) {
                var filters:Array = [new GlowFilter(0x0000AA)];
                _proxTile.filters = filters;
            }
        }

        protected function deselectProxTile():void {
            if (!_proxTile) return;
            redrawCursor(CURSOR_NORMAL);

            if (_selectedTile != _proxTile) {
                _proxTile.filters = [];
            }
            _proxTile = null;
        }

        protected function checkProxTile():void {
            for (var i:int = 0; i < _boardTiles.length; i++) {
                var thisTile:BoardTile = _boardTiles[i];
                var dist:Number = Point.distance(new Point(thisTile.x, thisTile.y), new Point(_cursor.x, _cursor.y));
                if (dist < MIN_TILE_DISTANCE) {
                    selectProxTile(thisTile);
                    return;
                }
            }
            deselectProxTile();
        }

        public override function update():void {
            const cursorUpdateDiv:Number = 2;
            var cursorTarg:Point = new Point(_cursor.x + _cursorSpeed.x, _cursor.y + _cursorSpeed.y);
            _cursor.x += (cursorTarg.x - _cursor.x) / cursorUpdateDiv;
            _cursor.y += (cursorTarg.y - _cursor.y) / cursorUpdateDiv;

            var xMax:Number = _background ? _background.width : DuelParty.stageWidth;
            var yMax:Number = _background ? _background.height : DuelParty.stageHeight;
            if (_cursor.x < 0) _cursor.x = 0;
            else if (_cursor.x > xMax) _cursor.x = xMax;
            if (_cursor.y < 0) _cursor.y = 0;
            else if (_cursor.y > yMax) _cursor.y = yMax;

            checkProxTile();

            updateCamera();
            setContentChildIndicies();
        }

        protected function updateCamera():void {
			if (!_background) return;

			const camMove:Number = 15;
			var targPoint:Point = new Point(-_cursor.x + DuelParty.stageWidth/2,
											-_cursor.y + DuelParty.stageHeight/2);
			Utilities.keepPointInBounds(targPoint, new Rectangle(-_background.width + DuelParty.stageWidth,
                                                                 -_background.height + DuelParty.stageHeight,
                                                                 0, 0));
			_contentArea.x += (targPoint.x - _contentArea.x) / camMove;
			_contentArea.y += (targPoint.y - _contentArea.y) / camMove;
		}

        protected function toXML():XML {
            var xml:XML = <board></board>;
            xml.@background = _backgroundName;
            xml.@numPlayers = _baseTilesAdded;

            var tilesXML:XML = <boardTiles></boardTiles>;
            for (var i:int = 0; i < _boardTiles.length; i++) {
                var thisTile:BoardTile = _boardTiles[i];

                var tileXML:XML = <tile></tile>;
                tileXML.@id = i;
                tileXML.@x = thisTile.x;
                tileXML.@y = thisTile.y;

                var typeNode:XML = <type></type>;
                typeNode.setChildren(getShortQualifiedName(thisTile, "Tile".length));
                tileXML.appendChild(typeNode);

                var outNode:XML = <tilesOut></tilesOut>;
                for (var j:int = 0; j < thisTile.tilesOut.length; j++) {
                    var tileOutNode:XML = <tileOut></tileOut>;
                    tileOutNode.setChildren(_boardTiles.indexOf(thisTile.tilesOut[j]));
                    outNode.appendChild(tileOutNode);
                }
                tileXML.appendChild(outNode);

                if (_modifiedParamsForBoardTile[thisTile] != null) {
                    var dataFieldNames:Array = _modifiedParamsForBoardTile[thisTile];
                    for (j = 0; j < dataFieldNames.length; j++) {
                        var paramNode:XML = <{dataFieldNames[j]}></{dataFieldNames[j]}>;
                        paramNode.setChildren(thisTile[dataFieldNames[j]]);
                        tileXML.appendChild(paramNode);
                    }
                }

                tilesXML.appendChild(tileXML);
            }
            xml.setChildren(tilesXML);

            var embsXML:XML = <embellishments></embellishments>;
            for (i = 0; i < _embellishments.length; i++) {
                var thisEmb:Sprite = _embellishments[i];
                var embXML:XML = <embellishment></embellishment>;
                embXML.@x = thisEmb.x;
                embXML.@y = thisEmb.y;
                embXML.setChildren(getShortQualifiedName(thisEmb));
                embsXML.appendChild(embXML);
            }
            xml.appendChild(embsXML);

            return xml;
        }

        protected function formTileGraph():void {
            for (var i:int = 0; i < _boardTiles.length; i++) {
                _boardTiles[i].tilesIn.splice(0, _boardTiles[i].tilesIn.length);
            }

            for (i = 0; i < _boardTiles.length; i++) {
                var thisTile:BoardTile = _boardTiles[i];
                for (var j:int = 0; j < thisTile.tilesOut.length; j++) {
                    var outTile:BoardTile = thisTile.tilesOut[j];
                    outTile.tilesIn.push(thisTile);
                }
            }
        }

        protected function checkErrorCasesOnTile(tile:BoardTile):Boolean {
            var type:String = getShortQualifiedName(tile, "Tile".length);
            if (!tile.tilesOut.length) {
                showDialogBox(DialogBox.DIALOG_ONLY, {speaker:"Map Builder",
                              dialog:"ERROR: Tile '"+type+"' has no tiles out!"});
                return true;
            }
            if (type == "Gate" && ((tile as GateTile).gateDirForward && tile.tilesOut.length <= 1 ||
                                  !(tile as GateTile).gateDirForward && tile.tilesIn.length <= 1)) {
                showDialogBox(DialogBox.DIALOG_ONLY, {speaker:"Map Builder",
                              dialog:"ERROR: Gate tile requires at least one unblocked path!"});
                return true;
            }
            return false;
        }

        protected function compileMap():void {

            for (var i:int = 0; i < _boardTiles.length; i++) {
                if (checkErrorCasesOnTile(_boardTiles[i])) {
                    return;
                }
            }

            trace(toXML());
        }

        protected function loadMap():void {
            showDialogBox(DialogBox.TEXT_INPUT, {speaker:"Map Builder",
                                                 dialog:"Enter the filename of the map input file:"}, loadMapAtPath);
        }

        protected function loadMapAtPath(e:GameEvent):void {
            GameEvent.addOneTimeEventListener(BoardLoader.getBoardLoader(), GameEvent.ACTION_COMPLETE, boardLoaded);
            BoardLoader.getBoardLoader().loadBoard(e.data.text);
        }

        protected function boardLoaded(e:GameEvent):void {
            for (var i:int = 0; i < e.data.boardTiles.length; i++) {
                addBoardTile(e.data.boardTiles[i]);
            }
            redrawTileConnections();
            setBackground(e.data.envVars.background);
        }

        protected function loadBackground():void {
            showDialogBox(DialogBox.TEXT_INPUT, {speaker:"Map Builder",
                                                 dialog:"Enter the name of the background image:"}, backgroundChosen);
        }

        protected function backgroundChosen(e:GameEvent):void {
            setBackground(e.data.text);
        }

        protected function setBackground(bg:String):void {
            if (_background) {
                _contentArea.removeChild(_background);
            }

            try {
                _background = Utilities.classInstanceFromString(bg + "Background");
                _contentArea.addChildAt(_background, 0);
                _backgroundName = bg;
            } catch(e:Error) {
                showDialogBox(DialogBox.DIALOG_ONLY, {speaker:"Map Builder",
                                dialog:"'"+bg+"' is an invalid background file!"}, null);
                _background = null;
            }
        }

        protected function setSelectedTileParams():void {
            if (!_selectedTile) {
                showDialogBox(DialogBox.DIALOG_ONLY, {speaker:"Map Builder",
                                dialog:"You must select a tile to set its parameters!"}, null);
            } else {
                var tileClassName:String = getQualifiedClassName(_selectedTile);
                var tileClass:Object = getDefinitionByName(tileClassName);
                if (tileClass.getParamFields == null) {
                    showDialogBox(DialogBox.DIALOG_ONLY, {speaker:"Map Builder",
                                dialog:"Tile '"+tileClass+" has no parameters to set!"}, null);
                } else {
                    var dataFieldNames:Array = tileClass.getParamFields();
                    var dataFields:Object = new Object();
                    for (var i:int = 0; i < dataFieldNames.length; i++) {
                        dataFields[dataFieldNames[i]] = _selectedTile[dataFieldNames[i]];
                    }
                    showDialogBox(DialogBox.DATA_GRID, {speaker:"Map Builder",
                                    dialog:"Set parameters on '"+tileClass+"'...",
                                    dataFields:dataFields}, selectedTileParamsSet);
                }
            }
        }

        protected function selectedTileParamsSet(e:GameEvent):void {
            for (var param:String in e.data.dataGrid) {
                setParamOnTile(_selectedTile, param, e.data.dataGrid[param]);
            }
        }

        protected function setContentChildIndicies():void {
            var children:Array = new Array();
            for (var i:int = 0; i < _contentArea.numChildren; i++) {
                children.push(_contentArea.getChildAt(i));
            }
            children.sortOn(["y", "name"]);
            for (i = 0; i < children.length; i++) {
                _contentArea.setChildIndex(children[i], i);
            }
        }

        public override function gainedFocus():void {
            super.gainedFocus();
			KeyActions.addArrowKeyListeners(cursorMove);
            KeyActions.addArrowKeyListeners(cursorMove, false);
            KeyActions.addEventListener(Keyboard.SPACE, cursorClick);
            KeyActions.addEventListener(90 /*Z*/, deselectTile);
            KeyActions.addEventListener(88 /*X*/, removeProxTile);
        }

        public override function lostFocus():void {
            super.lostFocus();
			KeyActions.removeArrowKeyListeners();
            KeyActions.removeArrowKeyListeners(false);
            KeyActions.removeEventListener(Keyboard.SPACE);
            KeyActions.removeEventListener(90);
            KeyActions.removeEventListener(88);
        }
    }
}