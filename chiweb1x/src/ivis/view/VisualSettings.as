package ivis.view
{
	import flare.display.TextSprite;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import ivis.event.DataChangeEvent;
	import ivis.model.Edge;
	import ivis.model.Node;
	import ivis.util.ArrowUIs;
	import ivis.util.CompoundUIs;
	import ivis.util.EdgeUIs;
	import ivis.util.Groups;
	import ivis.util.NodeUIs;
	import ivis.util.VisualStyles;
	import ivis.model.VisualStyle;

	/**
	 * Visual settings for the graph. This class is designed to define custom
	 * visual styles for the graph elements such as nodes, edges, compounds,
	 * and bendpoints.
	 * 
	 * TODO global settings (backgroundColor, toolTipDelay, etc.) ?
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class VisualSettings extends EventDispatcher
	{
		protected var _defaultGlobalStyle:VisualStyle;
		
		private var _defaultNodeStyle:VisualStyle;
		private var _defaultEdgeStyle:VisualStyle;
		private var _defaultCompoundStyle:VisualStyle;
		
		protected var _groupStyle:Object;
		
		/**
		 * Default visual styles for nodes.
		 */
		public function get defaultNodeStyle():VisualStyle
		{
			return _defaultNodeStyle;
		}
		
		/**
		 * Default visual styles for edges.
		 */
		public function get defaultEdgeStyle():VisualStyle
		{
			return _defaultEdgeStyle;
		}
		
		/**
		 * Default visual styles for compound nodes.
		 */
		public function get defaultCompoundStyle():VisualStyle
		{
			return _defaultCompoundStyle;
		}
		
		//------------------------- CONSTRUCTOR --------------------------------
		
		public function VisualSettings()
		{
			// initialize group style map
			_groupStyle = new Object();
			
			// initialize default styles
			this.initDefaultStyles();
		}
		
		//---------------------- PUBLIC FUNCTIONS ------------------------------
		
		/**
		 * Attaches visual styles required for the initialization to the
		 * given node. Default node style is always attached to the given
		 * node and if there is a custom style defined for NODES group it is
		 * also attached.
		 * 
		 * @param node	node to attach visual styles
		 */
		public function initNodeStyle(node:Node) : void
		{
			// attach default node style
			node.attachStyle(VisualStyles.DEFAULT_STYLE,
				_defaultNodeStyle);
			
			// attach custom style specific to Groups.NODES
			
			var style:VisualStyle = this.getGroupStyle(Groups.NODES);
			
			if (style != null)
			{
				//style.apply(node);
				node.attachStyle(Groups.NODES, style);
			}
		}
		
		/**
		 * Applies default visual style to the given compound node.
		 * 
		 * @param node	compound node to apply visual style
		 */
		public function initCompoundStyle(node:Node) : void
		{
			// apply default compound node style
			node.attachStyle(VisualStyles.DEFAULT_STYLE,
				_defaultCompoundStyle);
		}
		
		/**
		 * Applies visual styles to the given edge. First applies the default
		 * node style, then applies custom style for the EDGES group.
		 * 
		 * @param edge	edge to apply visual style
		 */
		public function initEdgeStyle(edge:Edge) : void
		{
			// apply default edge style
			edge.attachStyle(VisualStyles.DEFAULT_STYLE,
				_defaultEdgeStyle);
			
			// apply custom style specific to Groups.EDGES
			var style:VisualStyle = this.getGroupStyle(Groups.EDGES);
			
			if (style != null)
			{
				//style.apply(edge);
				edge.attachStyle(Groups.EDGES, style);
			}
		}
		
		/**
		 * Adds a custom visual style for the specified group.
		 * 
		 * @param name	name of the group
		 * @param style	custom visual style for the group
		 */
		public function addGroupStyle(name:String,
			style:VisualStyle) : void
		{
			_groupStyle[name] = style;
			
			this.dispatchEvent(
				new DataChangeEvent(DataChangeEvent.ADDED_GROUP_STYLE,
					{group: name, style: style}));
		}
		
		/**
		 * Removes a custom visual style for the specified group.
		 * 
		 * @param name	name of the group
		 * @return		removed style if succesfull, null if failed
		 */
		public function removeGroupStyle(name:String) : VisualStyle
		{
			var style:VisualStyle = _groupStyle[name];
			
			if (style != null)
			{
				delete _groupStyle[name];
				
				this.dispatchEvent(new DataChangeEvent(
					DataChangeEvent.REMOVED_GROUP_STYLE,
					{group: name, style:style}));
			}
			
			return style;
		}
		
		/**
		 * Gets the visual style defined for the given group name.
		 * 
		 * @param name	name of the group
		 * @return		visual style for the given group
		 */
		public function getGroupStyle(name:String) : VisualStyle
		{
			return _groupStyle[name];
		}
		
		
		//---------------------- PROTECTED FUNCTIONS ---------------------------
		
		/**
		 * Initializes default styles for nodes, edges, compounds, and
		 * bendpoints.
		 */
		protected function initDefaultStyles() : void
		{
			var style:Object;
			
			// init default node style
			
			style = {shape: NodeUIs.RECTANGLE,
				size: 50,
				w: 100,
				h: 50,
				alpha: 0.9,
				fillColor: 0xff8a1b0b,
				lineColor: 0xff333333,
				lineWidth: 1,
				labelText: "node",
				labelOffsetX: 0,
				labelOffsetY: 0,
				labelHorizontalAnchor: TextSprite.CENTER,
				labelVerticalAnchor: TextSprite.MIDDLE,
				selectionGlowColor: 0x00ffff33, // "#ffff33"
				selectionGlowAlpha: 0.9,
				selectionGlowBlur: 8,
				selectionGlowStrength: 6};
			
			_defaultNodeStyle = new VisualStyle(style);
			
			// init default compound node style
			
			style = {shape: CompoundUIs.RECTANGLE,
				alpha: 0.9,
				fillColor: 0xff9ed1dc,
				lineColor: 0xff333333,
				lineWidth: 1,
				labelText: "compound", // TODO no default label?
				labelOffsetX: 0,
				labelOffsetY: 0,
				labelHorizontalAnchor: TextSprite.CENTER,
				labelVerticalAnchor: TextSprite.TOP,
				selectionGlowColor: 0x00ffff33, // "#ffff33"
				selectionGlowAlpha: 0.9,
				selectionGlowBlur: 8,
				selectionGlowStrength: 6,
				paddingLeft: 10,
				paddingRight: 10,
				paddingTop: 10,
				paddingBottom: 10};
			
			_defaultCompoundStyle = new VisualStyle(style);
			
			// init default edge style
			
			style = {shape: EdgeUIs.LINE,				
				fillColor: 0xff000000,
				alpha: 0.8,
				lineColor: 0xff000000,
				lineAlpha: 0.8,
				lineWidth: 1,
				labelText: "edge", // TODO no default label?
				labelPos: EdgeLabeler.TARGET, // TODO change to EdgeLabeler.CENTER
				labelOffsetX: 0,
				labelOffsetY: 0,
				labelHorizontalAnchor: TextSprite.CENTER,
				labelVerticalAnchor: TextSprite.MIDDLE,
				labelDistanceCalculation: EdgeLabeler.PERCENT_DISTANCE,
				labelDistanceFromNode: 30,
				sourceArrowType: ArrowUIs.SIMPLE_ARROW, // TODO no arrows as default?
				targetArrowType: ArrowUIs.SIMPLE_ARROW, // TODO no arrows as default?
				arrowTipAngle: 0.3,
				arrowTipDistance: 15,
				selectionGlowColor: 0x00ffff33, // "#ffff33"
				selectionGlowAlpha: 0.8,
				selectionGlowBlur: 4,
				selectionGlowStrength: 10};
			
			_defaultEdgeStyle = new VisualStyle(style);
			
			// init default style of BEND_NODES group
			
			style = {shape: NodeUIs.CIRCLE,				
				size: 4,
				alpha: 1.0,
				fillColor: 0xff000000,
				lineColor: 0xff000000,
				lineWidth: 1,
				selectionGlowColor: 0x00ffff33, // "#ffff33"
				selectionGlowAlpha: 0.9,
				selectionGlowBlur: 8,
				selectionGlowStrength: 6};
			
			_groupStyle[Groups.BEND_NODES] = new VisualStyle(style);
			
			// TODO other defaults?
			
		}
		
		
	}
}