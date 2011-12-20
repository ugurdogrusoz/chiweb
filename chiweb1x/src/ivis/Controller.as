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
	import ivis.model.Style;
	import ivis.util.Groups;
	import ivis.view.GraphManager;
	import ivis.view.ui.NodeUIManager;

	// TODO currently, this class is used as the main class that inits the
	// application. But, we should provide another mechanism to init the app.
	public class Controller
	{
		protected var _manager:GraphManager;
		protected var _controlCenter:ControlCenter;
		
		public function get manager():GraphManager
		{
			return _manager;
		}
		
		public function Controller()
		{	
			// instantiate manager
			_manager = new GraphManager();
			
			// initialize default controls for the visualization
			_controlCenter = new ControlCenter(_manager);
			
			
			// custom shapes for debugging purposes
			//NodeUIs.registerUI("gradientRect",
			//	GradientRectUI.instance);
			
			// custom listeners for debugging purposes
			
			//_controlCenter.disableDefaultControl(ControlCenter.DRAG_CONTROL);
			//_controlCenter.disableDefaultControl(ControlCenter.CLICK_CONTROL);
			
			//_view.vis.doubleClickEnabled = true;
			
			//_controlCenter.addCustomListener("inspector",
			//	MouseEvent.MOUSE_OVER,
			//	showInspector,
			//	NodeSprite);
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
			this.manager.graph.printGraph();
		}
		
		public function showInspector(event:MouseEvent):void
		{
			//var evt:MouseEvent = evt as MouseEvent;
			
			trace ("custom listener: " + event.localX + ", " + event.localY);
		}
		
		public function createTestGroup() : void
		{
			if (this.manager.graph.addGroup("TEST"))
			{
				trace("TEST group added to data");
			}
		}
		
		public function removeTestGroup() : void
		{
			if (this.manager.graph.removeGroup("TEST"))
			{
				trace("TEST group removed from data");
			}
		}
		
		public function clearTestGroup() : void
		{
			if (this.manager.graph.clearGroup("TEST"))
			{
				trace("TEST group cleared");
			}
		}
		
		public function createTestStyle() : void
		{
			var style:Object = {shape: NodeUIManager.ROUND_RECTANGLE,
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
			
			this.manager.graphStyleManager.addGroupStyle("TEST",
				new Style(style));
			
			trace("TEST group style added..");
		}
		
		public function removeTestStyle() : void
		{
			this.manager.graphStyleManager.removeGroupStyle("TEST");
			
			trace("TEST group style removed..");
		}
		
		public function addToTestGroup() : void
		{
			for each (var ds:DataSprite in this.manager.graph.selectedNodes)
			{
				this.manager.graph.addToGroup("TEST", ds);
				
				trace("node " + ds.data.id + " added to TEST");
			}
		}
		
		public function removeFromTestGroup() : void
		{
			for each (var ds:DataSprite in this.manager.graph.selectedNodes)
			{
				if (this.manager.graph.removeFromGroup("TEST", ds))
				{
					trace("node " + ds.data.id + " removed from TEST");
				}
			}
		}
		
		public function addTestProperty() : void
		{
			this.manager.graphStyleManager.getGroupStyle("TEST").addProperty(
				"w", 200);
			
			trace("TEST property 'w' is set to 200");
		}
		
		public function removeTestProperty() : void
		{
			this.manager.graphStyleManager.getGroupStyle("TEST").removeProperty(
				"w");
			
			trace("TEST property 'w' removed");
		}
		
		// TODO also test specific styles
	}
}