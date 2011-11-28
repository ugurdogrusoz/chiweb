package ivis.util
{
	import flash.geom.Point;

	public class GeometryUtils
	{
		//-----------------------CONSTRUCTOR------------------------------------
		
		public function GeometryUtils()
		{
			throw new Error("GeometryUtils is an abstract class.");
		}
		
		//---------------------- PUBLIC FUNCTIONS ------------------------------
		
		/**
		 * Taken from the Utils class of CytoscapeWeb project.
		 * 
		 * Code found here:
		 * http://keith-hair.net/blog/2008/08/05/line-to-circle-intersection-data/
		 * 
		 * @param A The start point of the line.
		 * @param B The end point of the line.
		 * @param C The center of the circle.
		 * @param r The radius of the circle.
		 * @return An Object with the following properties:
		 *   enter       -Intersection Point entering the circle.
		 *   exit        -Intersection Point exiting the circle.
		 *   inside      -Boolean indicating if the points of the line are inside the circle.
		 *   tangent     -Boolean indicating if line intersect at one point of the circle.
		 *   intersects  -Boolean indicating if there is an intersection of the points and the circle.
		 *
		 * If both "enter" and "exit" are null, or "intersects" == false, it indicates there is no intersection.
		 * This is a customization of the intersectCircleLine Javascript function found here:
		 * http://www.kevlindev.com/gui/index.htm
		 */
		public static function lineIntersectCircle(A:Point, B:Point, C:Point, r:Number=1):Object
		{
			var result:Object = { inside: false, tangent: false, intersects: false,
				enter: null, exit: null }
			
			var a:Number = (B.x - A.x) * (B.x - A.x) + 
				(B.y - A.y) * (B.y - A.y);
			
			var b:Number = 2 * ((B.x - A.x) * (A.x - C.x) +
				(B.y - A.y) * (A.y - C.y));
			
			var cc:Number = C.x * C.x + C.y * C.y +
				A.x * A.x + A.y * A.y -
				2 * (C.x * A.x + C.y * A.y) -
				r * r;
			
			var deter:Number = b * b - 4 * a * cc;
			
			if (deter > 0 )
			{
				var e:Number = Math.sqrt(deter);
				var u1:Number = (-b + e) / (2 * a);
				var u2:Number = (-b - e) / (2 * a);
				if ((u1 < 0 || u1 > 1) && (u2 < 0 || u2 > 1))
				{
					if ((u1 < 0 && u2 < 0) || (u1 > 1 && u2 > 1))
						result.inside = false;
					else
						result.inside = true;
				}
				else
				{
					if (0 <= u2 && u2 <= 1)
						result.enter = Point.interpolate (A, B, 1 - u2);
					if (0 <= u1 && u1 <= 1)
						result.exit = Point.interpolate (A, B, 1 - u1);
					
					result.intersects = true;
					
					if (result.exit != null &&
						result.enter != null &&
						result.exit.equals(result.enter))
					{
						result.tangent = true;
					}
				}
			}
			
			return result;
		}
		
		/**
		 * Calculates the slope angle of the line defined by given two points.
		 * 
		 * @param points	array containing two clipping points 
		 * @return			angle of the slope of the line
		 */
		public static function slopeAngle(p1:Point, p2:Point):Number
		{
			// calculate the angle between the line (defined by p1 and p2) 
			// and the x-axis.
			
			var slopeAngle:Number = Math.atan((p2.y - p1.y) / (p2.x - p1.x));
			
			return slopeAngle;
		}
	}
}