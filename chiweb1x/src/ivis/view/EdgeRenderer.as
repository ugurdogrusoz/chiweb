package ivis.view
{
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.data.render.EdgeRenderer;
	
	import flash.display.Graphics;
	import flash.geom.Point;
	
	import ivis.model.Edge;
	import ivis.model.Node;
	import ivis.view.ui.ArrowUIManager;
	import ivis.view.ui.CompoundUIManager;
	import ivis.view.ui.EdgeUIManager;
	import ivis.view.ui.NodeUIManager;
	import ivis.view.ui.IArrowUI;
	import ivis.view.ui.IEdgeUI;
	import ivis.view.ui.INodeUI;

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
		
		/** @inheritDoc */
		public override function render(d:DataSprite):void
		{
			var edge:Edge;
			var edgeUI:IEdgeUI;
			
			if (d is Edge)
			{
				edge = d as Edge;
				edgeUI = EdgeUIManager.getUI(edge.shape);
				
				if (edge.source == null ||
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
				// unrecognized edge UI
				else if (edgeUI == null)
				{
					trace ("[EdgeRenderer.render]" + edge.data.id +
						" has an unrecognized UI");
					
					// try to render with parent renderer
					super.render(d);
					
					// TODO try to render with a default UI if shape cannot be rendered with the parent renderer
					// edgeUI = EdgeUIManager.getUI(EdgeUIManager.LINE);
				}
				// edge is either a segment or an actual edge with no segments,
				// in both cases it should be rendered
				else
				{
					d.graphics.clear();
					
					// calculate clipping points for the edge
					var points:Array = this.clippingPoints(edge);
					
					// set the default line style
					this.setLineStyle(edge, edge.graphics);
					
					// if a custom line style is defined in edgeUI, it will
					// overwrite the default line style
					edgeUI.setLineStyle(edge);
					
					// draw source and target arrows,
					// and recalculate clipping points if necessary
					if (points != null)
					{
						points = this.drawArrows(edge, points);
					}
					
					// draw the edge
					if (points != null)
					{
						// store start end points of the edge
						edge.props.$startPoint = points[0];
						edge.props.$endPoint = points[1];
						
						// draw the edge line using the clipping points						
						edgeUI.draw(edge);
						
						// TODO what to do with bendpoints when edges are curved?
					}
					else
					{
						trace("cannot calculate clipping points for the edge: "
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
		
		/** @inheritDoc */
		protected override function setLineStyle(e:EdgeSprite,
			g:Graphics):void
		{
			var lineAlpha:Number = e.lineAlpha;
			
			if (lineAlpha == 0)
			{
				return;
			}
			
			// bit mask to avoid transparent edges when fillcolor=0xffffffff
			// (https://sourceforge.net/forum/message.php?msg_id=7393265)
			var color:uint =  0xffffff & e.lineColor;
			
			g.lineStyle(e.lineWidth, color, lineAlpha, 
				pixelHinting, scaleMode, caps, joints, miterLimit);
		}
		
		/**
		 * Calculates clipping points of the given edge for its source and 
		 * target nodes. If the shapes of source or target cannot be handled
		 * by the intersect function, then the resulting array will be null.
		 * 
		 * @param edge	edge to intersect with its node and target	
		 * @return		array of two clipping points if success, null o.w. 
		 */
		protected function clippingPoints(edge:Edge):Array
		{
			var points:Array = null;
			
			var source:Node = edge.source as Node; 
			var target:Node = edge.target as Node;
			
			// find intersection points of the edge and the nodes
			// (according to the node shapes)
			
			var sourcePoint:Point = this.intersection(source, edge);
			var targetPoint:Point = this.intersection(target, edge);
			
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
		 * Calculates the intersection point of the given node with the given
		 * edge. If the shape of the node is not a shape that can be handled
		 * by this function, then the return value will be null.
		 * 
		 * @param node	node to intersect
		 * @param edge	edge to intersect
		 * @return		intersection point if successful, null otherwise
		 */
		protected function intersection(node:Node,
			edge:Edge):Point
		{
			var interPoint:Point = null;
			
			// find the intersection point according to the node shape
			
			var nodeUI:INodeUI;
			
			if (node.isInitialized())
			{
				nodeUI = CompoundUIManager.getUI(node.shape);
				
				if (nodeUI == null)
				{
					// try to calculate clipping points for a default UI
					nodeUI = CompoundUIManager.getUI(
						CompoundUIManager.RECTANGLE);
				}
			}
			else
			{
				nodeUI = NodeUIManager.getUI(node.shape);
				
				if (nodeUI == null)
				{
					// try to calculate clipping points for a default UI
					nodeUI = NodeUIManager.getUI(NodeUIManager.RECTANGLE);
				}
			}
						
			interPoint = nodeUI.intersection(node, edge);
			
			return interPoint;
		}
		
		/**
		 * Draws the arrows for both source and target ends of the given edge.
		 * Returns new clipping points after drawing the arrows.
		 * 
		 * @param edge		edge on which arrows to be drawn
		 * @param points	clipping points for the given edge
		 * @return			new clipping points
		 */
		protected function drawArrows(edge:Edge,
			points:Array):Array
		{
			var sourceArrowUI:IArrowUI = null;
			var targetArrowUI:IArrowUI = null;
			var newPoints:Array = points;
			
			var sourceArrowType:String = null;
			var targetArrowType:String = null;
			
			// for a segment edge, get arrow props from the parent
			if (edge.isSegment)
			{
				sourceArrowType = edge.parentE.props.sourceArrowType;
				targetArrowType = edge.parentE.props.targetArrowType;
			}
			// for an actual edge, use directly its prop object
			else
			{
				sourceArrowType = edge.props.sourceArrowType;
				targetArrowType = edge.props.targetArrowType;
			}
			
			// get the UI corresponding to the source arrow type
			if (sourceArrowType != null)
			{
				sourceArrowUI = ArrowUIManager.getUI(sourceArrowType);
			}
			
			// get the UI corresponding to the target arrow type
			if (targetArrowType != null)
			{
				targetArrowUI = ArrowUIManager.getUI(targetArrowType);
			}
			
			// do not draw arrows for segment edges between two bendpoints
			if (edge.isSegment)
			{
				if (edge.source === edge.parentE.source)
				{
					// draw source arrow (target is a bendpoint)
					if (sourceArrowUI != null)
					{
						newPoints = sourceArrowUI.drawSourceArrow(edge, points);
					}
				}
				else if (edge.target === edge.parentE.target)
				{
					// draw target arrow (source is a bendpoint)
					if (targetArrowUI != null)
					{
						newPoints = targetArrowUI.drawTargetArrow(edge, points);
					}
				}
					
			}
			// do not draw arrows for hidden actual edges (having segments) 
			else if (! edge.hasBendPoints())
			{
				// draw both source and target arrows
				
				if (sourceArrowUI != null)
				{
					newPoints = sourceArrowUI.drawSourceArrow(edge, points);
				}
				
				if (targetArrowUI != null)
				{
					newPoints = targetArrowUI.drawTargetArrow(edge, points);
				}
			}
			
			return newPoints;
		}
	}
}