package main
{
	import controls.ButtonControl;
	import controls.CreationControl;
	import controls.CursorControl;
	
	import flare.display.TextSprite;
	import flare.vis.data.DataSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.operator.layout.Layout;
	
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.SpreadMethod;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import gui.RemoteLayoutOptions;
	
	import ivis.controls.EventControl;
	import ivis.controls.StateManager;
	import ivis.manager.ApplicationManager;
	import ivis.manager.GlobalConfig;
	import ivis.model.Style;
	import ivis.util.Groups;
	import ivis.view.ui.ArrowUIManager;
	import ivis.view.ui.CompoundUIManager;
	import ivis.view.ui.EdgeUIManager;
	import ivis.view.ui.IEdgeUI;
	import ivis.view.ui.INodeUI;
	import ivis.view.ui.NodeUIManager;
	
	import layout.RemoteLayout;
	
	import mx.core.Container;
	import mx.core.IFlexDisplayObject;
	import mx.events.MenuEvent;
	import mx.managers.PopUpManager;
	
	import ui.DashedEdgeUI;
	import ui.GradientRectUI;
	import ui.ImageNodeUI;
	
	import util.Constants;
	import util.CursorUtils;

	/**
	 * Main initializer for the Sample application (sample.mxml).
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class SampleMain
	{
		//---------------------------- VARIABLES -------------------------------
		
		public var appManager:ApplicationManager;
		protected var _rootContainer:Container;
		public var remoteLayout:RemoteLayout;
		
		protected var _nodeState:String;
		protected var _edgeState:String;
		protected var _selectedLayout:Object;
		
		private static var _instance:SampleMain = new SampleMain();
		
		/**
		 * Singleton instance. 
		 */
		public static function get instance():SampleMain
		{
			return _instance;
		} 
		
		
		/**
		 * Root container of the application.
		 */
		public function get rootContainer():Container
		{
			return _rootContainer;
		}
		
		public function set rootContainer(value:Container):void
		{
			// set container
			_rootContainer = value;
			
			// also init button control for the root container
			var buttonControl:EventControl = new ButtonControl(_rootContainer);
			this.appManager.controlCenter.addControl(buttonControl);
		}
		
		//-------------------------- CONSTRUCTOR -------------------------------
		
		public function SampleMain()
		{
			this.appManager = new ApplicationManager();
			this.remoteLayout = new RemoteLayout();
			
			this._nodeState = Constants.ADD_CIRCULAR_NODE;
			this._edgeState = Constants.ADD_DEFAULT_EDGE;
			this._selectedLayout = {label: "default",
				type: "remote",
				style: "CoSE"};
			
			this.initCustomStyles();
			this.initUIs();
			this.initControls();
			this.initStates();
		}
		
		//------------------------ PUBLIC FUNCTIONS ----------------------------
		
		/**
		 * Handles main menu events.
		 */
		public function handleMenuCommand(event:MenuEvent):void
		{	
			var label:String = event.label.toString().toLowerCase();
			
			if(label == "remote layout properties")
			{
				var props:IFlexDisplayObject = 
					this.showWindow(RemoteLayoutOptions);
			}
			
			// TODO handle other commands..
		}
		
		/**
		 * Updates the node type according to the selected combo box item.
		 */
		public function setNodeType(event:Event):void
		{
			if (this.appManager.controlCenter.checkState(StateManager.ADD_NODE))
			{
				// deactive state for previous selection
				this.addNode();
				
				// update node state
				this._nodeState = event.currentTarget.selectedItem.state;
				
				// active state for current selection
				this.addNode();
			}
			else
			{
				// only update node state
				this._nodeState = event.currentTarget.selectedItem.state;
			}
		}
		
		/**
		 * Updates the edge type according to the selected combo box item.
		 */
		public function setEdgeType(event:Event):void
		{
			if (this.appManager.controlCenter.checkState(StateManager.ADD_EDGE))
			{
				// deactive state for previous selection
				this.addEdge();
				
				// update edge state
				this._edgeState = event.currentTarget.selectedItem.state;
				
				// active state for current selection
				this.addEdge();
			}
			else
			{
				// only update edge state
				this._edgeState = event.currentTarget.selectedItem.state;
			}
		}
		
		/**
		 * Updates the layout type according to the selected combo box item.
		 */
		public function setLayoutType(event:Event):void
		{
			this._selectedLayout = event.currentTarget.selectedItem;
		}
		
		/**
		 * Toggles selection of graph elements.
		 */
		public function select(event:Event):void
		{
			var state:Boolean = this.appManager.controlCenter.toggleState(
				StateManager.SELECT);
			
			if (event != null)
			{
				// change selected prop of the target button
				event.target.selected = state;
			}
		}
		
		/**
		 * Activates state of selected node type. (Node is created upon clicking
		 * on the canvas or on another node).
		 */
		public function addNode(event:Event = null):void
		{
			var state:Boolean = this.appManager.controlCenter.toggleState(
				this._nodeState);
			
			this.appManager.controlCenter.setState(
				StateManager.ADD_NODE, state);
			
			if (event != null)
			{
				// change selected prop of the target button
				event.target.selected = state;
			}
		}
		
		/**
		 * Activates state of selected edge type. (Edge is created upon clicking
		 * on the canvas or on another node).
		 */
		public function addEdge(event:Event = null):void
		{	
			var state:Boolean = this.appManager.controlCenter.toggleState(
				this._edgeState);
			
			this.appManager.controlCenter.setState(
				StateManager.ADD_EDGE, state);
			
			if (event != null)
			{
				// change selected prop of the target button
				event.target.selected = state;
			}
		}
		
		/**
		 * Performs layout of selected type.
		 */
		public function performLayout(event:Event = null):void
		{	
			if (this._selectedLayout.type == "remote")
			{
				this.performRemoteLayout(this._selectedLayout.style);
			}
			else
			{
				// TODO other layouts
			}			
		}
		
		/**
		 * Activates ADD_CIRCULAR_NODE state. (Node is created upon clicking on
		 * the canvas or on another node).
		 */
		public function addCircularNode():void
		{
			var state:Boolean = this.appManager.controlCenter.toggleState(
				Constants.ADD_CIRCULAR_NODE);
			
			this.appManager.controlCenter.setState(
				StateManager.ADD_NODE, state);
		}
		
		/**
		 * Activates ADD_GRADIENT state. (Node is created upon clicking on
		 * the canvas or on another node).
		 */
		public function addGradientRect():void
		{
			var state:Boolean = this.appManager.controlCenter.toggleState(
				Constants.ADD_GRADIENT);
			
			this.appManager.controlCenter.setState(
				StateManager.ADD_NODE, state);
		}
		
		/**
		 * Activates ADD_IMAGE_NODE state. (Node is created upon clicking on
		 * the canvas or on another node).
		 */
		public function addImageNode():void
		{
			var state:Boolean = this.appManager.controlCenter.toggleState(
				Constants.ADD_IMAGE_NODE);
			
			this.appManager.controlCenter.setState(
				StateManager.ADD_NODE, state);
		}
		
		/**
		 * Activates ADD_BENDPOINT state. (Bend is created upon clicking on
		 * an edge).
		 */
		public function addBendPoint(event:Event = null):void
		{
			var state:Boolean = this.appManager.controlCenter.toggleState(
				StateManager.ADD_BENDPOINT);
			
			if (event != null)
			{
				// change selected prop of the target button
				event.target.selected = state;
			}
		}
		
		/**
		 * Activates ADD_DEFAULT_EDGE state. (Edge is created upon clicking on
		 * canvas).
		 */
		public function addDefaultEdge():void
		{
			var state:Boolean = this.appManager.controlCenter.toggleState(
				Constants.ADD_DEFAULT_EDGE);
			
			this.appManager.controlCenter.setState(
				StateManager.ADD_EDGE, state);
		}
		
		/**
		 * Activates ADD_DASHED_EDGE state. (Edge is created upon clicking on
		 * canvas).
		 */
		public function addDashedEdge():void
		{
			var state:Boolean = this.appManager.controlCenter.toggleState(
				Constants.ADD_DASHED_EDGE);
			
			this.appManager.controlCenter.setState(
				StateManager.ADD_EDGE, state);
		}
		
		/**
		 * Enables panning of the canvas.
		 */
		public function enablePan(event:Event = null):void
		{
			var state:Boolean =
				this.appManager.controlCenter.toggleState(StateManager.PAN);
			
			if(state)
			{
				CursorUtils.showOpenHand();
			}
			else
			{
				CursorUtils.hideOpenHand();
			}
			
			if (event != null)
			{
				// change selected prop of the target button
				event.target.selected = state;
			}
		}
		
		/**
		 * Zooms in by a default scale.
		 */
		public function zoomIn():void
		{
			this.appManager.graphManager.zoomIn();
		}
		
		/**
		 * Zooms out by a default scale.
		 */
		public function zoomOut():void
		{
			this.appManager.graphManager.zoomOut();
		}
		
		/**
		 * Centers and fits the view in canvas.
		 */
		public function fitInCanvas():void
		{
			this.appManager.graphManager.fitInVisibleArea();
		}
		
		/**
		 * Zooms the graph to its actual size.
		 */
		public function actualSize():void
		{
			this.appManager.graphManager.zoomToActual();
		}
		
		/**
		 * Deletes all selected nodes.
		 */
		public function deleteSelected():void
		{
			this.appManager.graphManager.deleteSelected();
		}
		
		/**
		 * Hides all selected nodes.
		 */
		public function hideSelected():void
		{
			this.appManager.graphManager.filterSelected();
		}
		
		/**
		 * Shows all selected nodes.
		 */
		public function showAll():void
		{
			this.appManager.graphManager.resetFilters();
		}
		
		/**
		 * Performs a remote layout.
		 */
		public function performRemoteLayout(style:String):void
		{
			// update layout before performing it
			this.remoteLayout.layoutStyle = style;
			this.appManager.graphManager.setLayout(this.remoteLayout);
			
			// perform layout
			this.appManager.graphManager.performLayout();
		}
		
		/**
		 * Performs a local layout.
		 */
		public function performLocalLayout():void
		{
			// update layout before performing it
			//this.appManager.graphManager.setLayout(_localLayout);
			
			// perform layout
			//this.appManager.graphManager.performLayout();
		}
		
		//------------------------ PROTECTED FUNCTIONS -------------------------
		
		/**
		 * Initializes custom styles for nodes, edges, compound nodes, bend
		 * nodes and for other custom groups.
		 */
		protected function initCustomStyles():void
		{
			var style:Object;
			
			// add group style for gradient node
			
			style = {shape: Constants.GRADIENT_RECT,
				w: 80,
				h: 60,
				alpha: 0.6,
				fillColor: 0xff3e66f0,
				lineWidth: 2,
				labelFontWeight: "bold",
				labelFontStyle: "italic",
				gradientType: GradientType.LINEAR,
				gradientAngle: GradientRectUI.AUTO_ANGLE,
				spreadMethod: SpreadMethod.REFLECT,
				interpolationMethod: InterpolationMethod.RGB};
			
			this.appManager.graphManager.graphStyleManager.addGroupStyle(
				Constants.GRADIENT_RECT, new Style(style));
			
			// add group style for dashed edge
			
			style = {shape: Constants.DASHED_EDGE,				
				fillColor: 0xff000000,
				alpha: 0.8,
				//sourceArrowType: ArrowUIManager.SIMPLE_ARROW,
				targetArrowType: ArrowUIManager.SIMPLE_ARROW,
				onLengthCoeff: 1,
				offLengthCoeff: 2,
				lineColor: 0xff66cc12,
				lineAlpha: 0.5,
				lineWidth: 3};
			
			this.appManager.graphManager.graphStyleManager.addGroupStyle(
				Constants.DASHED_EDGE, new Style(style));
			
			// add group style for image node
			
			style = {shape: Constants.IMAGE_NODE,
				buttonMode: true,
				w: 150,
				h: 50,
				alpha: 0.8,
				fillColor: 0xfffcfcfc,
				lineWidth: 1,
				imageUrl: "http://www.cs.bilkent.edu.tr/~ivis/images/ivis-logo.png",
				labelFontWeight: "bold",
				labelVerticalAnchor: TextSprite.BOTTOM};
			
			this.appManager.graphManager.graphStyleManager.addGroupStyle(
				Constants.IMAGE_NODE, new Style(style));
			
			// add group style for circular node
			
			style = {shape: NodeUIManager.CIRCLE,
				size: 66,				
				alpha: 0.8,
				fillColor: 0xff229fa8,
				lineWidth: 1};
			
			this.appManager.graphManager.graphStyleManager.addGroupStyle(
				Constants.CIRCULAR_NODE, new Style(style));
			
			// add group style for nodes
			
			style = {buttonMode: true, // enables hand cursor when mouse over
				doubleClickEnabled: true}; // enables double click to dispacth 
			
			this.appManager.graphManager.graphStyleManager.addGroupStyle(
				Groups.NODES, new Style(style));
			
			// add group style for edges
			
			style = {buttonMode: true}; // enables hand cursor when mouse over
			
			this.appManager.graphManager.graphStyleManager.addGroupStyle(
				Groups.EDGES, new Style(style));
			
			// add group style for bend nodes
			
			style = {buttonMode: true}; // enables hand cursor when mouse over
			
			this.appManager.graphManager.graphStyleManager.addGroupStyle(
				Groups.BEND_NODES, new Style(style));
			
			// add group style for compound nodes
			
			style = {shape: CompoundUIManager.ROUND_RECTANGLE,
				buttonMode: true, // enables hand cursor when mouse over
				alpha: 0.7,
				fillColor: 0xffa21be0,
				lineWidth: 2,
				labelFontWeight: "bold"};
			
			this.appManager.graphManager.graphStyleManager.addGroupStyle(
				Groups.COMPOUND_NODES, new Style(style));
		}
		
		/**
		 * Register custom UIs.
		 */
		protected function initUIs():void
		{
			NodeUIManager.registerUI(Constants.IMAGE_NODE,
				ImageNodeUI.instance);
			NodeUIManager.registerUI(Constants.GRADIENT_RECT,
				GradientRectUI.instance);
			EdgeUIManager.registerUI(Constants.DASHED_EDGE,
				DashedEdgeUI.instance);
			
			// TODO also create a custom UI for compound nodes?
		}
		
		/**
		 * Init custom controls.
		 */
		protected function initControls():void
		{
			var creationControl:EventControl = new CreationControl();
			var cursorControl:EventControl = new CursorControl();
			
			this.appManager.controlCenter.addControl(creationControl);
			this.appManager.controlCenter.addControl(cursorControl);
			
			this.appManager.controlCenter.addCustomListener("showInspector",
				MouseEvent.DOUBLE_CLICK,
				showInspector,
				NodeSprite);
		}
		
		/**
		 * Initializes custom states to be used in custom controls.
		 */
		protected function initStates():void
		{
			this.appManager.controlCenter.setState(
				Constants.ADD_GRADIENT, false);
			
			this.appManager.controlCenter.setState(
				Constants.ADD_CIRCULAR_NODE, false);
			
			this.appManager.controlCenter.setState(
				Constants.ADD_DEFAULT_EDGE, false);
			
			this.appManager.controlCenter.setState(
				Constants.ADD_DASHED_EDGE, false);
			
			this.appManager.controlCenter.setState(
				Constants.ADD_IMAGE_NODE, false);
		}
		
		/**
		 * Custom listener for DOUBLE_CLICK action on nodes. Shows an inspector
		 * window with node information.
		 */
		protected function showInspector(event:MouseEvent):void
		{
			//var evt:MouseEvent = evt as MouseEvent;
			
			trace ("double click listener: " + event.localX + ", " + event.localY);
			
			// TODO open an inspector window for nodes
		}
		
		/**
		 * Shows a modal window on top of the root container.
		 * 
		 * @param window	Class of the window to be instantiated
		 */
		protected function showWindow(window:Class):IFlexDisplayObject
		{
			var props: IFlexDisplayObject = 
				PopUpManager.createPopUp(this.rootContainer, window, true);
			
			props.x = (this.rootContainer.width - props.width) / 2;
			props.y = (this.rootContainer.height - props.height) / 2;
			
			return props;
		}
	}
}