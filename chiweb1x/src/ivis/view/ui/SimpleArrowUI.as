package ivis.view.ui
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	import ivis.model.Edge;
	import ivis.util.GeometryUtils;

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
		
		/** @inheritDoc */
		public function drawSourceArrow(edge:Edge,
			points:Array):Array
		{
			var angle:Number = edge.props.arrowTipAngle;
			var distance:Number = edge.props.arrowTipDistance;
			
			var slopeAngle: Number = GeometryUtils.slopeAngle(points[0],
				points[1]);
			
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
		
		/** @inheritDoc */
		public function drawTargetArrow(edge:Edge,
			points:Array):Array
		{
			var angle:Number = edge.props.arrowTipAngle;
			var distance:Number = edge.props.arrowTipDistance;
			
			var slopeAngle: Number = GeometryUtils.slopeAngle(points[0],
				points[1]);
			
			if (!isNaN(slopeAngle))
			{
				// adjust arrow direction (arrow angle)
				if ((points[1] as Point).x - (points[0] as Point).x >= 0)
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