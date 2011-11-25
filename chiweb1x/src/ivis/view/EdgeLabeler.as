package ivis.view
{
	import flare.display.TextSprite;
	import flare.vis.data.DataSprite;
	
	import flash.geom.Point;
	import flash.text.TextFormat;
	
	import ivis.model.Edge;
	import ivis.model.Node;
	import ivis.util.Edges;
	import ivis.util.Groups;

	public class EdgeLabeler extends NodeLabeler
	{
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
			
			if ((d as Edge).hasBendPoints())
			{
				// get the segment adjacent to the source node
				adjacentToSrc = Edges.segmentAdjacentToSource(d as Edge);
				
				// get the segment adjacent to the target node
				adjacentToTgt = Edges.segmentAdjacentToTarget(d as Edge);
				
				// take the segment adjacent to the source node
				if (label.horizontalAnchor == TextSprite.LEFT)
				{
					startPoint = adjacentToSrc.props.startPoint;
					endPoint = adjacentToSrc.props.endPoint;
				}
				// take the segment adjacent to the target node
				else if (label.horizontalAnchor == TextSprite.RIGHT)
				{
					startPoint = adjacentToTgt.props.startPoint;
					endPoint = adjacentToSrc.props.endPoint;
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
			
			var x:Number;
			var y:Number;
			
			// TODO get these values from elsewhere (visual styles)
			
			var xOff:Number = 0;
			var yOff:Number = 0;
			
			label.horizontalAnchor = TextSprite.CENTER;
			//label.horizontalAnchor = TextSprite.LEFT;
			//label.horizontalAnchor = TextSprite.RIGHT;
			
			label.verticalAnchor = TextSprite.MIDDLE;
			//label.verticalAnchor = TextSprite.TOP;
			//label.verticalAnchor = TextSprite.BOTTOM;
			
			if (label.horizontalAnchor == TextSprite.LEFT)
			{
				// TODO place the label next to the source 
				// (a fixed distance away from the source clipping point)
				x = (startPoint.x + endPoint.x) / 2;
				y = (startPoint.y + endPoint.y) / 2;
			}
			else if (label.horizontalAnchor == TextSprite.RIGHT)
			{
				// TODO place the label next to the target
				// (a fixed distance away from the target clipping point)
				x = (startPoint.x + endPoint.x) / 2;
				y = (startPoint.y + endPoint.y) / 2;
			}
			else
			{
				// place the label to the center of the edge (or the segment)
				x = (startPoint.x + endPoint.x) / 2;
				y = (startPoint.y + endPoint.y) / 2;
			}
			
			if (label.verticalAnchor == TextSprite.TOP)
			{
				// TODO where is top?
			}
			else if (label.verticalAnchor == TextSprite.BOTTOM)
			{
				// TODO where is bottom?
			}
			
			label.x = x + xOff;
			label.y = y + yOff;
		}
	}
}