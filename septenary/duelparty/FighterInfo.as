package septenary.duelparty {
    import flash.display.MovieClip;
    import flash.display.DisplayObject;

    public class FighterInfo extends MovieClip {

        protected var _fighter:Fighter;

        public function get fighter():Fighter {
            return _fighter;
        }

        public function setFighterInfo(fighter:Fighter, bgVisible:Boolean=false):void {
            _fighter = fighter;
            if (!fighter) {
                setNullMessage();
                return;
            }
            nullMsg.visible = false;
            lblName.text = fighter.fighterName.toString();
			lblAttack.text = fighter.attack.toString();
			lblCounter.text = fighter.counter.toString();
			lblHealth.text = fighter.health.toString();
            lblUpkeep.text = fighter.upkeep.toString();
			lblSpecial.text = fighter.specialDesc;
            bg.visible = bgVisible;
        }

        protected function setNullMessage():void {
            for (var i:int = 0; i < numChildren; i++) {
                this.getChildAt(i).visible = false;
            }
            nullMsg.visible = true;
            mcPortraitBack.visible = true;
        }
    }
}