package ivis.view
{
	import flare.util.Geometry;
	import flare.vis.data.DataSprite;
	
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import ivis.model.Node;

	/**
	 * Implementation of the INodeUI interface for the round rectangle node
	 * shape. This class is designed to draw nodes as round rectangles and
	 * to calculate edge clipping points for round rectangular nodes.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class RoundRectNodeUI implements INodeUI
	{
		private static var _instance:INodeUI;
		
		/**
		 * Singleton instance.
		 */
		public static function get instance():INodeUI
		{
			if (_instance == null)
			{
				_instance = new RoundRectNodeUI();
			}
			
			return _instance;
		}
		
		//------------------------- CONSTRUCTOR --------------------------------
		
		public function RoundRectNodeUI()
		{
			// default constructor
		}
		
		//---------------------- PUBLIC FUNCTIONS ------------------------------
		
		/**
		 * Sets the line style of the node.
		 * 
		 * @param ds	data sprite (the node)
		 */
		public function setLineStyle(ds:DataSprite):void
		{
			var pixelHinting:Boolean = true;
			var g:Graphics = ds.graphics;
			
			g.lineStyle(ds.lineWidth,
				ds.lineColor,
				ds.lineAlpha,
				pixelHinting);
		}
		
		/**
		 * Draws a round rectangular node assuming that ds has a field w for its
		 * width and h for its height.
		 * 
		 * @param ds	data sprite (the node)
		 */
		public function draw(ds:DataSprite):void
		{
			var width:Number = ds.w;
			var height:Number = ds.h;
			var g:Graphics = ds.graphics;
			
			g.drawRoundRect(-width / 2, -height / 2,
				width, height,
				width / 2, height / 2);
		}
		
		/**
		 * Calculates the intersection point of the given node and the line
		 * specified by the points p1 and p2. This function assumes the shape
		 * of the given node as round rectangle. If no intersection point is
		 * found, then the center of the given node is returned as an
		 * intersection point.
		 * 
		 * @param node	round rectangular Node
		 * @param p1	start point of the line
		 * @param p2	end point of the line
		 * @return		intersection point 
		 */
		public function intersection(node:Node,
			p1:Point,
			p2:Point):Point
		{
			// TODO consider rounded corners!! this is identical to rectangle
			
			var interPoint:Point = null;
			
			var ip0:Point = new Point();
			var ip1:Point = new Point();
			
			var rect:Rectangle = new Rectangle(node.left, node.top,
				node.width, node.height);
			
			// calculate intersection point of the line with the rectangle
			if (Geometry.intersectLineRect(p1.x, p1.y, p2.x, p2.y,
				rect, ip0, ip1) == Geometry.NO_INTERSECTION)
			{
				// if no intersection, then take the center of the node
				// as the intersection point
				interPoint = new Point(node.x, node.y);
			}
			else
			{
				interPoint = new Point(ip0.x, ip0.y);
			}
			
			return interPoint;
		}
	}
}