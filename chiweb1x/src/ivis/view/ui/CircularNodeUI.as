package ivis.view.ui
{
	import flare.util.Shapes;
	import flare.vis.data.DataSprite;
	
	import flash.display.Graphics;
	import flash.geom.Point;
	
	import ivis.model.Node;
	import ivis.util.GeometryUtils;

	/**
	 * Implementation of the INodeUI interface for circular node shapes. This
	 * class is designed to draw nodes as circles and to calculate edge
	 * clipping points for circlular nodes.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class CircularNodeUI implements INodeUI
	{
		private static var _instance:INodeUI;
		
		/**
		 * Singleton instance.
		 */
		public static function get instance():INodeUI
		{
			if (_instance == null)
			{
				_instance = new CircularNodeUI();
			}
			
			return _instance;
		}
		
		//------------------------- CONSTRUCTOR --------------------------------
		
		public function CircularNodeUI()
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
		 * Draws a circular node assuming that ds has a field size for its
		 * radius.
		 * 
		 * @param ds			data sprite (the node)
		 */
		public function draw(ds:DataSprite):void
		{
			var radius:Number = ds.size;
			var g:Graphics = ds.graphics;
			
			Shapes.drawCircle(g, radius/2);
		}
		
		/**
		 * Calculates the intersection point of the given node and the line
		 * specified by the points p1 and p2. This function assumes the shape
		 * of the given node as circular. If no intersection point is found,
		 * then the center of the given node is returned as an intersection 
		 * point.
		 * 
		 * @param node	circular Node
		 * @param p1	start point of the line
		 * @param p2	end point of the line
		 * @return		intersection point 
		 */
		public function intersection(node:Node,
			p1:Point,
			p2:Point):Point
		{
			var interPoint:Point = null;
			var center:Point = new Point(node.x, node.y);
			
			var result:Object = GeometryUtils.lineIntersectCircle(
				p1, p2, center, node.width / 2);
			
			if (result.enter != null)
			{
				interPoint = result.enter as Point;
			}
			else if (result.exit != null)
			{
				interPoint = result.exit as Point;
			}
			else
			{
				// if no intersection, then take the center of the node
				// as the intersection point
				interPoint = new Point(node.x, node.y);
			}
			
			return interPoint;
		}
	}
}