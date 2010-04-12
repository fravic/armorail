package septenary.duelparty {
    import flash.display.MovieClip;
    import flash.geom.Point;

    public class Sprite3D extends MovieClip {

        private var _rotation:Number = 0;

        public override function set rotation(value:Number):void {
            var angBuffer:Number = 360/(2 * totalFrames);
            var rotFrame:int = Math.floor((Utilities.normalizeDegAngle(-value + angBuffer)/360) * totalFrames) + 1;
            gotoAndStop(rotFrame);
            _rotation = value;
        }

        public override function get rotation():Number {
            return _rotation;
        }
        
        public function set position(value:Point):void {
            x = value.x;
            y = value.y;
        }

        public function Sprite3D() {
            super();
            this.rotation = 0;
            this.cacheAsBitmap = true;
        }
    }
}