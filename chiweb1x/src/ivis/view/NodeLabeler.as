package ivis.view
{
	import flare.animate.Transitioner;
	import flare.display.TextSprite;
	import flare.util.Filter;
	import flare.vis.data.DataList;
	import flare.vis.data.DataSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.operator.label.Labeler;
	
	import flash.text.TextFormat;
	
	import ivis.util.Groups;

	/**
	 * Labeler for simple (regular) nodes.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class NodeLabeler extends Labeler
	{
		public function NodeLabeler(source:* = null,
			group:String = Groups.NODES,
			format:TextFormat = null,
			filter:* = null)
		{
			var policy:String = Labeler.LAYER;
			
			//TODO default label text source "props.labelText"?
			
			super(source, group, format, filter, policy);
		}
		
		/** @inheritDoc */
		public override function setup():void
		{
			super.setup();
			
			this._labels.buttonMode = false;
			this._labels.useHandCursor = false;
		}
		
		public override function operate(t:Transitioner=null):void
		{
			if (this.visualization != null)
			{
				if (t != null)
				{
					this._t = t;
				}
				else
				{
					this._t = Transitioner.DEFAULT;
				}
				
				var filterFn:Function = Filter.$(this.filter);
				var list:DataList = this.visualization.data.group(this.group);
				
				if (list != null)
				{
					for each (var node:DataSprite in list)
					{
						if ((filterFn == null || filterFn(node)) &&
							(node is NodeSprite))
						{
							this.process(node);
						}
					}
					
					/*
					$each(list, function(i:uint, d:DataSprite):void {
						if (f == null || f(d)) process(d);
					});
					*/
				}
			}
		}
		
		protected override function process(d:DataSprite):void
		{
			var label:TextSprite = this.getLabel(d, true);
			
			label.filters = null; // filters(d); TODO get filters
			label.alpha = d.alpha;
			label.visible = d.visible;
			
			this.updateLabelPosition(label, d);
		}
		
		protected override function getLabel(d:DataSprite,
			create:Boolean=false,
			visible:Boolean=true):TextSprite
		{
			updateTextFormat(d);
			
			var label:TextSprite = super.getLabel(d, create, visible);
			
			if (label && !cacheText)
			{
				label.text = this.getLabelText(d);
				label.applyFormat(this.textFormat);
			}
			
			// TODO get horizontal & vertical anchors from elsewhere (styles)
			//if (hAnchor != null) label.horizontalAnchor = hAnchor(d);
			//if (vAnchor != null) label.verticalAnchor = vAnchor(d);
			/*
			labelHorizontalAnchor: "center",
			labelVerticalAnchor: "middle",
			*/
			
			label.horizontalAnchor = TextSprite.CENTER;
			//label.horizontalAnchor = TextSprite.LEFT;
			//label.horizontalAnchor = TextSprite.RIGHT;
			
			label.verticalAnchor = TextSprite.MIDDLE;
			//label.verticalAnchor = TextSprite.TOP;
			//label.verticalAnchor = TextSprite.BOTTOM;
			
			return label;
		}
		
		protected function updateLabelPosition(label:TextSprite,
			d:DataSprite):void
		{
			if (label == null)
			{
				return;
			}
			
			var x:Number = d.x;
			var y:Number = d.y;
			
			// TODO get these values from elsewhere (visual styles)
			var xOff:Number = 0;
			var yOff:Number = 0;
			
			// the offset should be based on each node's size
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
			
			label.x = x + xOff;
			label.y = y + yOff;
			
			label.render();
		}
		
		protected function updateTextFormat(d:DataSprite):void
		{
			// TODO get these values from elsewhere (visual styles)
			/*
			labelFontName: "Arial",
			labelFontSize: 11,
			labelFontColor: "#000000",
			labelFontWeight: "normal",
			labelFontStyle: "normal",
			*/
			
			textFormat.font = "Arial";
			textFormat.color = 0x0;
			textFormat.size = 14;
			textFormat.bold = null; // textFormat.bold = (fontWeight(d) === "bold");
			textFormat.italic = null; // textFormat.italic = (fontStyle(d) === "italic");
		}
	}
}