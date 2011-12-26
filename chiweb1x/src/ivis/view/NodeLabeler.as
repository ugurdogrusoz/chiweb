package ivis.view
{
	import flare.animate.Transitioner;
	import flare.display.TextSprite;
	import flare.util.Filter;
	import flare.vis.data.DataList;
	import flare.vis.data.DataSprite;
	import flare.vis.operator.label.Labeler;
	
	import flash.text.TextFormat;
	
	import ivis.util.Groups;
	import ivis.util.Labels;
	
	/**
	 * Labeler for simple (regular) nodes.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class NodeLabeler extends Labeler
	{
		public function NodeLabeler(source:* = Labels.DEFAULT_TEXT_SOURCE,
			group:String = Groups.NODES,
			format:TextFormat = null,
			filter:* = null)
		{
			var policy:String = Labeler.LAYER;
			
			super(source, group, format, filter, policy);
			
			this.cacheText = false;
		}
		
		/** @inheritDoc */
		public override function setup():void
		{
			super.setup();
			
			this._labels.buttonMode = false;
			this._labels.useHandCursor = false;
		}
		
		/** @inheritDoc */
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
					for each (var ds:DataSprite in list)
					{
						if ((filterFn == null || filterFn(ds)))
						{
							this.process(ds);
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
		
		/** @inheritDoc */
		protected override function process(d:DataSprite):void
		{
			var label:TextSprite = this.getLabel(d, true);
			
			if (label != null)
			{
				label.filters = null; // filters(d); TODO get filters
				label.alpha = d.alpha;
				label.visible = d.visible;
			
				this.updateLabelPosition(label, d);
				label.render();
			}
		}
		
		/** @inheritDoc */
		protected override function getLabel(d:DataSprite,
			create:Boolean=false,
			visible:Boolean=true):TextSprite
		{
			this.updateTextFormat(d);
			
			var label:TextSprite = super.getLabel(d, create, visible);
			
			// do not create label for empty strings
			if (label.text.length <= 0)
			{
				label = null;
			}
			
			if (label && !cacheText)
			{
				label.text = this.getLabelText(d);
				label.applyFormat(this.textFormat);
				
				// get horizontal & vertical anchors
				
				label.horizontalAnchor = d.props.labelHorizontalAnchor;
				label.verticalAnchor = d.props.labelVerticalAnchor;
			}
			
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
			
			var xOff:Number = d.props.labelOffsetX;
			var yOff:Number = d.props.labelOffsetY;
			
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
		}
		
		protected function updateTextFormat(d:DataSprite):void
		{
			this.textFormat.font = d.props.labelFontName;
			this.textFormat.color = d.props.labelFontColor;
			this.textFormat.size = d.props.labelFontSize;
			
			this.textFormat.bold = null;
			this.textFormat.italic = null;
			
			if (d.props.labelFontWeight == "bold")
			{
				this.textFormat.bold = true;
			}
			
			if (d.props.labelFontStyle == "italic")
			{
				this.textFormat.italic = true;
			}
		}
	}
}