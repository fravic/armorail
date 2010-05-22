package septenary.duelparty {
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.utils.setTimeout;
    import com.greensock.TweenLite;

    public class TurnOrderSelection extends Screen {

        protected var _players:Array;
        protected var _displayForPlayer:Array = new Array();
        protected var _numDispForPlayer:Array = new Array();
        protected var _rollsForPlayers:Array = new Array();
        protected var _queuedPlayerRolls:Array = new Array();
        protected var _turnOrder:Array = new Array();
        protected var _diceRolls:Array = new Array();
        protected var _playersRequiringRoll:Array;
        protected var _rollsDone:int = 0;

        public function TurnOrderSelection(players:Array) {
            super();
            _alwaysOnTop = true;

            _players = players;
            _playersRequiringRoll = _players;
            addPlayerSprites();
            startWithNotification();
        }
        protected function closeScreen(e:GameEvent=null):void {
            dispatchEvent(new GameEvent(GameEvent.ACTION_COMPLETE, {turnOrder:_turnOrder}));
        }

        protected function addPlayerSprites():void {
            const playerSidePostfix:String = "Front";
            const playerY:Number = 350;
            const playerXSpacing:Number = 100;

            var leftmostPlayerX:Number = DuelParty.stageWidth/2 - (playerXSpacing*_players.length)/2;

            for (var i:int = 0; i < _players.length; i++) {
                var disp:Sprite = Utilities.classInstanceFromString((_players[i] as Player).playerData.display
                                                                    + playerSidePostfix);
                disp.x = leftmostPlayerX + playerXSpacing * i;
                disp.y = playerY;
                addChild(disp);

                _displayForPlayer[i] = disp;
            }
        }

        protected function startWithNotification():void {
            showDialogBox(DialogBox.DIALOG_ONLY, {speaker:"Turn Order",
                dialog:"Hey!  Let's start by determining turn order.  Roll teh dice, yo!"}, determineTurnOrder);
            repositionDialogBox();
        }

        public function determineTurnOrder(e:GameEvent=null):void {
            var localPlayerRolling:Boolean = false;
            for (var i:int = 0; i < _playersRequiringRoll.length; i++) {
                if ((_players[i] as Player).playerData.inputSource == NetScreen.PLAYER_INPUT) {
                    if (!localPlayerRolling) localPlayerRolling = true;
                    else {
                        _queuedPlayerRolls.push(i);
                        continue;
                    }
                }
                playerTurnOrderRoll(i);
            }
		}

        protected function playerTurnOrderRoll(playerNum:int):void {
            const dicePlayerSpacing:Number = 80;

            var diceRoll:DiceRoll = new DiceRoll(_players[playerNum]);
            diceRoll.addEventListener(GameEvent.ACTION_COMPLETE, endTurnOrderRoll);
            _diceRolls.push(diceRoll);

            for (var i:int = 0; i < _rollsForPlayers.length; i++) {
                diceRoll.restrictRollNumbers([_rollsForPlayers[i]]);
            }

            diceRoll.x = _displayForPlayer[playerNum].x;
            diceRoll.y = _displayForPlayer[playerNum].y - dicePlayerSpacing;
            pushSuperScreen(diceRoll);
        }

        protected function endTurnOrderRoll(e:GameEvent):void {
            const numDisplayYSpacing:Number = 50;

            _diceRolls.splice(_diceRolls.indexOf(e.target), 1);
            dismissSuperScreen(e.target as Screen);

            for (var i:int = 0; i < _diceRolls.length; i++) {
                (_diceRolls[i] as DiceRoll).restrictRollNumbers([e.data.roll]);
            }

            var playerIndex:int = _players.indexOf(e.data.player);
            _rollsForPlayers[playerIndex] = e.data.roll;
            _rollsDone++;

            var disp:Sprite = _displayForPlayer[playerIndex];
            var numDisp:Sprite = GUIAnimationFactory.createAnimation(GUIAnimationFactory.MOVES_LEFT_COUNTER,
                                    new Point(disp.x, disp.y - numDisplayYSpacing), {movesLeft:e.data.roll}, null);
            _numDispForPlayer[playerIndex] = numDisp;
            addChild(numDisp);

            if ((e.data.player as Player).playerData.inputSource == NetScreen.PLAYER_INPUT &&
                 _queuedPlayerRolls.length > 0) {
                playerTurnOrderRoll(_queuedPlayerRolls[0]);
                _queuedPlayerRolls.splice(0, 1);
            } else if (_rollsDone >= _players.length) {
                setTimeout(allTurnOrderRollsEnded, 1000);
            }
        }

        protected function allTurnOrderRollsEnded():void {
            const lowest:int = -1;
            var queued:int = 0;

            //Check for duplicate rolls
            _playersRequiringRoll = new Array();
            var alreadySeen:Array = new Array();
            for (var i:int = 0; i < _rollsForPlayers.length; i++) {
                if (alreadySeen[_rollsForPlayers[i]]) {
                    var otherPlayer:Player = _players[_rollsForPlayers.indexOf(_rollsForPlayers[i])];
                    if (_playersRequiringRoll.indexOf(otherPlayer) < 0) _playersRequiringRoll.push(otherPlayer);
                    _playersRequiringRoll.push(_players[i]);
                } else {
                    alreadySeen[_rollsForPlayers[i]] = true;
                }
            }
            if (_playersRequiringRoll.length > 0) {
                showDialogBox(DialogBox.DIALOG_ONLY, {speaker:"Turn Order",
                    dialog:"Eh?!  Some of you rolled the same number!  Reroll!"}, determineTurnOrder);
                return;
            }

            while (queued++ < _rollsForPlayers.length) {
                var max:int = lowest, maxIndex:int = lowest;
                for (i = 0; i < _rollsForPlayers.length; i++) {
                    if (_rollsForPlayers[i] > max) {
                        max = _rollsForPlayers[i];
                        maxIndex = i;
                    }
                }
                _turnOrder.push(maxIndex);
                _rollsForPlayers[maxIndex] = lowest;
            }
            nextTurnOrderMessage(0);
        }

        protected function nextTurnOrderMessage(turnOrderNum:int):void {
            const words:Array = ["First", "Second", "Third", "Fourth", "Fifth", "Sixth", "Seventh", "Eighth"];

            if (turnOrderNum >= _players.length) {
                Singleton.get(GameScreen).addEventListener(GameEvent.ACTION_COMPLETE, closeScreen);
                Singleton.get(GameScreen).unDarken();
                return;
            }

            showDialogBox(DialogBox.DIALOG_ONLY, {speaker:"Turn Order",
                dialog:words[turnOrderNum]+" is "+(_players[_turnOrder[turnOrderNum]] as Player).playerData.name+"!",
                turnOrderPlayerNum:turnOrderNum}, teleportPlayerOut);
            repositionDialogBox();     

            removeChild(_numDispForPlayer[_turnOrder[turnOrderNum]]);
        }

        protected function teleportPlayerOut(e:GameEvent):void {
            const playerRotTime:Number = 5;

            var turnOrderNum:int = e.data.dialogBoxData.turnOrderPlayerNum;
            var playerNum:int = _turnOrder[turnOrderNum];
            var disp:Sprite = _displayForPlayer[playerNum];

            var playerRot:TweenLite = TweenLite.to(disp, playerRotTime, {rotation:20000});

            var teleportAnim:TeleportOutAnim = new TeleportOutAnim();
            teleportAnim.x = disp.x;  teleportAnim.y = disp.y;
            addChild(teleportAnim);

            function removePlayerSprite(e:GameEvent):void {
                removeChild(_displayForPlayer[playerNum]);
            }
            function advanceTurnOrderMessages(e:GameEvent):void {
                removeChild(teleportAnim);
                nextTurnOrderMessage(turnOrderNum + 1);
            }
            GameEvent.addAnimFrameListener(teleportAnim, removePlayerSprite, 20);
            GameEvent.addAnimFrameListener(teleportAnim, advanceTurnOrderMessages);
        }

        protected function repositionDialogBox():void {

        }
    }
}