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
		
		//------------------------- CONSTRUCTOR --------------------------------
		
		/**
		 * Instantiates a labeler for nodes.
		 * 
		 * @param source	source property of the label text
		 * 					(default value is "data.label")
		 * @param access	target property to store node's label
		 * 					(default value is "props.$label")
		 * @param group		the data group
		 * 					(default value is Groups.NODES)
		 * @param format	optional text formatting information
		 * @param filter	function determining which nodes to be labelled
		 */
		public function NodeLabeler(source:* = Labels.DEFAULT_TEXT_SOURCE,
			access:String = Labels.DEFAULT_LABEL_ACCESS,
			group:String = Groups.NODES,
			format:TextFormat = null,
			filter:* = null)
		{
			// create a labeler with a layer policy
			var policy:String = Labeler.LAYER;
			super(source, group, format, filter, policy);
			
			this.access = access;
			
			// never cache text, otherwise it won't refresh label text when
			// source property (it is data.label by default) changes.
			this.cacheText = false;
		}
		
		//---------------------- PUBLIC FUNCTIONS ------------------------------
		
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
		
		//---------------------- PROTECTED FUNCTIONS ---------------------------
		
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
			var label:TextSprite;
			
			this.updateTextFormat(d);
			
			// do not create a label for null or empty strings
			if (this.getLabelText(d) == null ||
				this.getLabelText(d).length <= 0)
			{
				label = super.getLabel(d, false);
				
				// remove the previous label if any
				if (label != null)
				{
					this._labels.removeChild(label);
					label = null;
				}
			}
			else
			{
				label = super.getLabel(d, create, visible);
			}
			
			if (label && !cacheText)
			{
				label.textMode = d.props.labelTextMode;
				label.text = this.getLabelText(d);
				label.applyFormat(this.textFormat);
				
				// get horizontal & vertical anchors
				
				label.horizontalAnchor = d.props.labelHorizontalAnchor;
				label.verticalAnchor = d.props.labelVerticalAnchor;
			}
			
			return label;
		}
		
		/**
		 * Updates the position of the given label with respect to its owner
		 * data sprite.
		 * 
		 * @param label	label to be updated
		 * @param d		owner data sprite of the label
		 */
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
		
		/**
		 * Updates the text format of the label with respect to the given
		 * owner data sprite.
		 * 
		 * @param d	owner data sprite of the label
		 */
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