package ivis.manager
{
	import flare.display.TextSprite;
	
	import flash.events.EventDispatcher;
	
	import ivis.event.DataChangeEvent;
	import ivis.model.Edge;
	import ivis.model.Node;
	import ivis.model.Style;
	import ivis.model.util.Styles;
	import ivis.util.Groups;
	import ivis.view.EdgeLabeler;
	import ivis.view.ui.ArrowUIManager;
	import ivis.view.ui.CompoundUIManager;
	import ivis.view.ui.EdgeUIManager;
	import ivis.view.ui.NodeUIManager;
	
	import mx.core.Container;

	/**
	 * Style manager for the graph. This class is designed to define custom
	 * group styles for the graph elements such as nodes, edges, compounds,
	 * and bendpoints.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class GraphStyleManager extends EventDispatcher
	{
		private var _defaultNodeStyle:Style;
		private var _defaultEdgeStyle:Style;
		private var _defaultCompoundStyle:Style;
		
		protected var _groupStyleMap:Object;
		
		/**
		 * Default visual styles for nodes.
		 */
		public function get defaultNodeStyle():Style
		{
			return _defaultNodeStyle;
		}
		
		/**
		 * Default visual styles for edges.
		 */
		public function get defaultEdgeStyle():Style
		{
			return _defaultEdgeStyle;
		}
		
		/**
		 * Default visual styles for compound nodes.
		 */
		public function get defaultCompoundStyle():Style
		{
			return _defaultCompoundStyle;
		}
		
		//------------------------- CONSTRUCTOR --------------------------------
		
		public function GraphStyleManager()
		{
			// initialize group style map
			_groupStyleMap = new Object();
			
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
		public function initNodeStyle(node:Node):void
		{
			// attach default node style
			node.attachStyle(Styles.DEFAULT_STYLE,
				_defaultNodeStyle);
			
			// attach custom style specific to Groups.NODES
			
			var style:Style = this.getGroupStyle(Groups.NODES);
			
			if (style != null)
			{
				node.attachStyle(Groups.NODES, style);
			}
		}
		
		/**
		 * Attaches default visual style to the given compound node.
		 * 
		 * @param node	compound node to attach visual styles
		 */
		public function initCompoundStyle(node:Node):void
		{
			// attach default compound node style
			node.attachStyle(Styles.DEFAULT_STYLE,
				_defaultCompoundStyle);
		}
		
		/**
		 * Attaches visual styles to the given edge. First attaches the default
		 * node style, then attaches custom style for the EDGES group.
		 * 
		 * @param edge	edge to attach visual styles
		 */
		public function initEdgeStyle(edge:Edge):void
		{
			// attach default edge style
			edge.attachStyle(Styles.DEFAULT_STYLE,
				_defaultEdgeStyle);
			
			// attach custom style specific to Groups.EDGES
			var style:Style = this.getGroupStyle(Groups.EDGES);
			
			if (style != null)
			{
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
			style:Style):void
		{
			_groupStyleMap[name] = style;
			
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
		public function removeGroupStyle(name:String):Style
		{
			var style:Style = _groupStyleMap[name];
			
			if (style != null)
			{
				delete _groupStyleMap[name];
				
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
		public function getGroupStyle(name:String):Style
		{
			return _groupStyleMap[name];
		}
		
		
		//---------------------- PROTECTED FUNCTIONS ---------------------------
		
		/**
		 * Initializes default styles for nodes, edges, compounds, and
		 * bendpoints.
		 */
		protected function initDefaultStyles():void
		{
			var style:Object;
			
			// init default node style
			
			style = {shape: NodeUIManager.RECTANGLE,
				size: 50,
				w: 100,
				h: 50,
				alpha: 0.9,
				fillColor: 0xff8a1b0b,
				lineColor: 0xff333333,
				lineWidth: 1,
				labelText: "", 
				labelOffsetX: 0,
				labelOffsetY: 0,
				labelHorizontalAnchor: TextSprite.CENTER,
				labelVerticalAnchor: TextSprite.MIDDLE,
				labelFontName: "Arial",
				labelFontSize: 11,
				labelFontColor: 0xff000000,
				labelFontWeight: "normal",
				labelFontStyle: "normal",
				selectionGlowColor: 0x00ffff33, // "#ffff33"
				selectionGlowAlpha: 0.9,
				selectionGlowBlur: 8,
				selectionGlowStrength: 6};
			
			this._defaultNodeStyle = new Style(style);
			
			// init default compound node style
			
			style = {shape: CompoundUIManager.RECTANGLE,
				size: 50,
				w: 100,
				h: 50,
				alpha: 0.9,
				fillColor: 0xff9ed1dc,
				lineColor: 0xff333333,
				lineWidth: 1,
				labelText: "",
				labelOffsetX: 0,
				labelOffsetY: 0,
				labelHorizontalAnchor: TextSprite.CENTER,
				labelVerticalAnchor: TextSprite.TOP,
				labelFontName: "Arial",
				labelFontSize: 11,
				labelFontColor: 0xff000000,
				labelFontWeight: "normal",
				labelFontStyle: "normal",
				selectionGlowColor: 0x00ffff33, // "#ffff33"
				selectionGlowAlpha: 0.9,
				selectionGlowBlur: 8,
				selectionGlowStrength: 6,
				paddingLeft: 10,
				paddingRight: 10,
				paddingTop: 10,
				paddingBottom: 10};
			
			this._defaultCompoundStyle = new Style(style);
			
			// init default edge style
			
			style = {shape: EdgeUIManager.LINE,				
				fillColor: 0xff000000,
				alpha: 0.8,
				lineColor: 0xff000000,
				lineAlpha: 0.8,
				lineWidth: 1,
				labelText: "",
				labelPos: EdgeLabeler.MIDDLE,
				labelOffsetX: 0,
				labelOffsetY: 0,
				labelHorizontalAnchor: TextSprite.CENTER,
				labelVerticalAnchor: TextSprite.MIDDLE,
				labelDistanceCalculation: EdgeLabeler.PERCENT_DISTANCE,
				labelDistanceFromNode: 30,
				//sourceArrowType: ArrowUIManager.SIMPLE_ARROW,
				//targetArrowType: ArrowUIManager.SIMPLE_ARROW,
				arrowTipAngle: 0.3,
				arrowTipDistance: 15,
				selectionGlowColor: 0x00ffff33, // "#ffff33"
				selectionGlowAlpha: 0.8,
				selectionGlowBlur: 4,
				selectionGlowStrength: 10};
			
			this._defaultEdgeStyle = new Style(style);
			
			// init default style of BEND_NODES group
			
			style = {shape: NodeUIManager.CIRCLE,				
				size: 4,
				alpha: 1.0,
				fillColor: 0xff000000,
				lineColor: 0xff000000,
				lineWidth: 1,
				selectionGlowColor: 0x00ffff33, // "#ffff33"
				selectionGlowAlpha: 0.9,
				selectionGlowBlur: 8,
				selectionGlowStrength: 6};
			
			// TODO _defaultBendStyle instead of adding a group style?
			
			_groupStyleMap[Groups.BEND_NODES] = new Style(style);
			
			// TODO other defaults?
			
		}
	}
}