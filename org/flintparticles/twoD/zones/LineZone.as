/*
 * FLINT PARTICLE SYSTEM
 * .....................
 * 
 * Author: Richard Lord
 * Copyright (c) Richard Lord 2008-2009
 * http://flintparticles.org
 * 
 * 
 * Licence Agreement
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package org.flintparticles.twoD.zones 
{
	import flash.geom.Point;	

	/**
	 * The LineZone zone defines a zone that contains all the points on a line.
	 */

	public class LineZone implements Zone2D 
	{
		private var _start:Point;
		private var _end:Point;
		private var _length:Point;
		
		/**
		 * The constructor creates a LineZone zone.
		 * 
		 * @param start The point at one end of the line.
		 * @param end The point at the other end of the line.
		 */
		public function LineZone( start:Point = null, end:Point = null )
		{
			if( start == null )
			{
				_start = new Point( 0, 0 );
			}
			else
			{
				_start = start;
			}
			if( end == null )
			{
				_end = new Point( 0, 0 );
			}
			else
			{
				_end = end;
			}
			_length = _end.subtract( _start );
		}
		
		/**
		 * The point at one end of the line.
		 */
		public function get start() : Point
		{
			return _start;
		}

		public function set start( value : Point ) : void
		{
			_start = value;
			_length = _end.subtract( _start );
		}

		/**
		 * The point at the other end of the line.
		 */
		public function get end() : Point
		{
			return _end;
		}

		public function set end( value : Point ) : void
		{
			_end = value;
			_length = _end.subtract( _start );
		}

		/**
		 * The x coordinate of the point at the start of the line.
		 */
		public function get startX() : Number
		{
			return _start.x;
		}

		public function set startX( value : Number ) : void
		{
			_start.x = value;
			_length = _end.subtract( _start );
		}

		/**
		 * The y coordinate of the point at the start of the line.
		 */
		public function get startY() : Number
		{
			return _start.y;
		}

		public function set startY( value : Number ) : void
		{
			_start.y = value;
			_length = _end.subtract( _start );
		}

		/**
		 * The x coordinate of the point at the end of the line.
		 */
		public function get endX() : Number
		{
			return _end.x;
		}

		public function set endX( value : Number ) : void
		{
			_end.x = value;
			_length = _end.subtract( _start );
		}

		/**
		 * The y coordinate of the point at the end of the line.
		 */
		public function get endY() : Number
		{
			return _end.y;
		}

		public function set endY( value : Number ) : void
		{
			_end.y = value;
			_length = _end.subtract( _start );
		}

		/**
		 * The contains method determines whether a point is inside the zone.
		 * This method is used by the initializers and actions that
		 * use the zone. Usually, it need not be called directly by the user.
		 * 
		 * @param x The x coordinate of the location to test for.
		 * @param y The y coordinate of the location to test for.
		 * @return true if point is inside the zone, false if it is outside.
		 */
		public function contains( x:Number, y:Number ):Boolean
		{
			// not on line if dot product with perpendicular is not zero
			if ( ( x - _start.x ) * _length.y - ( y - _start.y ) * _length.x != 0 )
			{
				return false;
			}
			// is it between the points, dot product of the vectors towards each point is negative
			return ( x - _start.x ) * ( x - _end.x ) + ( y - _start.y ) * ( y - _end.y ) <= 0;
		}
		
		/**
		 * The getLocation method returns a random point inside the zone.
		 * This method is used by the initializers and actions that
		 * use the zone. Usually, it need not be called directly by the user.
		 * 
		 * @return a random point inside the zone.
		 */
		public function getLocation():Point
		{
			var ret:Point = _start.clone();
			var scale:Number = Math.random();
			ret.x += _length.x * scale;
			ret.y += _length.y * scale;
			return ret;
		}
		
		/**
		 * The getArea method returns the size of the zone.
		 * This method is used by the MultiZone class. Usually, 
		 * it need not be called directly by the user.
		 * 
		 * @return a random point inside the zone.
		 */
		public function getArea():Number
		{
			// treat as one pixel tall rectangle
			return _length.length;
		}
	}
}
