package ivis.view
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	import ivis.model.Edge;

	/**
	 * Implementation of the IArrowUI interface for simple edge arrows.
	 * This class is designed to draw edge arrows as simple arrows.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class SimpleArrowUI implements IArrowUI
	{
		private static var _instance:IArrowUI;
		
		/**
		 * Singleton instance.
		 */
		public static function get instance():IArrowUI
		{
			if (_instance == null)
			{
				_instance = new SimpleArrowUI();
			}
			
			return _instance;
		}
		
		//------------------------- CONSTRUCTOR --------------------------------
		
		public function SimpleArrowUI()
		{
			// default constructor
		}
		
		//---------------------- PUBLIC FUNCTIONS ------------------------------
		
		public function drawSourceArrow(edge:Edge,
			points:Array):Array
		{
			// TODO enabling setting of those variables via edge.props object
			var angle:Number = 0.3;
			var distance:Number = 15;
			
			var slopeAngle: Number = this.calcSlopeAngle(points);
			
			if (!isNaN(slopeAngle))
			{
				// adjust arrow direction (arrow angle)
				if ((points[1] as Point).x - (points[0] as Point).x < 0)
				{
					angle = Math.PI - angle;	
				}
				
				// calculate end points
				var endPoints:Array = this.calcEndPoints(points[0],
					distance,
					angle,
					slopeAngle);
				
				// draw the arrow
				this.drawArrow(points[0],
					endPoints,
					edge.graphics);
			}
			
			// no need to change the location of the clipping points for a
			// simple arrow, so just return the original array
			return points;
		}
		
		public function drawTargetArrow(edge:Edge,
			points:Array):Array
		{
			// TODO enabling setting of those variables via edge.props object
			var angle:Number = 0.3;
			var distance:Number = 15;
			
			var slopeAngle: Number = this.calcSlopeAngle(points);
			
			if (!isNaN(slopeAngle))
			{
				// adjust arrow direction (arrow angle)
				if ((points[1] as Point).x - (points[0] as Point).x > 0)
				{
					angle = Math.PI - angle;	
				}
				
				// calculate end points
				var endPoints:Array = this.calcEndPoints(points[1],
					distance,
					angle,
					slopeAngle);
				
				// draw the arrow
				this.drawArrow(points[1],
					endPoints,
					edge.graphics);
			}
			
			// no need to change the location of the clipping points for a
			// simple arrow, so just return the original array
			return points;
		}
		
		/**
		 * Calculates the slope angle of the line defined by given two clipping
		 * points.
		 * 
		 * @param points	array containing two clipping points 
		 * @return			angle of the slope of the line
		 */
		protected function calcSlopeAngle(points:Array):Number
		{
			// calculate the angle between the line (defined by points[0] and 
			// points[1]) and the x-axis.
			
			var slopeAngle:Number = Math.atan(
				((points[1] as Point).y - (points[0] as Point).y) /
				((points[1] as Point).x - (points[0] as Point).x));
			
			return slopeAngle;
		}
		
		/**
		 * Calculates end points of the arrow head.
		 * 
		 * @param p			 one of the clipping points of the edge
		 * @param distance	 distance of the end points to the arrow head
		 * @param angle		 angle (in radians) between edge and the arrow head
		 * @param slopeAngle slope angle of the edge
		 * @return			 end points of the arrow head in an array
		 */
		protected function calcEndPoints(p:Point,
			distance:Number,
			angle:Number,
			slopeAngle:Number):Array
		{
			// set the first end point of the arrow
			
			var p1:Point = Point.polar(distance, slopeAngle + angle);
			
			p1.x += p.x;
			p1.y += p.y;
			
			// set the second end point of the arrow
			
			var p2:Point = Point.polar(distance, slopeAngle - angle);
			
			p2.x += p.x;
			p2.y += p.y;
			
			return [p1, p2];
		}
		
		/**
		 * Draws the arrow head for the given clipping point and the end points
		 * of the arrow head.
		 * 
		 * @param p			clipping point
		 * @param endPoints	array of endPoints
		 * @param g			graphics of the edge 
		 */
		protected function drawArrow(p:Point,
			endPoints:Array,
			g:Graphics):void
		{
			// draw the arrow orthogonal to the line, facing the node
			
			g.moveTo(p.x, p.y);
			g.lineTo((endPoints[0] as Point).x, (endPoints[0] as Point).y);
			
			g.moveTo(p.x, p.y);
			g.lineTo((endPoints[1] as Point).x, (endPoints[1] as Point).y);
		}
			
	}
}