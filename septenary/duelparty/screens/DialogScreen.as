package septenary.duelparty.screens {
    import septenary.duelparty.*;
    import septenary.duelparty.ui.*;

    import flash.display.Sprite;
    import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;

    public class DialogScreen extends NetScreen {
                                                         
        public static const DIALOG_ONLY:String = "DialogBoxOnly";
        public static const YES_NO_SELECT:String = "DialogBoxYesNo";
		public static const YES_NO_SHOP:String = "DialogBoxYesNoShop";
        public static const TEXT_INPUT:String = "DialogBoxTextInput";
        public static const SHOP_TIER_SELECT:String = "DialogBoxShopTier";
        public static const DATA_GRID:String = "DialogBoxDataGrid";

        protected const DIALOG_BOX_WIDTH:Number = 400;

        protected var _type:String;
        protected var _data:Object;
        protected var _content:Sprite;

        public function DialogScreen(type:String, data:Object) {
            //Give the specified player control of the dialog box
            super(data.player ? data.player : null);  

            _type = type;
            _data = data;

            if (_data.speaker) tFSpeaker.text = _data.speaker;
            if (_data.dialog) tFDialog.text = _data.dialog;
			tFDialog.autoSize = TextFieldAutoSize.CENTER;
            _content = Utilities.classInstanceFromString(type);
            mcContentArea.addChild(_content);

            if (this["setup" + type]) this["setup" + type]();

			setupBackground();
            centerScreen();
        }

        /* DIALOG ONLY */

        protected function setupDialogBoxOnly():void {
			var dBContent:DialogBoxOnly = _content as DialogBoxOnly;
			dBContent.btnOk.lbl.text = "Continue";
        }

        protected function eventDialogBoxOnly(e:MouseEvent):void {
            if (this.hasPlayerFocus() && _player != null) {
                Singleton.get(NetworkManager).sendMessage(NetworkMessage.DIALOG_BOX,
                                                   {playerNetID:_player.playerData.netID});
            }

            dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, {dialogBoxData:_data}));
        }

        protected function aiOptionsForDialogBoxOnly():Array {
            return [{type:AIBehaviour.AI_CLOSE_DIALOG}];
        }

        protected function aiEventDialogBoxOnly(e:GameEvent):void {
            navigateToAndSelectFocusable((_content as DialogBoxOnly).btnOk);
        }

        /* YES OR NO */

        protected function setupDialogBoxYesNo():void {
            var dBContent:DialogBoxYesNo = _content as DialogBoxYesNo;
			dBContent.btnYes.lbl.text = "Yes";
			dBContent.btnNo.lbl.text = "No";
        }

        protected function eventDialogBoxYesNo(e:MouseEvent):void {
            var dBContent:DialogBoxYesNo = _content as DialogBoxYesNo;
            dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, {dialogBoxData:_data,
                                                                    yes:(e.target == dBContent.btnYes)}));
        }

        /* YES OR NO WITH SHOPPING */
		
		protected function setupDialogBoxYesNoShop():void {
			var dBContent:DialogBoxYesNoShop = _content as DialogBoxYesNoShop;
			dBContent.btnYes.lbl.text = "Pay";
			dBContent.btnYes.lblCoins.text = "-"+_data.cost;
			dBContent.btnNo.lbl.text = "Don't Buy";
			dBContent.lblCoins.text = "x "+_data.player.coins;
		}
		
		protected function eventDialogBoxYesNoShop(e:MouseEvent):void {
            var dBContent:DialogBoxYesNoShop = _content as DialogBoxYesNoShop;

            if (this.hasPlayerFocus() && _player != null) {
                Singleton.get(NetworkManager).sendMessage(NetworkMessage.DIALOG_BOX,
                                                   {playerNetID:_player.playerData.netID,
                                                    type:(e.target == dBContent.btnYes ? AIBehaviour.AI_SHOP_YES : 
                                                                                         AIBehaviour.AI_CLOSE_DIALOG)});
            }

            dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, {dialogBoxData:_data,
                                                                    yes:(e.target == dBContent.btnYes)}));
        }

        protected function aiOptionsForDialogBoxYesNoShop():Array {
            return [{type:AIBehaviour.AI_SHOP_YES}, {type:AIBehaviour.AI_CLOSE_DIALOG}];
        }

        protected function aiEventDialogBoxYesNoShop(e:GameEvent):void {
            var data:Object = {dialogBoxData:_data};
            switch(e.data.action.type) {
                case AIBehaviour.AI_SHOP_YES:
                    navigateToAndSelectFocusable((_content as DialogBoxYesNoShop).btnYes);
                    break;
                case AIBehaviour.AI_CLOSE_DIALOG:
                    navigateToAndSelectFocusable((_content as DialogBoxYesNoShop).btnNo);
                    break;
            }
        }

        /* TIERED FIGHTER SHOPPING */

        protected function setupDialogBoxShopTier():void {
            var dBContent:DialogBoxShopTier = _content as DialogBoxShopTier;
			const tierButtons:Array = [dBContent.btnTier1, dBContent.btnTier2, dBContent.btnTier3];

			for (var i:int = 0; i < tierButtons.length; i++) {
            	if (_data.player.coins < _data.costs[i]) getFocusManager()
                                                            .disableFocusable(tierButtons[i]);
				tierButtons[i].lbl.text = "Tier "+(i + 1);
				tierButtons[i].lblCoins.text = "-" + _data.costs[i];
			}
            dBContent.lblCoins.text = "x " + _data.player.coins;
			dBContent.btnNo.lbl.text = "Don't Buy";
        }

        protected function eventDialogBoxShopTier(e:MouseEvent):void {
            var data:Object = {tier:0, dialogBoxData:_data};
            var dBContent:DialogBoxShopTier = _content as DialogBoxShopTier;

            if (e.target == dBContent.btnTier1) data.tier = 1;
            else if (e.target == dBContent.btnTier2) data.tier = 2;
            else if (e.target == dBContent.btnTier3) data.tier = 3;

            if (this.hasPlayerFocus() && _player != null) {
                Singleton.get(NetworkManager).sendMessage(NetworkMessage.DIALOG_BOX,
                                                   {playerNetID:_player.playerData.netID,
                                                    type:(data.tier != 0 ? AIBehaviour.AI_SHOP_TIER :
                                                                           AIBehaviour.AI_CLOSE_DIALOG),
                                                    tier:data.tier});
            }

            dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, data));
        }

        protected function aiOptionsForDialogBoxShopTier():Array {
            var options:Array = [{type:AIBehaviour.AI_CLOSE_DIALOG}];
            for (var i:int = 0; i < 3; i++) {
            	if (_data.player.coins >= _data.costs[i]) {
                    options.push({type:AIBehaviour.AI_SHOP_TIER, tier:(i + 1)});
                }
			}
            return options;
        }

        protected function aiEventDialogBoxShopTier(e:GameEvent):void {
            switch(e.data.action.type) {
                case AIBehaviour.AI_CLOSE_DIALOG:
                    navigateToAndSelectFocusable((_content as DialogBoxShopTier).btnNo);
                    break;
                case AIBehaviour.AI_SHOP_TIER:
                    switch (e.data.action.tier) {
                        case 1:
                            navigateToAndSelectFocusable((_content as DialogBoxShopTier).btnTier1);
                            break;
                        case 2:
                            navigateToAndSelectFocusable((_content as DialogBoxShopTier).btnTier2);
                            break;
                        case 3:
                            navigateToAndSelectFocusable((_content as DialogBoxShopTier).btnTier3);
                            break;
                        default:
                            Utilities.assert(false, "Invalid AI tier selection!");
                            break;
                    }
                    break;
            }
        }

        /* TEXT INPUT */

        protected function setupDialogBoxTextInput():void {
			var dBContent:DialogBoxTextInput = _content as DialogBoxTextInput;
            var fldText:FocusableTextField = (_content as DialogBoxTextInput).fldText;
            fldText.init(fldText.tF, fldText.tFPrompt);
			dBContent.btnOk.lbl.text = "Continue";
			trace(dBContent.btnOk.lbl.text);
        }

        protected function eventDialogBoxTextInput(e:MouseEvent):void {
            var dBContent:DialogBoxTextInput = _content as DialogBoxTextInput;
            var retText:String = dBContent.tFText.text;
            if (retText.charAt(retText.length -1) == " ") retText = retText.substr(0, retText.length - 1);
            dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, {dialogBoxData:_data, text:retText}));
        }

        /* DATA GRID */

        protected function setupDialogBoxDataGrid():void {
            const rowSpacing:Number = 10;
            var dBContent:DialogBoxDataGrid = _content as DialogBoxDataGrid;

            var lastRowY:Number = 0;
            for (var dataFieldName:String in _data.dataFields) {
                var row:DialogBoxDataGridRow = new DialogBoxDataGridRow();
                row.tFLabel.text = dataFieldName;
                row.tFInput.text = _data.dataFields[dataFieldName];
                row.y = lastRowY;
                _content.addChild(row);

                FocusableTextField.createFocusableTextField(row.tFInput);
                lastRowY += row.height + rowSpacing;
            }

            (_content as DialogBoxDataGrid).btnOk.y = lastRowY;
			dBContent.btnOk.lbl.text = "Continue";
        }

        protected function eventDialogBoxDataGrid(e:MouseEvent):void {
            var data:Object = {dialogBoxData:_data};
            data.dataGrid = new Object();

            for (var i:int = 0; i < _content.numChildren; i++) {
                if (_content.getChildAt(i) is DialogBoxDataGridRow) {
                    var row:DialogBoxDataGridRow = _content.getChildAt(i) as DialogBoxDataGridRow;
                    data.dataGrid[row.tFLabel.text] = row.tFInput.text;
                }
            }

            dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, data));
        }

        /* COMMON HANDLERS */
		
		protected function setupBackground():void {
			const bgTextAreaPadding:Number = 5;
			const minTextAreaHeight:Number = 48;
			const contentAreaPadding:Number = 16;
			const bottomPadding:Number = -6;
			const centerOverlapRatio:Number = .02;
			
			bgTextArea.height = Math.max(minTextAreaHeight, tFDialog.height + bgTextAreaPadding);
			mcContentArea.y = bgTextArea.y + bgTextArea.height + contentAreaPadding;
			bgBottom.y = mcContentArea.y + mcContentArea.height + bottomPadding;
			bgCenter.height = bgBottom.y - bgCenter.y;
			bgCenter.height *= (1 + centerOverlapRatio);
		}

        protected function aiHandler(e:GameEvent):void {
            this["aiEvent" + _type](e);
        }

        protected function netMessageHandler(e:GameEvent):void {
            if (e.data.type == NetworkMessage.DIALOG_BOX && e.data.vars.playerNetID == _player.playerData.netID) {
                Singleton.get(NetworkManager).claimMessage(e.data);
                var syntheticEvent:GameEvent = new GameEvent(GameEvent.NETWORK_MESSAGE,
                    {action:{type:e.data.vars.type, tier:e.data.vars.tier}});
                this["aiEvent" + _type](syntheticEvent);
            }
        }

        protected override function gainedPlayerFocus():void {
            super.gainedPlayerFocus();
            getFocusManager().addGeneralFocusableListener(_content, this["event" + _type]);
		}

		protected override function lostPlayerFocus():void {
            super.lostPlayerFocus();
            getFocusManager().removeGeneralFocusableListener(_content, this["event" + _type]);
		}

        protected override function gainedAIFocus():void {
            super.gainedAIFocus();
            getFocusManager().addGeneralFocusableListener(_content, this["event" + _type]);

            GameEvent.addOneTimeEventListener(_player.ai, GameEvent.ACTION_COMPLETE, aiHandler);
            _player.ai.think(this["aiOptionsFor" + _type]());
        }

        protected override function lostAIFocus():void {
            super.lostAIFocus();
            getFocusManager().removeGeneralFocusableListener(_content, this["event" + _type]);
        }

        protected override function gainedNetFocus():void {
            super.gainedNetFocus();
            getFocusManager().addGeneralFocusableListener(_content, this["event" + _type]);
			Singleton.get(NetworkManager).addEventListener(GameEvent.NETWORK_MESSAGE, netMessageHandler);
            Singleton.get(NetworkManager).dispatchQueuedMessages();
		}

        protected override function lostNetFocus():void {
            super.lostNetFocus();
            getFocusManager().removeGeneralFocusableListener(_content, this["event" + _type]);
			Singleton.get(NetworkManager).removeEventListener(GameEvent.NETWORK_MESSAGE, netMessageHandler);
        }
    }
}