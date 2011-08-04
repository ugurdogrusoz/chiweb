package ivis.view
{
	import flare.util.Geometry;
	import flare.util.Shapes;
	import flare.vis.data.DataSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.data.render.EdgeRenderer;
	
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import ivis.model.Edge;
	import ivis.model.Node;
	import ivis.util.GeometryUtils;
	import ivis.util.NodeShapes;
	
	import org.osmf.layout.PaddingLayoutFacet;

	/**
	 * Renderer for Edge instances.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class EdgeRenderer extends flare.vis.data.render.EdgeRenderer
	{
		private static var _instance:ivis.view.EdgeRenderer =
			new ivis.view.EdgeRenderer();
		
		public static function get instance():ivis.view.EdgeRenderer
		{
			return _instance;
		}
		
		public override function render(d:DataSprite):void
		{
			var edge:Edge;
			
			if (d is Edge)
			{
				edge = d as Edge;
				
				
				if (edge == null ||
					edge.source == null ||
					edge.target == null)
				{
					// cannot render
				}
				// edge is totally transparent
				else if (edge.lineWidth === 0 ||
					edge.lineAlpha === 0 ||
					edge.alpha === 0)
				{
					trace (edge.data.id + " is totally transparent");
					
					// just clear
					d.graphics.clear();
				}
				// edge is an actual edge, and has bendpoints on it,
				// so it should not be displayed
				else if (edge.hasBendPoints())
				{
					d.graphics.clear();
				}
				// edge is either a segment or an actual edge with no segments,
				// in both cases it should be rendered
				else
				{
					d.graphics.clear();
					
					// TODO arrow?
					
					// calculate clipping points
					var points:Array = this.clippingPoints(edge.source,
						edge.target);
					
					// TODO set the linestyle (may need to override setLineStyle)
					
					// TODO Using a bit mask to avoid transparent edges when fillcolor=0xffffffff.
					// See https://sourceforge.net/forum/message.php?msg_id=7393265
					// var color:uint =  0xffffff & e.lineColor;
					
					this.setLineStyle(edge, edge.graphics);
					
					// draw the edge
					if (points != null)
					{
						// store start end points of the edge
						edge.props.startPoint = points[0];
						edge.props.endPoint = points[1];
						
						// draw the edge line using the clipping points
						this.drawLine(edge, points);
					}
					else
					{
						// TODO warning on screen?
						trace("Cannot calculate clipping points for the edge: "
							+ edge.data.id);
						
						super.render(d);
					}
				}
			}
			else
			{
				super.render(d);
			}
		}
		
		/**
		 * Calculate clipping points of the edge for the given source and target
		 * nodes. If the shapes of source or target cannot be handled by the
		 * intersect function, then the resulting array will be null.
		 * 
		 * @param source	source of the edge
		 * @param target	target of the edge
		 * @return			array of two clipping points if success, null o.w. 
		 */
		protected function clippingPoints(source:NodeSprite,
			target:NodeSprite):Array
		{
			var points:Array = null;
			var sourcePoint:Point;
			var targetPoint:Point;
			
			// find intersection points of the line (joining the centers of
			// source and target nodes) and the nodes (according to the node
			// shape)
			
			var sourceCenter:Point = new Point(source.x, source.y);
			var targetCenter:Point = new Point(target.x, target.y);
			
			sourcePoint = this.intersection(source as Node,
				sourceCenter,
				targetCenter);
			
			targetPoint = this.intersection(target as Node,
				sourceCenter,
				targetCenter);
			
			if (sourcePoint != null &&
				targetPoint != null)
			{
				points = new Array();
				points.push(sourcePoint);
				points.push(targetPoint);
			}
			
			return points;
		}
		
		/**
		 * Calculates the intersection point of the given Node with the line
		 * specified by the points p1 and p2. If the shape of the node is not
		 * a shape that can be handled by this function, then the return value
		 * will be null.
		 * 
		 * @param node	Node to intersect
		 * @param p1	start point of the line
		 * @param p2	end point of the line
		 * @return		intersection point if successful, null otherwise
		 */
		protected function intersection(node:Node,
			p1:Point,
			p2:Point):Point
		{
			var interPoint:Point = null;
			
			// find the intersection point according to the node shape
			
			if (node.shape == Shapes.CIRCLE)
			{
				interPoint = this.intersectCircle(node, p1, p2);
			}			
			else if (node.shape == NodeShapes.ROUND_RECTANGLE)
			{
				interPoint = this.intersectRoundRect(node, p1, p2);
			}
			// default case is a RECTANGLE
			else if (node.shape == NodeShapes.RECTANGLE)
			{
				interPoint = this.intersectRect(node, p1, p2);
			}
			
			return interPoint;
		}
		
		/**
		 * Calculates the intersection point of the given node and the line
		 * specified by the points p1 and p2. This function assumes the shape
		 * of the node as NodeShapes.RECTANGLE. If no intersection point is
		 * found, then the center of the given node is returned as an
		 * intersection point.
		 * 
		 * @param node	rectangular Node
		 * @param p1	start point of the line
		 * @param p2	end point of the line
		 * @return		intersection point 
		 */
		protected function intersectRect(node:Node,
			p1:Point,
			p2:Point):Point
		{
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
		
		/**
		 * Calculates the intersection point of the given node and the line
		 * specified by the points p1 and p2. This function assumes the shape
		 * of the node as NodeShapes.ROUND_RECTANGLE. If no intersection point
		 * is found, then the center of the given node is returned as an
		 * intersection point.
		 * 
		 * @param node	circular Node
		 * @param p1	start point of the line
		 * @param p2	end point of the line
		 * @return		intersection point 
		 */
		protected function intersectRoundRect(node:Node,
			p1:Point,
			p2:Point):Point
		{
			//TODO intersectRoundRect
			return this.intersectRect(node, p1, p2);
		}
		
		/**
		 * Calculates the intersection point of the given node and the line
		 * specified by the points p1 and p2. This function assumes the shape
		 * of the node as Shapes.CIRCLE. If no intersection point is
		 * found, then the center of the given node is returned as an
		 * intersection point.
		 * 
		 * @param node	circular Node
		 * @param p1	start point of the line
		 * @param p2	end point of the line
		 * @return		intersection point 
		 */
		protected function intersectCircle(node:Node,
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
		
		protected function drawLine(edge:Edge, points:Array):void
		{
			var g:Graphics = edge.graphics;
			
			// TODO consider line styles (dashed, dotted, solid, etc)
			// TODO consider 'Shapes' such as LINE BEZIER CARDINAL BSPLINE?
			// TODO bendpoints when edges are curved?
			g.moveTo((points[0] as Point).x, (points[0] as Point).y);
			g.lineTo((points[1] as Point).x, (points[1] as Point).y);
		}
		
	}
}