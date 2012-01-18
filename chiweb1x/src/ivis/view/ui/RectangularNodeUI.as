package ivis.view.ui
{
	import flare.util.Geometry;
	import flare.vis.data.DataSprite;
	
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import ivis.model.Edge;
	import ivis.model.Node;

	/**
	 * Implementation of the INodeUI interface for rectangular node shapes.
	 * This class is designed to draw nodes as rectangles and to calculate edge
	 * clipping points for rectangular nodes.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class RectangularNodeUI implements INodeUI
	{	
		private static var _instance:INodeUI;
		
		/**
		 * Singleton instance.
		 */
		public static function get instance():INodeUI
		{
			if (_instance == null)
			{
				_instance = new RectangularNodeUI();
			}
			
			return _instance;
		}
		
		//------------------------- CONSTRUCTOR --------------------------------
		
		public function RectangularNodeUI()
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
			var pixelHinting:Boolean = false;
			var g:Graphics = ds.graphics;
			
			g.lineStyle(ds.lineWidth,
				ds.lineColor,
				ds.lineAlpha,
				pixelHinting);
		}
		
		/**
		 * Draws a rectangular node assuming that ds has a field w for its
		 * width and h for its height.
		 * 
		 * @param ds	data sprite (the node)
		 */
		public function draw(ds:DataSprite):void
		{
			var width:Number = ds.w;
			var height:Number = ds.h;
			var g:Graphics = ds.graphics;
			
			g.drawRect(-width/2, -height/2, width, height);
		}
		
		/**
		 * Calculates the intersection point of the given node and the given
		 * edge. This function assumes the shape of the given node as
		 * rectangular, and shape of the given edge as linear.
		 * 
		 * If no intersection point is found, then the center of the given node 
		 * is returned as an intersection point.
		 * 
		 * @param node	rectangular Node
		 * @param egde	a linear edge
		 * @return		intersection point 
		 */
		public function intersection(node:Node,
			edge:Edge):Point
		{
			var interPoint:Point = null;
			
			// centers of source and target nodes (considered as start & end
			// points of the line)
			var p1:Point = new Point(edge.source.x, edge.source.y);
			var p2:Point = new Point(edge.target.x, edge.target.y);
			
			// used as parameters for the utiliy function to store intersection
			// points
			var ip0:Point = new Point();
			var ip1:Point = new Point();
			
			// construct the rectangle defined by the node
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