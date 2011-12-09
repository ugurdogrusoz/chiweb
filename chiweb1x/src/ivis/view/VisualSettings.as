package ivis.view
{
	import flare.display.TextSprite;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import ivis.event.DataChangeDispatcher;
	import ivis.event.DataChangeEvent;
	import ivis.model.Edge;
	import ivis.model.Node;
	import ivis.util.ArrowUIs;
	import ivis.util.CompoundUIs;
	import ivis.util.EdgeUIs;
	import ivis.util.Groups;
	import ivis.util.NodeUIs;

	/**
	 * Visual settings for the graph. This class is designed to define custom
	 * visual styles for the graph elements such as nodes, edges, compounds,
	 * and bendpoints.
	 * 
	 * TODO global settings, per node, per edge settings...
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class VisualSettings
	{
		protected var _defaultGlobalStyle:VisualStyle;
		protected var _defaultNodeStyle:VisualStyle;
		protected var _defaultEdgeStyle:VisualStyle;
		protected var _defaultCompoundStyle:VisualStyle;
		
		protected var _perNodeStyle:Object;
		protected var _perEdgeStyle:Object;
		
		protected var _groupStyle:Object;
		
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
		 * Applies visual styles to the given node. First applies the default
		 * node style, then applies custom style for the NODES group.
		 * 
		 * @param node	node to apply visual style
		 */
		public function applyNodeStyle(node:Node) : void
		{
			// apply default node style
			_defaultNodeStyle.apply(node);
			
			// apply custom style specific to Groups.NODES
			var style:VisualStyle = this.getGroupStyle(Groups.NODES);
			
			if (style != null)
			{
				style.apply(node);
			}
		}
		
		/**
		 * Applies default visual style to the given compound node.
		 * 
		 * @param node	compound node to apply visual style
		 */
		public function applyCompoundStyle(node:Node) : void
		{
			// apply default compound node style
			_defaultCompoundStyle.apply(node);
		}
		
		/**
		 * Applies visual styles to the given edge. First applies the default
		 * node style, then applies custom style for the EDGES group.
		 * 
		 * @param edge	edge to apply visual style
		 */
		public function applyEdgeStyle(edge:Edge) : void
		{
			// apply default edge style
			_defaultEdgeStyle.apply(edge);
			
			// apply custom style specific to Groups.EDGES
			var style:VisualStyle = this.getGroupStyle(Groups.EDGES);
			
			if (style != null)
			{
				style.apply(edge);
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
			
			// TODO also add info
			DataChangeDispatcher.instance.dispatchEvent(
				new DataChangeEvent(DataChangeEvent.ADDED_GROUP_STYLE));
		}
		
		/**
		 * Removes a custom visual style for the specified group.
		 * 
		 * @param name	name of the group
		 */
		public function removeGroupStyle(name:String) : void
		{
			delete _groupStyle[name];
		
			// TODO also add info
			DataChangeDispatcher.instance.dispatchEvent(
				new DataChangeEvent(DataChangeEvent.REMOVED_GROUP_STYLE));
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
				lineWidth: 1};
			
			_groupStyle[Groups.BEND_NODES] = new VisualStyle(style);
			
			// TODO other defaults?
			
		}
	}
}