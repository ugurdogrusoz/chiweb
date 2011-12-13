package ivis
{
	import flare.display.TextSprite;
	import flare.vis.controls.Control;
	import flare.vis.data.DataSprite;
	import flare.vis.data.NodeSprite;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import ivis.controls.ActionState;
	import ivis.controls.ControlCenter;
	import ivis.util.Groups;
	import ivis.util.NodeUIs;
	import ivis.view.CompoundNodeLabeler;
	import ivis.view.EdgeLabeler;
	import ivis.view.GraphView;
	import ivis.view.NodeLabeler;
	import ivis.view.VisualStyle;

	// TODO currently, this class is used as the main class that inits the
	// application. But, we should provide another mechanism to init the app.
	public class Controller
	{
		protected var _view:GraphView;
		protected var _controlCenter:ControlCenter;
		
		public function get view():GraphView
		{
			return _view;
		}
		
		public function Controller()
		{	
			// instantiate view
			_view = new GraphView();
			
			// initialize default controls for the visualization
			_controlCenter = new ControlCenter(_view);
			
			// labeler for debug purposes
			_view.vis.nodeLabeler = new NodeLabeler("props.labelText");
			_view.vis.compoundLabeler = new CompoundNodeLabeler("props.labelText");
			_view.vis.edgeLabeler = new EdgeLabeler("props.labelText");
			
			// custom shapes for debugging purposes
			//NodeUIs.registerUI("gradientRect",
			//	GradientRectUI.instance);
			
			// custom listeners for debugging purposes
			
			//_controlCenter.disableDefaultControl(ControlCenter.DRAG_CONTROL);
			//_controlCenter.disableDefaultControl(ControlCenter.CLICK_CONTROL);
			
			//_view.vis.doubleClickEnabled = true;
			
			_controlCenter.addCustomListener("inspector",
				MouseEvent.MOUSE_OVER,
				showInspector,
				NodeSprite);
		}
		
		public function toggle(state:String):Boolean
		{
			var result:Boolean = false;
			
			if (state == ActionState.ADD_NODE)
			{
				result = _controlCenter.state.toggleAddNode();
			}
			else if (state == ActionState.ADD_EDGE)
			{
				result = _controlCenter.state.toggleAddEdge();
			}
			else if (state == ActionState.ADD_BENDPOINT)
			{
				result = _controlCenter.state.toggleAddBendPoint();
			}
			else if (state == ActionState.SELECT)
			{
				result = _controlCenter.state.toggleSelect();
			}
			
			return result;
		}
		
		//------------------------------ DEBUG ---------------------------------
		
		public function printGraph():void
		{
			this.view.graph.printGraph();
		}
		
		public function showInspector(event:MouseEvent):void
		{
			//var evt:MouseEvent = evt as MouseEvent;
			
			trace ("custom listener: " + event.localX + ", " + event.localY);
		}
		
		public function createTestGroup() : void
		{
			if (this.view.graph.addGroup("TEST"))
			{
				trace("TEST group added to data");
			}
		}
		
		public function removeTestGroup() : void
		{
			if (this.view.graph.removeGroup("TEST"))
			{
				trace("TEST group removed from data");
			}
		}
		
		public function clearTestGroup() : void
		{
			if (this.view.graph.clearGroup("TEST"))
			{
				trace("TEST group cleared");
			}
		}
		
		public function createTestStyle() : void
		{
			var style:Object = {shape: NodeUIs.ROUND_RECTANGLE,
				size: 50,
				w: 120,
				h: 100,
				alpha: 0.4,
				fillColor: 0xff4cbae8,
				lineColor: 0xffff0606,
				lineWidth: 5,
				labelText: "test",
				labelOffsetX: 0,
				labelOffsetY: 0,
				labelHorizontalAnchor: TextSprite.BOTTOM,
				labelVerticalAnchor: TextSprite.LEFT,
				selectionGlowColor: 0x00ccff33, // "#ffff33"
				selectionGlowAlpha: 0.4,
				selectionGlowBlur: 8,
				selectionGlowStrength: 6};
			
			this.view.visualSettings.addGroupStyle("TEST",
				new VisualStyle(style));
			
			trace("TEST group style added..");
		}
		
		public function removeTestStyle() : void
		{
			this.view.visualSettings.removeGroupStyle("TEST");
			
			trace("TEST group style removed..");
		}
		
		public function addToTestGroup() : void
		{
			for each (var ds:DataSprite in this.view.graph.selectedNodes)
			{
				this.view.graph.addToGroup("TEST", ds);
				
				trace("node " + ds.data.id + " added to TEST");
			}
		}
		
		public function removeFromTestGroup() : void
		{
			for each (var ds:DataSprite in this.view.graph.selectedNodes)
			{
				if (this.view.graph.removeFromGroup("TEST", ds))
				{
					trace("node " + ds.data.id + " removed from TEST");
				}
			}
		}
		
		// TODO also test specific styles & style property change event
	}
}