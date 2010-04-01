package septenary.duelparty {    import flash.geom.Rectangle;    import flash.events.EventDispatcher;	public class BattleManager {        protected static var activeManager:BattleManager;		protected var _callback:Function;        protected var _curOffense:Fightmaster;        protected var _curTile:BoardTile;        protected var _playersBattled:Array;        protected var _curBattlePlayer:Fightmaster;        protected var _battleStage:int;  //First attack, first counter, second attack, second counter... etc...        public static function getBattleManager():BattleManager {            if (!activeManager) {                activeManager = new BattleManager();            }            return activeManager;        }        public function BattleManager():void {            if (activeManager) Utilities.assert(false, "Double instantiation of singleton BattleManager.");        }		public function startBattle(attacker:Fightmaster, tile:BoardTile, callback:Function):void {			_callback = callback;            _curOffense = attacker;            _curTile = tile;            _playersBattled = new Array();            _battleStage = 0;            			//Don't start the battle if there is no attack fighter			if (!_curOffense.getForeGuard() || !_curOffense.getForeGuard().attack) {				endBattle();				return;			}            GameEvent.addOneTimeEventListener(GameInterface.getGameInterface(), GameEvent.ACTION_COMPLETE,                                               nextPlayerInBattleOrder);			GameInterface.getGameInterface().playBattleNotice();		}        protected function nextPlayerInBattleOrder(e:GameEvent=null):void {            if (_curTile.residents.length - _playersBattled.length > 1) {                var playerChoice:PlayerChoice = new PlayerChoice(_curOffense as Player,                                                                 _curTile.residents, "Select a player to attack.");                GameEvent.addOneTimeEventListener(playerChoice, GameEvent.ACTION_COMPLETE, nextBattlePlayerSelected);				GameScreen.getGameScreen().pushSuperScreen(playerChoice);            } else {                //Select last remaining player                for (var i:int = 0; i < _curTile.residents.length; i++) {                    if (_playersBattled.indexOf(_curTile.residents[i]) < 0) {                        pushNextBattleFightmaster(_curTile.residents[i]);                        break;                    }                }                battleFight();            }        }        protected function pushNextBattleFightmaster(fightable:Fightmaster):void {            _playersBattled.push(fightable);            _curBattlePlayer = fightable;        }        protected function nextBattlePlayerSelected(e:GameEvent):void {            GameScreen.getGameScreen().dismissSuperScreen(e.target as Screen);            pushNextBattleFightmaster(e.data.player);            battleFight();        }				protected function battleFight(e:GameEvent=null):void {			//Play battle animations			var fighters:Object = getFighters();			if (fighters.attacker) {				//Null counter?				if (isCounterStage() && !fighters.attacker.counter) {					battleContinue();				} else {                    GameEvent.addOneTimeEventListener(fighters.attacker, GameEvent.ACTION_COMPLETE, battleDamage);					fighters.attacker.attackAnim(getFightmasters().defender, getDamageDirections().defenderOnFront);				}			} else {				battleContinue();			}		}				protected function battleDamage(e:GameEvent):void {			var fighters:Object = getFighters();			var damage:Number = !isCounterStage() ? fighters.attacker.attack : fighters.attacker.counter;			var curDefender:Fightmaster = getFightmasters().defender;            GameEvent.addOneTimeEventListener(curDefender, GameEvent.DAMAGE_DONE, battleDamageDone);            curDefender.damage(damage, getDamageDirections().defenderOnFront, isCounterStage());		}        protected function battleDamageDone(e:GameEvent):void {            var bounty:Object = e.target.payoutBounty();            if (_curTile.residents.indexOf(e.target) < 0) _curBattlePlayer = null;            if (bounty != null) {                battleBounty(getFightmasters().attacker, bounty);            } else {			    battleContinue();            }        }        protected function battleBounty(fightable:Fightmaster, bounty:Object):void {            for (var key:String in bounty) {                if (key != "coins") (fightable as Player).gameStats[key] += bounty[key];            }            if (!(fightable is Player) || !bounty.coins) {                battleContinue();                return;            }            GameEvent.addOneTimeEventListener(fightable, GameEvent.PLAYER_COINS_MODIFIED, battleBountyPaid);			(fightable as Player).giveCoins(bounty.coins);        }        protected function battleBountyPaid(e:GameEvent):void {            battleContinue();        }				protected function battleContinue():void {			//If the last attack was standard, try to counter...			var fighters:Object = getFighters();			if (!isCounterStage() && fighters.defender) {				_battleStage++;				battleFight();				return;			}						//...Otherwise, if there are more residents, attack next...            isCounterStage() ? _battleStage++ : _battleStage += 2;  //Skip the counter stage if necessary			if (_playersBattled.length < _curTile.residents.length) {				nextPlayerInBattleOrder();				return;			}						//...Otherwise, end the battle			endBattle();		}				protected function endBattle():void {			if (GameBoard.getGameBoard().gameOver) {				return;			}			_callback();		}        protected function getTargetArea():Rectangle {            return new Rectangle();        }        protected function getDamageDirections():Object {            var curDefense:Fightmaster = getCurDefenseWOCounter();            var dirsWOCounter:Object = new Object();            if (!curDefense || _curOffense.isFacingForward() == curDefense.isFacingForward()) {                dirsWOCounter = {attackerOnFront:true, defenderOnFront:false}            } else {                dirsWOCounter = {attackerOnFront:true, defenderOnFront:true}            }            if (!isCounterStage()) {                return {attackerOnFront:dirsWOCounter.attackerOnFront, defenderOnFront:dirsWOCounter.defenderOnFront};            } else {                return {attackerOnFront:dirsWOCounter.defenderOnFront, defenderOnFront:dirsWOCounter.attackerOnFront};            }        }				protected function getFighters():Object {            var fightables:Object = getFightmasters();            var damageDirs:Object = getDamageDirections();            var fighters:Object = new Object();            fighters.attacker = fightables.attacker ? damageDirs.attackerOnFront ? fightables.attacker.getForeGuard() :                                                                                   fightables.attacker.getRearGuard() :                                                      null;            fighters.defender = fightables.defender ? damageDirs.defenderOnFront ? fightables.defender.getForeGuard() :                                                                                   fightables.defender.getRearGuard() :                                                      null;            return fighters;		}        protected function getFightmasters():Object {            var curDefense:Fightmaster = getCurDefenseWOCounter();            if (!isCounterStage()) {                return {attacker:_curOffense, defender:curDefense};            } else {                return {attacker:curDefense, defender:_curOffense};            }        }        protected function getCurDefenseWOCounter():Fightmaster {            return _curBattlePlayer;        }        protected function isCounterStage():Boolean {            return (Boolean)(_battleStage % 2);        }	}}