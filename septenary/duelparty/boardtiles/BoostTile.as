﻿package septenary.duelparty.boardtiles {	import septenary.duelparty.*;	public class BoostTile extends BoardTile {        protected var _boostCost:int = 5;        protected var _boostAmount:int = 1;        public function get boostCost():int {            return _boostCost;        }        public function set boostCost(value:int):void {            _boostCost = value;        }        public function get boostAmount():int {            return _boostAmount;        }        public function set boostAmount(value:int):void {            _boostAmount = value;        }        public static function getParamFields():Array {            return ["boostCost", "boostAmount"];        }		public function BoostTile() {			_reducesMoveCount = false;			_activateOnPass = true;		}		public override function activate(player:Player, onPass:Boolean=false):void {			super.activate(player);            function boostOrNot(e:GameEvent):void {                if (e.data.yes) {                    GameEvent.addOneTimeEventListener(player, GameEvent.PLAYER_COINS_MODIFIED, playerCoinsTaken);                    player.takeCoins(_boostCost);                } else {                    activateDone(player);                }            }            function playerCoinsTaken(e:GameEvent):void {                GameInterface.getGameInterface().showDialogBox(DialogBox.DIALOG_ONLY,                    {speaker:"Gate Tile", dialog:"Hah!  You gots scammed!", player:player}, boostPlayer);            }            function boostPlayer(e:GameEvent):void {                GameEvent.addOneTimeEventListener(player, GameEvent.ACTION_COMPLETE, doneBoostSelection);                player.boostMoveCount(_boostAmount);            }            if (player.coins >= _boostCost) {                GameInterface.getGameInterface().showDialogBox(DialogBox.YES_NO_SHOP, {speaker:"Boost Tile",                                                    dialog:"Pay meh "+_boostCost+" money and I'll boost you!",                                                    player:player, cost:_boostCost}, boostOrNot);            } else {                GameInterface.getGameInterface().showDialogBox(DialogBox.DIALOG_ONLY, {speaker:"Boost Tile",                                                    dialog:"You need "+_boostCost+" money to boost!",                                                    player:player, cost:_boostCost}, boostOrNot);            }		}		protected function doneBoostSelection(e:GameEvent):void {			activateDone(e.data as Player);		}	}}