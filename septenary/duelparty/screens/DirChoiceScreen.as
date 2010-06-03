package septenary.duelparty.screens {
    import septenary.duelparty.*;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.utils.Dictionary;

	public class DirChoiceScreen extends NetScreen {

        protected var _tile:BoardTile;
		protected var _choiceArrows:Array = new Array();
		protected var _choiceIndices:Dictionary = new Dictionary();
		
		public function DirChoiceScreen(player:Player, tile:BoardTile) {
			super(player);

            _tile = tile;

			placeChoiceArrows(tile);
			
			x = tile.x;
			y = tile.y;
		}

        protected function getMoveTiles(tile:BoardTile):Array {
            var tilesRef:Array;
			if (_player.movement.moveDirForward) {
				tilesRef = tile.tilesOut;
			} else {
				tilesRef = tile.tilesIn;
			}
            return tilesRef;
        }
		
		protected function placeChoiceArrows(tile:BoardTile):void {
			const dirArrowDist:Number = 45;
			
			var tilesRef:Array = getMoveTiles(tile);
			for (var i:int = 0; i < tilesRef.length; i++) {
				var outTile:BoardTile = tilesRef[i];
				var choiceArrow:Sprite = new DirChoiceArrow();
				var arrowAngle:Number = Math.atan2(outTile.y - tile.y, outTile.x - tile.x);
				choiceArrow.rotation = arrowAngle * 180 / Math.PI;
				choiceArrow.x = dirArrowDist * Math.cos(arrowAngle);
				choiceArrow.y = dirArrowDist * Math.sin(arrowAngle);
				_choiceArrows.push(addChild(choiceArrow));
				_choiceIndices[choiceArrow] = i;
			}
		}
		
		protected function selectChoiceArrow(choiceArrow:DirChoiceArrow):void {
            dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE,
                                       {player:_player, index:_choiceIndices[choiceArrow]}));
		}
		
		protected function choiceArrowDown(e:MouseEvent):void {
			selectChoiceArrow(e.target as DirChoiceArrow);
		}

        protected function aiHandler(e:GameEvent):void {
            navigateToAndSelectFocusable(_choiceArrows[e.data.action.tileIndex]);
        }
		
		protected override function gainedPlayerFocus():void {
            super.gainedPlayerFocus();
            getFocusManager().addGeneralFocusableListener(this, choiceArrowDown);
		}
		
		protected override function lostPlayerFocus():void {
            super.lostPlayerFocus();
            getFocusManager().removeGeneralFocusableListener(this, choiceArrowDown);
		}

        protected override function gainedAIFocus():void {
            super.gainedAIFocus();
            getFocusManager().addGeneralFocusableListener(this, choiceArrowDown);

            GameEvent.addOneTimeEventListener(_player.ai, GameEvent.ACTION_COMPLETE, aiHandler);

            //Get direction choice options
            var options:Array = new Array();
			var tilesRef:Array = getMoveTiles(_tile);
            for (var i:int = 0; i < tilesRef.length; i++) {
                var tileOption:Object = {type:AIBehaviour.AI_DIR_CHOICE,
                                         tileIndex:getMoveTiles(_tile).indexOf(tilesRef[i])};
                options.push(tileOption);
            }

            _player.ai.think(options);
        }

        protected override function lostAIFocus():void {
            super.lostAIFocus();
            getFocusManager().removeGeneralFocusableListener(this, choiceArrowDown);
        }
	}
}