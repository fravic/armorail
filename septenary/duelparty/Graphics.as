package septenary.duelparty {
    import flash.system.Capabilities;
    import flash.display.DisplayObject;
    import flash.filters.GlowFilter;
    import flash.utils.setTimeout;

	public class Graphics {

        public static function highlightObject(obj:DisplayObject):void {
            var gF:GlowFilter = new GlowFilter(0xFFFFFF, 1, 3, 3, 5);
            var filters:Array = [gF];
            obj.filters = filters;
        }

        public static function unHighlightObject(obj:DisplayObject):void {
            obj.filters = [];
        }

        public static function flashObject(obj:DisplayObject, callback:Function, callbackInterval:Number=200):void {
            const flashStep:Number = 50;
            const numFlashes:int = 3;

            var flashesDone:int = 0;
            var isFlashed:Boolean = false;
            function flash():void {
                if (!isFlashed) {
                    obj.alpha = 0.5;
                    setTimeout(flash, flashStep);
                } else {
                    obj.alpha = 1.0;
                    if (++flashesDone < numFlashes) {
                        setTimeout(flash, flashStep);
                    } else {
                        if (callbackInterval > 0) {
                            setTimeout(callback, callbackInterval);
                        } else {
                            callback();
                        }
                    }
                }
                isFlashed = !isFlashed;
            }
            unHighlightObject(obj);
            flash();
        }

        public static function hexToRGB(hex):Object {
            var red:Number = hex >> 16;
            var greenBlue:Number = hex - (red << 16);
            var green:Number = greenBlue >> 8;
            var blue:Number = greenBlue - (green << 8);
            return({red:red, green:green, blue:blue});
        }

        public static function inchesToPixels(inches:Number):uint {
           return Math.round(Capabilities.screenDPI * inches);
        }

        public static function mmToPixels(mm:Number):uint {
           return Math.round(Capabilities.screenDPI * (mm / 25.4));
        }
    }
}