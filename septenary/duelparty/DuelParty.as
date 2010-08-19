package septenary.duelparty {
    import septenary.duelparty.screens.*;

	import com.greensock.plugins.*;

    import flash.display.Stage;
	import flash.display.Sprite;
    import flash.display.StageScaleMode;
    import flash.display.StageAlign;
    import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class DuelParty extends Sprite {

        private static const CLASS_INCLUDES:ClassIncludes = new ClassIncludes();

		public static const UPDATE_INTERVAL:int = 33;
        public static var stageWidth:Number;
        public static var stageHeight:Number;
        public static var stage:Stage;

		protected var _currentState:Screen;
		protected var _updateTimer:Timer = new Timer(DuelParty.UPDATE_INTERVAL);

		public function DuelParty():void {
            Singleton.init(this);

            this.stage.scaleMode = StageScaleMode.NO_SCALE;
            this.stage.align = StageAlign.TOP_LEFT;
            this.stage.addEventListener(Event.RESIZE, stageResized);

            DuelParty.stageWidth = stage.stageWidth;
            DuelParty.stageHeight = stage.stageHeight;
            DuelParty.stage = this.stage;

			KeyActions.initialize(stage);
			TweenPlugin.activate([BezierThroughPlugin, BezierPlugin, ShortRotationPlugin]);
			
			_updateTimer.addEventListener(TimerEvent.TIMER, update, false, 0, true);
			_updateTimer.start();

            addChild(new BlackTransitionScreen());

            CONFIG::SINGLE_PLAYER {
                var player1:PlayerData = new PlayerData();
                player1.name = player1.netID = "Fravic";
                player1.display = "PlayerBlue";
                player1.color = 0xFF0000;
                var player2:PlayerData = new PlayerData();
                player2.name = player2.netID = "Fernando";
                player2.display = "PlayerOrange";
                player2.color = 0x0000FF;
                switchState(GameScreen, {boardType:"default", playerDatas:[player1, player2]});
                return;
            }
			switchState(MainMenuScreen, {});
		}
				
		public function update(e:TimerEvent):void {
			_currentState.update();
		}
		
		public function switchState(State:Class, screenData:Object):void {
            trace("SWITCHING STATE!");

			if (_currentState != null) {
                _currentState.lostFocus();
				removeChild(_currentState);
			}
			_currentState = new State(screenData);
            _currentState.gainedFocus();
            Singleton.get(BlackTransitionScreen).setMasked(_currentState);
			addChild(_currentState);
		} 

        protected function stageResized(e:Event):void {
            
        }
	}
}
