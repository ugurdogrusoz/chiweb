/**
* Author: Ebrahim Rajabzadeh
*
* Copyright: i-Vis Research Group, Bilkent University, 2009 - present 
*/

package ivis
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.geom.Point;
	
	import mx.formatters.NumberBaseRoundType;
	import mx.formatters.NumberFormatter;
	
	public class Utils
	{
		
		private static const _formatter: NumberFormatter = new NumberFormatter
		
		// static var initialization
		_formatter.precision = 0
		_formatter.rounding = NumberBaseRoundType.NEAREST
		
		public function Utils()
		{
			throw new Error("abstract class")
		}
		
		public static function formatNumber(n: Object): String
		{
			return _formatter.format(n)
		}
		
		public static function convertPoint(p: Point, src: DisplayObject, dest: DisplayObject): Point
		{
			var t: Point = src.localToGlobal(p)
			return dest.globalToLocal(t)
		}

		public static function boundingRect(points: Array): Object
		{
			var leftmost: * = null;
			var rightmost: * = null;
			var topmost: * = null;
			var bottommost: * = null;
			var top: Number = int.MAX_VALUE
			var left: Number = int.MAX_VALUE
			var right: Number = int.MIN_VALUE
			var bottom: Number = int.MIN_VALUE
			
			for each(var n:* in points)
			{
				if(n.y < top)
				{
					top = n.y
					topmost = n
				}
				if((n.y + n.height) > bottom)
				{
					bottom = n.y + n.height
					bottommost = n
				}
				if(n.x < left)
				{
					left = n.x
					leftmost = n
				}
				if((n.x + n.width) > right)
				{
					right = n.x + n.width
					rightmost = n
				}
			}
			
			return { top: top, left: left, right: right, bottom: bottom,
				topmost: topmost, leftmost: leftmost, rightmost: rightmost, bottommost: bottommost,
				width: Number(right - left), height: Number(bottom - top)}
		}
		
		public static function pointInBounds(x: Number, y: Number, b: Object): Boolean
		{
			return y > b.top && y < b.bottom && x < b.right && x > b.left
		}
		
		public static function copyArray(src: Array, dest: Array): void
		{
			for(var i: int = 0; i < src.length; ++i)
				dest[i] = src[i]
		}
		
		public static function cloneArray(a: Array): Array
		{
			var r: Array = new Array(a.length)
			
			for(var i: int = 0; i < a.length; ++i)
				r[i] = a[i]
				
			return r
		}
		
		public static function merge(a: Array, b: Array): Array
		{
			var res: Array = new Array(a.length + b.length)
			var i: int = 0
			
			for(; i < a.length; ++i)
				res[i] = a[i]

			for(; i < res.length; ++i)
				res[i] = b[i - a.length]
				
								
			return res
		}

		public static function colorToString(color: uint): String
		{
			var res: String = color.toString(16)
			var i: int = res.length
			
			if(i > 6)
				res = res.substr(-6, 6)
			
			while(res.length < 6)
				res = "0" + res
				
			return res
		}
		
		public static function intToRgb(color: uint): Array
		{
			var r: uint = (color & 0x00ff0000) >> 16;
			var g: uint = (color & 0x0000ff00) >> 8;
			var b: uint = (color & 0x000000ff);
			
			return [r, g, b];
		}

		public static function rgbToInt(rgb: Array): uint
		{
			return (0xffff0000 & (rgb[0] << 16)) | (0xff00ff00 & (rgb[1] << 8)) | (0xff0000ff & rgb[2]) 
		}

		public static function colorFromString(s: String): uint
		{
			var re:RegExp = /\s+/;
  			var cs:Array = s.split(re);
  			
  			return cs.length < 3 ? 0 :
  				((uint(cs[0]) + (uint(cs[1]) << 8) + (uint(cs[2]) << 16))) || 0xff000000;
		}
		
		public static function brighter(color: uint, b: int = 10): uint
		{
			var comps: Array = intToRgb(color)
			
			b = Math.min(b, 255  - comps[0], 255  - comps[1], 255  - comps[2]) 
			b = Math.max(b, 0)
			
			comps[0] += b
			comps[1] += b
			comps[2] += b

			return rgbToInt(comps)
		}
		
		public static function drawDashedLine(graphics: Graphics, x1:Number, y1:Number, x2:Number, y2:Number, dashlen:Number, gaplen:Number): void 
		{
			
			var dx: Number = x2 - x1;
			var dy: Number = y2 - y1;
			var m: Number = Math.atan2(dy, dx);
			var ddx: Number = dashlen * Math.cos(m);
			var ddy: Number = dashlen * Math.sin(m);
			var gdx: Number = gaplen * Math.cos(m);
			var gdy: Number = gaplen * Math.sin(m);
			
			var x: Number = x1;
			var y: Number = y1;
			var i: int = Math.sqrt(dx*dx + dy*dy) / (dashlen + gaplen);
			while(i >= 0) {
				graphics.moveTo(x, y);
				x += ddx;
				y += ddy;
				graphics.lineTo(x, y);
				x += gdx;
				y += gdy;
				--i;
			}
		}
		
		public static function randomPartition(n: uint, limit: uint = 0): Array
		{
			var result: Array = new Array
			
			while(n)
			{
				var l: int = (l > 0) ? limit : Math.max(n/4, 1)
				var m: uint = Math.min(Math.ceil(Math.random() * n), l)
				result.push(m)
				n -= m
			}
			
			return result
		}

		public static function stdRandom(): Number
		{
			var u1: Number = Math.random()
			var u2: Number = Math.random()
			
			// needs to be in (0,1]
			if(u1 == 0)
				u1 = 1
			if(u2 == 0)
				u2 = 1
			
			// Box–Muller transform
			return Math.sqrt(-2*Math.log(u1))*Math.cos(2*Math.PI*u2)
		}
		
		public static function isIn(a: Array, o: Object): int
		{
			for(var i: int = 0; i < a.length; ++i)
			{
				if(a[i].equals(o))
					return i
			}
			
			return -1
		}
	}
}