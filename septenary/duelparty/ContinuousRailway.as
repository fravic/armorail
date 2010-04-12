package septenary.duelparty {
    import flash.display.Sprite;

    public class ContinuousRailway extends Sprite {

        public static const RAIL_TYPE_GOLD:int = 0;
        public static const RAIL_TYPE_SILVER:int = 1;

        protected static const RAIL_SIZE:Number = 203;

        protected var _speed:Number;
        protected var _width:Number;
        protected var _scale:Number;
        protected var _size:Number;

        public function ContinuousRailway(width:Number, scale:Number, speed:Number, type:int=RAIL_TYPE_SILVER) {
            super();

            _speed = speed;
            _width = width;
            _scale = scale;
            _size = RAIL_SIZE*scale;

            init(type);
        }

        protected function init(type:int):void {
            const railBuffer:int = 2;

            var numParts:int = (int)(_width/_size) + railBuffer;
            for (var i:int = 0; i < numParts; i++) {
                var part:Sprite;
                if (type == RAIL_TYPE_GOLD) part = new RailComponentGold();
                else part = new RailComponentSilver();

                part.x = -_speed + _size * i + _size/2;
                part.scaleY = part.scaleX = _scale;
                addChild(part);
            }
        }

        public function update():void {
            var totalSize:Number = _size * numChildren;

            for (var i:int = 0; i < numChildren; i++) {
                var part:Sprite = getChildAt(i) as Sprite;
                part.x += _speed;
                if (part.x > _width) {
                    part.x -= totalSize;
                }
            }
        }
    }
}