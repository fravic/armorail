package septenary.duelparty.screens {    import septenary.duelparty.*;	import flash.display.Sprite;	import flash.events.MouseEvent;	public class FighterSelectionScreen extends NetScreen {        protected var _fighter:Fighter;				public function FighterSelectionScreen(player:Player, fighter:Fighter) {            super(player);            _fighter = fighter;            infoNew.setFighterInfo(fighter);            infoFront.setFighterInfo(player.foreGuard);            infoBack.setFighterInfo(player.rearGuard);						btnReplaceFront.lbl.text = btnReplaceBack.lbl.text = "Replace Weapon";            centerScreen();		}        protected function replaceBtnHandler(e:MouseEvent):void {            replaceFighter(e.target == btnReplaceFront);        }        protected function replaceFighter(onFront:Boolean):void {            if (onFront) {                _player.setFighter(_fighter, true);            } else {                _player.setFighter(_fighter, false);            }            dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE));        }        protected function aiHandler(e:GameEvent):void {            //navigateToAndSelectFocusable(e.data.action.type == AIBehaviour.AI_REPLACE_FRONT_WEAPON ?             //                            btnReplaceFront : btnReplaceBack);            navigateToAndSelectFocusable(btnReplaceBack);        }				protected override function gainedPlayerFocus():void {            super.gainedPlayerFocus();            getFocusManager().addGeneralFocusableListener(this, replaceBtnHandler);        }				protected override function lostPlayerFocus():void {            super.lostPlayerFocus();            getFocusManager()                    .removeGeneralFocusableListener(this, replaceBtnHandler);		}        protected override function gainedAIFocus():void {            super.gainedAIFocus();            getFocusManager().addGeneralFocusableListener(this, replaceBtnHandler);            GameEvent.addOneTimeEventListener(_player.ai, GameEvent.ACTION_COMPLETE, aiHandler);            _player.ai.think([{type:AIBehaviour.AI_REPLACE_FRONT_WEAPON}, {type:AIBehaviour.AI_REPLACE_BACK_WEAPON}]);        }        protected override function lostAIFocus():void {            super.lostAIFocus();            getFocusManager().removeGeneralFocusableListener(this, replaceBtnHandler);        }	}}