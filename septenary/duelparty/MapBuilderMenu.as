package septenary.duelparty {
    import fl.containers.ScrollPane;
    import flash.display.Sprite;
    import flash.events.MouseEvent;

    public class MapBuilderMenu extends Screen {

        public static const ACTION_ADD_TILE:int = 0;
        public static const ACTION_COMPILE_MAP:int = 1;
        public static const ACTION_LOAD_MAP:int = 2;
        public static const ACTION_LOAD_BG:int = 3;
        public static const ACTION_TILE_PARAMS:int = 4;
        public static const ACTION_ADD_EMB:int = 5;

        protected var _tilePane:ScrollPane;
        protected var _embPane:ScrollPane;
        protected var _menu:MapBuilderMenuButtons;

        public function MapBuilderMenu() {
            setupScrollPaneSelects();
            setupMenu();

            super();
        }

        protected function setupScrollPaneSelects():void {
            const mapTileTypes:Array = ["BankTile", "BaseTile", "BoostTile", "BuffTile", "DamageTrapTile", "GateTile",
                                        "HappeningTile", "HealingTile", "MineTile", "NegMineTile",
                                        "NeutralCreepSpawnTile", "NodeTile", "PassSwapTile", "ResourceTrapTile",
                                        "ReversalTile", "RevolvingDoorTile", "TeleportationTile"];

            const embellishmentTypes:Array = ["TallTree"];

            _tilePane = setupScrollPaneSelect(mapTileTypes, BoardLoader.TILE_CLASS_PREFIX);
            _embPane = setupScrollPaneSelect(embellishmentTypes);

            _tilePane.move(0, DuelParty.stageHeight - _tilePane.height);
            _embPane.move(0, DuelParty.stageHeight - _tilePane.height - _embPane.height);
            addChild(_tilePane);
            addChild(_embPane);
        }

        protected function setupScrollPaneSelect(selects:Array, prefix:String=""):ScrollPane {
            const scrollPaneHeight:Number = 75;
            const tileXSpacing:Number = 80;

            var newPane = new ScrollPane();
            var tileCont:Sprite = new Sprite();
            for (var i:int = 0; i < selects.length; i++) {
                var tileName:String = selects[i];
                var tileBtn:DataButton = new DataButton(tileName);
			    var newBoardTile:Sprite = Utilities.classInstanceFromString(prefix + tileName);
                tileBtn.x = i * tileXSpacing + tileXSpacing/2;
                tileBtn.y = scrollPaneHeight/2;
                tileBtn.addChild(newBoardTile);
                tileCont.addChild(tileBtn);
            }
            newPane.source = tileCont;
            newPane.setSize(DuelParty.stageWidth, scrollPaneHeight);
            addChild(newPane);
            return newPane;
        }

        protected function setupMenu():void {
            const menuYCoord:Number = DuelParty.stageHeight - 200;

            _menu = new MapBuilderMenuButtons();
            _menu.y = menuYCoord;

            addChild(_menu);
        }

        protected function tileSelected(e:MouseEvent):void {
            var sel:DataButton = e.target as DataButton;
            var tileName:String = sel.data as String;
            dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, {action:ACTION_ADD_TILE, tileName:tileName}));
        }

        protected function embSelected(e:MouseEvent):void {
            var sel:DataButton = e.target as DataButton;
            var embName:String = sel.data as String;
            dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, {action:ACTION_ADD_EMB, embName:embName}));
        }

        protected function menuButtonSelected(e:MouseEvent):void {
            if (e.target == _menu.btnCompile) {
                dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, {action:ACTION_COMPILE_MAP}));
            } else if (e.target == _menu.btnLoad) {
                dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, {action:ACTION_LOAD_MAP}));
            } else if (e.target == _menu.btnLoadBG) {
                dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, {action:ACTION_LOAD_BG}));
            } else if (e.target == _menu.btnTileParams) {
                dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, {action:ACTION_TILE_PARAMS}));
            }
        }

        public override function gainedFocus():void {
            super.gainedFocus();
            for (var i:int = 0; i < _tilePane.source.numChildren; i++) {
                FocusManager.getManager().addFocusableListeners(_tilePane.source.getChildAt(i), tileSelected);
            }
            for (i = 0; i < _embPane.source.numChildren; i++) {
                FocusManager.getManager().addFocusableListeners(_embPane.source.getChildAt(i), embSelected);
            }
            FocusManager.getManager().switchFocus(_tilePane.source.getChildAt(0));

            FocusManager.getManager().addGeneralFocusableListener(_menu, menuButtonSelected);
        }

        public override function lostFocus():void {
            super.lostFocus();
            for (var i:int = 0; i < _tilePane.source.numChildren; i++) {
                FocusManager.getManager().removeFocusableListeners(_tilePane.source.getChildAt(i), tileSelected);
            }
            for (i = 0; i < _embPane.source.numChildren; i++) {
                FocusManager.getManager().removeFocusableListeners(_embPane.source.getChildAt(i), embSelected);
            }

            FocusManager.getManager().removeGeneralFocusableListener(_menu, menuButtonSelected);
        }
    }
}