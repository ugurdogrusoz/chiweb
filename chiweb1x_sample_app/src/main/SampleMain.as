package main
{
	import controls.CreationControl;
	
	import ivis.controls.EventControl;
	import ivis.controls.StateManager;
	import ivis.manager.ApplicationManager;
	import ivis.model.Style;
	import ivis.view.ui.EdgeUIManager;
	import ivis.view.ui.IEdgeUI;
	import ivis.view.ui.INodeUI;
	import ivis.view.ui.NodeUIManager;
	
	import ui.DashedEdgeUI;
	import ui.GradientRectUI;
	
	import util.Constants;

	/**
	 * Main initializer for the Sample application (sample.mxml).
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class SampleMain
	{
		public var appManager:ApplicationManager;
		
		public function SampleMain()
		{
			this.appManager = new ApplicationManager();
			this.initCustomStyles();
			this.initUIs();
			this.initControls();
			this.initStates();
		}
		
		public function addDashedTriangle():void
		{
			var state:Boolean = this.appManager.controlCenter.toggleState(
				Constants.ADD_DASHED_TRI);
			
			this.appManager.controlCenter.stateManager.setState(
				StateManager.ADD_NODE, state);
		}
		
		public function addGradientRect():void
		{
			var state:Boolean = this.appManager.controlCenter.toggleState(
				Constants.ADD_GRADIENT);
			
			this.appManager.controlCenter.stateManager.setState(
				StateManager.ADD_NODE, state);
		}
		
		public function addImageNode():void
		{
			var state:Boolean = this.appManager.controlCenter.toggleState(
				Constants.ADD_IMAGE_NODE);
			
			this.appManager.controlCenter.stateManager.setState(
				StateManager.ADD_NODE, state);
		}
		
		public function addBendPoint():void
		{
			this.appManager.controlCenter.toggleState(
				StateManager.ADD_BENDPOINT);
		}
		
		public function addDefaultEdge():void
		{
			this.appManager.controlCenter.toggleState(
				StateManager.ADD_EDGE);
		}
		
		public function addDashedEdge():void
		{
			var state:Boolean = this.appManager.controlCenter.toggleState(
				Constants.ADD_DASHED_EDGE);
			
			this.appManager.controlCenter.stateManager.setState(
				StateManager.ADD_EDGE, state);
		}
		
		public function enablePan():void
		{
			this.appManager.controlCenter.toggleState(StateManager.PAN);
		}
		
		public function deleteSelected():void
		{
			this.appManager.graphManager.deleteSelected();
		}
		
		public function hideSelected():void
		{
			this.appManager.graphManager.filterSelected();
		}
		
		public function showAll():void
		{
			this.appManager.graphManager.resetFilters();
		}
		
		public function performRemoteLayout():void
		{
			// TODO update layout before performing it
			this.appManager.graphManager.performLayout();
		}
		
		public function performLocalLayout():void
		{
			// TODO update layout before performing it
			this.appManager.graphManager.performLayout();
		}
		
		protected function initCustomStyles():void
		{
			var style:Object;
			
			// TODO list:
			// 1) define custom styles for nodes, edges, compounds, and bends
			// 2) define additional data groups for nodes and edges, define custom styles for the new groups
			
			
			// add group styles
			style = {shape: Constants.GRADIENT_RECT,
				size: 50,
				w: 60,
				h: 60,
				alpha: 0.9,
				fillColor: 0xff3e66f0,
				lineWidth: 2,
				labelFontWeight: "bold",
				labelFontStyle: "italic"};
			
			this.appManager.graphManager.graphStyleManager.addGroupStyle(
				Constants.GRADIENT_RECT, new Style(style));
			
			style = {shape: Constants.DASHED_EDGE,				
				fillColor: 0xff000000,
				alpha: 0.8,
				//sourceArrowType: ArrowUIManager.SIMPLE_ARROW,
				//targetArrowType: ArrowUIManager.SIMPLE_ARROW
				lineColor: 0xff000000,
				lineAlpha: 0.8,
				lineWidth: 2};
			
			this.appManager.graphManager.graphStyleManager.addGroupStyle(
				Constants.DASHED_EDGE, new Style(style));
			/*
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
			
			_groupStyleMap[Groups.BEND_NODES] = new Style(style);
			*/
		}
		
		protected function initUIs():void
		{
			var gradient:INodeUI = new GradientRectUI();
			var dashedEdge:IEdgeUI = new DashedEdgeUI();
			
			NodeUIManager.registerUI(Constants.GRADIENT_RECT, gradient);
			EdgeUIManager.registerUI(Constants.DASHED_EDGE, dashedEdge);
		}
		
		protected function initControls():void
		{
			var nodeControl:EventControl = new CreationControl();
			
			this.appManager.controlCenter.addControl(nodeControl);
		}
		
		protected function initStates():void
		{
			this.appManager.controlCenter.stateManager.setState(
				Constants.ADD_GRADIENT, false);
			
			this.appManager.controlCenter.stateManager.setState(
				Constants.ADD_DASHED_TRI, false);
			
			this.appManager.controlCenter.stateManager.setState(
				Constants.ADD_DASHED_EDGE, false);
			
			this.appManager.controlCenter.stateManager.setState(
				Constants.ADD_IMAGE_NODE, false);
		}
	}
}