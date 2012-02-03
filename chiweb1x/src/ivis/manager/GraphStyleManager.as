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
		private var _defaultBendStyle:Style;
		
		/**
		 * Map to store group styles.
		 */
		protected var _groupStyleMap:Object;
		
		//----------------------------- ACCESSORS ------------------------------
		
		/**
		 * Names of all groups registered for a style.
		 */
		public function get groupStyleNames():Array
		{
			var names:Array = new Array();
			
			for (var name:String in this._groupStyleMap)
			{
				names.push(name);
			}
			
			return names;
		}
		
		//------------------------- CONSTRUCTOR --------------------------------
		
		/**
		 * Instantiates a new GraphStyleManager by initializing its default
		 * styles.
		 */
		public function GraphStyleManager()
		{
			// initialize group style map
			this._groupStyleMap = new Object();
			
			// initialize default styles
			this.initDefaultStyles();
		}
		
		//---------------------- PUBLIC FUNCTIONS ------------------------------
		
		/**
		 * Attaches default visual style to the given node.
		 * 
		 * @param node	node to attach visual styles
		 */
		public function initNodeStyle(node:Node):void
		{
			// attach default node style
			node.attachStyle(Styles.DEFAULT_STYLE,
				this._defaultNodeStyle);
			
			// attach custom style specific to Groups.NODES
			
//			var style:Style = this.getGroupStyle(Groups.NODES);
//			
//			if (style != null)
//			{
//				node.attachStyle(Groups.NODES, style);
//			}
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
				this._defaultCompoundStyle);
		}
		
		
		/**
		 * Attaches default visual style to the given edge.
		 * 
		 * @param edge	edge to attach visual styles
		 */
		public function initEdgeStyle(edge:Edge):void
		{
			// attach default edge style
			edge.attachStyle(Styles.DEFAULT_STYLE,
				this._defaultEdgeStyle);
			
			// attach custom style specific to Groups.EDGES
//			var style:Style = this.getGroupStyle(Groups.EDGES);
//			
//			if (style != null)
//			{
//				edge.attachStyle(Groups.EDGES, style);
//			}
		}
		
		
		/**
		 * Attaches default visual style to the given bend node.
		 * 
		 * @param node	bend node to attach visual styles
		 */
		public function initBendStyle(node:Node):void
		{
			// attach default compound node style
			node.attachStyle(Styles.DEFAULT_STYLE,
				this._defaultBendStyle);
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
			if (name != null &&
				style != null)
			{
				// add group to the style map
				this._groupStyleMap[name] = style;
				
				// dispatch event to notify listeners
				this.dispatchEvent(
					new DataChangeEvent(DataChangeEvent.ADDED_GROUP_STYLE,
						{group: name, style: style}));
			}
		}
		
		
		/**
		 * Removes a custom visual style for the specified group.
		 * 
		 * @param name	name of the group
		 * @return		removed style if succesfull, null if failed
		 */
		public function removeGroupStyle(name:String):Style
		{
			var style:Style = this._groupStyleMap[name];
			
			if (style != null)
			{
				// remove group from the style map
				delete this._groupStyleMap[name];
				
				// dispatch event to notify listeners
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
			return this._groupStyleMap[name];
		}
		
		
		/**
		 * Removes all group styles from the graph style manager.
		 */
		public function clearGroupStyles():void
		{
			// collect removed style information
			var styles:Object = this._groupStyleMap;
			
			// reset group style map
			this._groupStyleMap = new Object();
			
			// dispatch event to notify listeners
			this.dispatchEvent(new DataChangeEvent(
				DataChangeEvent.CLEARED_GROUP_STYLES,
				{styles:styles}));
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
				w: 60,
				h: 40,
				alpha: 0.8,
				fillColor: 0xFFCF76A8,
				fillAlpha: 0.9,
				lineColor: 0xFF333333,
				lineAlpha: 0.9,
				lineWidth: 1,
				//labelText: "", // empty label by default
				labelTextMode: TextSprite.DEVICE,
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
				fillAlpha: 0.9,
				lineColor: 0xff333333,
				lineAlpha: 0.9,
				lineWidth: 1,
				//labelText: "", // empty label by default
				labelTextMode: TextSprite.DEVICE,
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
				alpha: 0.8,
				fillColor: 0xff000000,
				fillAlpha: 0.8,
				lineColor: 0xff000000,
				lineAlpha: 0.8,
				lineWidth: 1,
				//labelText: "", // empty label by default
				labelTextMode: TextSprite.DEVICE,
				labelPos: EdgeLabeler.MIDDLE,
				labelOffsetX: 0,
				labelOffsetY: 0,
				labelHorizontalAnchor: TextSprite.LEFT,
				labelVerticalAnchor: TextSprite.BOTTOM,
				labelFontName: "Arial",
				labelFontSize: 11,
				labelFontColor: 0xff000000,
				labelFontWeight: "normal",
				labelFontStyle: "normal",
				labelDistanceCalculation: EdgeLabeler.PERCENT_DISTANCE,
				labelDistanceFromNode: 30,
				//sourceArrowType: ArrowUIManager.SIMPLE_ARROW,
				//targetArrowType: ArrowUIManager.SIMPLE_ARROW,
				sourceArrowTipAngle: 0.3,
				sourceArrowTipDistance: 15,
				targetArrowTipAngle: 0.3,
				targetArrowTipDistance: 15,
				selectionGlowColor: 0x00ffff33, // "#ffff33"
				selectionGlowAlpha: 0.8,
				selectionGlowBlur: 4,
				selectionGlowStrength: 10};
			
			this._defaultEdgeStyle = new Style(style);
			
			// init default bendpoint style 
			
			style = {shape: NodeUIManager.CIRCLE,				
				size: 6,
				alpha: 1.0,
				inheritColor: true, // inherit color from parent edge
				fillColor: 0xff000000, // not used when inheritColor is true 
				fillAlpha: 1.0, // not used when inheritColor is true
				lineWidth: 0,
				//labelText: "",
				labelTextMode: TextSprite.DEVICE,
				labelOffsetX: 0,
				labelOffsetY: 0,
				labelHorizontalAnchor: TextSprite.CENTER,
				labelVerticalAnchor: TextSprite.BOTTOM,
				labelFontName: "Arial",
				labelFontSize: 0,
				labelFontColor: 0xff000000,
				labelFontWeight: "normal",
				labelFontStyle: "normal",
				selectionGlowColor: 0x00ffff33, // "#ffff33"
				selectionGlowAlpha: 0.9,
				selectionGlowBlur: 8,
				selectionGlowStrength: 6};
			
			this._defaultBendStyle = new Style(style);
		}
	}
}