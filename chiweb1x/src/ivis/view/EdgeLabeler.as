package ivis.view
{
	import flare.display.TextSprite;
	import flare.vis.data.DataSprite;
	
	import flash.geom.Point;
	import flash.text.TextFormat;
	
	import ivis.model.Edge;
	import ivis.model.Node;
	import ivis.util.Edges;
	import ivis.util.GeometryUtils;
	import ivis.util.Groups;

	/**
	 * Labeler for edge sprites.
	 * 
	 * @author Selcuk Onur Sumer 
	 */
	public class EdgeLabeler extends NodeLabeler
	{
		public static const SOURCE:String = "source";
		public static const TARGET:String = "target";
		public static const MIDDLE:String = "middle";
		
		public function EdgeLabeler(source:* = null,
									group:String = Groups.EDGES,
									format:TextFormat = null,
									filter:* = null)
		{
			//var policy:String = Labeler.LAYER;
			
			//TODO default label text source "props.labelText"?
			
			super(source, group, format, filter);
		}
		
		/** @inheritDoc */
		protected override function process(d:DataSprite):void
		{
			if (d is Edge)
			{
				var edge:Edge = d as Edge;
				
				if (!edge.isSegment && edge.props.startPoint != null &&
					edge.props.endPoint != null)
				{
					var label:TextSprite = this.getLabel(d, true);
					
					label.filters = null; // filters(d); TODO get filters
					label.alpha = d.alpha;
					label.visible = d.visible;
					
					this.updateLabelPosition(label, d);
					label.render();
				}
			}
		}
		
		protected override function updateLabelPosition(label:TextSprite,
			d:DataSprite):void
		{
			if (label == null)
			{
				return;
			}
			
			var startPoint:Point = d.props.startPoint as Point;
			var endPoint:Point = d.props.endPoint as Point;
			var adjacentToSrc:Edge;
			var adjacentToTgt:Edge;
			
			// if edge has bendpoints, find the correct segment (or bend point)
			// to place the label
			if ((d as Edge).hasBendPoints())
			{
				// get the segment adjacent to the source node
				adjacentToSrc = Edges.segmentAdjacentToSource(d as Edge);
				
				// get the segment adjacent to the target node
				adjacentToTgt = Edges.segmentAdjacentToTarget(d as Edge);
				
				// take the segment adjacent to the source node
				if (d.props.labelPos == EdgeLabeler.SOURCE)
				{
					startPoint = adjacentToSrc.props.startPoint;
					endPoint = adjacentToSrc.props.endPoint;
				}
				// take the segment adjacent to the target node
				else if (d.props.labelPos == EdgeLabeler.TARGET)
				{
					startPoint = adjacentToTgt.props.startPoint;
					endPoint = adjacentToTgt.props.endPoint;
				}
				// default case is center 
				else
				{
					var segment:Edge;
					var bendNode:Node;
					var bendPoint:Point;
					
					// find the central segment or the central bendpoint
					if ((d as Edge).getBendNodes().length % 2 == 0)
					{
						segment = Edges.centralSegment(d as Edge);
						startPoint = segment.props.startPoint;
						endPoint = segment.props.endPoint;
					}
					else
					{
						bendNode = Edges.centralBendPoint(d as Edge);
						bendPoint = new Point(bendNode.x,
							bendNode.y);
						
						startPoint = bendPoint;
						endPoint = bendPoint;
					}
				}
			}
			
			// label coordinates
			var x:Number;
			var y:Number;
			
			// desired distance of the label from the node
			// (ignored if label position is EdgeLabeler.CENTER)
			var distance:Number = d.props.labelDistanceFromNode;
			
			// distance between clipping points of the edge
			var dist:Number;
			
			if (d.props.labelPos == EdgeLabeler.SOURCE)
			{
				// place the label next to the source 
				// (a fixed distance away from the source clipping point)
				
				dist = Point.distance(startPoint, endPoint);
				
				x = startPoint.x +
					(distance / dist) * (endPoint.x - startPoint.x);
				y = startPoint.y +
					(distance / dist) * (endPoint.y - startPoint.y);
			}
			else if (d.props.labelPos == EdgeLabeler.TARGET)
			{
				// place the label next to the target
				// (a fixed distance away from the target clipping point)
				
				// (alternative calculation with polar angles)
				//slopeAngle = GeometryUtils.slopeAngle(startPoint, endPoint);
				//loc = Point.polar(distance, slopeAngle);
				
				dist = Point.distance(startPoint, endPoint);
				
				x = endPoint.x +
					(distance / dist) * (startPoint.x - endPoint.x);
				y = endPoint.y +
					(distance / dist) * (startPoint.y - endPoint.y);
			}
			else
			{
				// place the label to the center of the edge (or the segment)
				x = (startPoint.x + endPoint.x) / 2;
				y = (startPoint.y + endPoint.y) / 2;
			}
			
			// apply offset values
			label.x = x + d.props.labelOffsetX;
			label.y = y + d.props.labelOffsetY;
		}
	}
}