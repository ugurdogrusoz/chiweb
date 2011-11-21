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
	import ivis.util.CompoundUIs;
	import ivis.util.EdgeUIs;
	import ivis.util.GeometryUtils;
	import ivis.util.NodeUIs;

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
			var edgeUI:IEdgeUI;
			
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
					
					// TODO set the linestyle (need to override setLineStyle
					// in order to use a bit mask)
					
					// TODO Using a bit mask to avoid transparent edges when fillcolor=0xffffffff.
					// See https://sourceforge.net/forum/message.php?msg_id=7393265
					// var color:uint =  0xffffff & e.lineColor;
					
					// set the default line style
					this.setLineStyle(edge, edge.graphics);
					
					// TODO consider line styles (dashed, dotted, solid, etc)
					
					// if a custom line style is defined in edgeUI, it will
					// overwrite the default line style
					edgeUI = EdgeUIs.getUI(edge.shape);
					edgeUI.setLineStyle(edge);
					
					// draw the edge
					if (points != null)
					{
						// store start end points of the edge
						edge.props.startPoint = points[0];
						edge.props.endPoint = points[1];
						
						// draw the edge line using the clipping points
						// TODO what to do with bendpoints when edges are curved?
						// TODO consider 'Shapes' such as LINE BEZIER CARDINAL BSPLINE?
						edgeUI.draw(edge, points);
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
			
			var nodeUI:INodeUI;
			
			if (node.isInitialized())
			{
				nodeUI = CompoundUIs.getUI(node.shape);
			}
			else
			{
				nodeUI = NodeUIs.getUI(node.shape);
			}
			
			interPoint = nodeUI.intersection(node, p1, p2);
			
			return interPoint;
		}
	}
}