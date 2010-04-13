package septenary.duelparty {	import flash.geom.Point;    import flash.geom.Rectangle;	import flash.utils.getDefinitionByName;    import flash.system.Capabilities;    import flash.display.DisplayObject;    import flash.display.DisplayObjectContainer;    import flash.display.MovieClip;    import flash.filters.GlowFilter;    import flash.utils.setTimeout;	public class Utilities {		public static const RADS_TO_DEG:Number = 180 / Math.PI;		public static function roundToDecimals(n:Number, d:int):Number {			var f:Number = Math.pow(10, d);			return Math.round(n * f) / f;		}		public static function magnitude(pt:Point):Number {			return Math.sqrt(pt.x * pt.x + pt.y * pt.y);		}		public static function magSquared(pt:Point):Number {			return pt.x * pt.x + pt.y * pt.y;		}		public static function sign(n:Number):int {			return n >= 0 ? 1 : -1;		}        public static function randomBounded(min:Number, max:Number):Number {            return Math.random() * (max - min) + min;        }		public static function randomPointOnCircle(r:Number):Point {			//Get a random angle around the circle			var theta:Number = Math.random() * (2 * Math.PI);			return new Point(r * Math.cos(theta), r * Math.sin(theta));		}		public static function normalizeDegAngle(a:Number):Number {			while (a < 0)				a += 360;			while (a > 360)				a -= 360;			return a;		}        public static function normalizeRadAngle(a:Number):Number {			while (a < 0)				a += 2 * Math.PI;			while (a >= 2 * Math.PI)				a -= 2 * Math.PI;			return a;		}		public static function angleDiff(a:Number, b:Number):Number {			var norm:Number = normalizeRadAngle(Math.abs(a - b));			if (norm > Math.PI) {				return 2 * Math.PI - norm;			} else {				return norm;			}		}        public static function shortRotation(from:Number, to:Number):int {            assert(from - to < 2 * Math.PI && from - to > -2 * Math.PI, "Attempt to short unormalized angles!");            var big:Number = Math.max(from, to);            var small:Number = Math.min(from, to);            var clkDist:Number = big - small;            var cntDist:Number = 2 * Math.PI - big + small;            if (clkDist < cntDist) {                if (small == from) {                    return 1;                } else {                    return -1;                }            } else {                if (small == from) {                    return -1;                } else {                    return 1;                }            }        }		public static function classInstanceFromString(s:String):* {			var newClass:Class = getDefinitionByName(s) as Class;			return new newClass();		}		public static function pointFromString(s:String):Point {			var nums:Array = s.match(/\d+(.\d+)*/g);			if (!nums || nums.length != 2)				return null;			return new Point(Number(nums[0]), Number(nums[1]));		}		public static function parseXMLValue(val:XML):* {			//Parse string			var str:String = val.toString();			//Parse numeric			var num:Number = Number(str);			if (!isNaN(num))				return num;			//Parse boolean			if (str == "true")				return true;			if (str == "false")				return false;			//Parse point			var pt:Point = pointFromString(str);			if (pt)				return pt;			return str;		}		public static function asciiCodeFromNum(n:int):int {			return n + 48;		}        public static function keepPointInBounds(pt:Point, bounds:Rectangle):void {            if (pt.x < bounds.x) {				pt.x = bounds.x;			} else if (pt.x > bounds.width) {				pt.x = bounds.width;			}			if (pt.y < bounds.y) {				pt.y = bounds.y;			} else if (pt.y > bounds.height) {				pt.y = bounds.height;			}        }        public static function rocket(targ:Object, src:Object, props:Array):void {            for (var i:int = 0; i < props.length; i++) {                if (src[props[i]]) targ[props[i]] = src[props[i]];            }        }        public static function inchesToPixels(inches:Number):uint {           return Math.round(Capabilities.screenDPI * inches);        }        public static function mmToPixels(mm:Number):uint {           return Math.round(Capabilities.screenDPI * (mm / 25.4));        }        public static function highlightObject(obj:DisplayObject):void {            var gF:GlowFilter = new GlowFilter(0xFFFFFF, 1, 3, 3, 5);            var filters:Array = [gF];            obj.filters = filters;        }        public static function unHighlightObject(obj:DisplayObject):void {            obj.filters = [];        }        public static function flashObject(obj:DisplayObject, callback:Function):void {            const flashStep:Number = 50;            const numFlashes:int = 3;            const callbackInterval:Number = 200;            var flashesDone:int = 0;            var isFlashed:Boolean = false;            function flash():void {                if (!isFlashed) {                    obj.alpha = 0.5;                    setTimeout(flash, flashStep);                } else {                    obj.alpha = 1.0;                    if (++flashesDone < numFlashes) {                        setTimeout(flash, flashStep);                    } else {                        setTimeout(callback, callbackInterval);                    }                }                isFlashed = !isFlashed;            }            unHighlightObject(obj);            flash();        }        public static function hexToRGB(hex):Object {            var red:Number = hex >> 16;            var greenBlue:Number = hex - (red << 16);            var green:Number = greenBlue >> 8;            var blue:Number = greenBlue - (green << 8);            return({red:red, green:green, blue:blue});        }        public static function assert(cond:Boolean, message:String="General assertion."):void {            CONFIG::DEBUG {                if (!cond) {                    throw new Error("Assertion Failed: " + message);                }            }        }	}}