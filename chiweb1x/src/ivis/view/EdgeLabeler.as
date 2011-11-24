package ivis.view
{
	import flare.display.TextSprite;
	import flare.vis.data.DataSprite;
	
	import flash.geom.Point;
	import flash.text.TextFormat;
	
	import ivis.model.Edge;
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
			
			// TODO calculate the position!
			//trace("[EdgeLabeler.updateLabelPos] edge: " + d.data.id);
			
			var x:Number = ((d.props.startPoint as Point).x + 
				(d.props.endPoint as Point).x) / 2;
			var y:Number = ((d.props.startPoint as Point).y + 
				(d.props.endPoint as Point).y) / 2;
			
			// TODO get these values from elsewhere (visual styles)
			var xOff:Number = 0;
			var yOff:Number = 0;
			
			// the offset should be based on each node's size
			/*
			if (label.horizontalAnchor == TextSprite.LEFT)
			{
				xOff += d.width/2;
			}
			else if (label.horizontalAnchor == TextSprite.RIGHT)
			{
				xOff -= d.width/2;
			}
			
			if (label.verticalAnchor == TextSprite.TOP)
			{
				yOff += d.height/2;
			}
			else if (label.verticalAnchor == TextSprite.BOTTOM)
			{
				yOff -= d.height/2;
			}
			*/
			
			label.x = x + xOff;
			label.y = y + yOff;
		}
	}
}