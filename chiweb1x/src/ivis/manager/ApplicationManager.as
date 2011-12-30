package ivis.manager
{
	import flare.display.TextSprite;
	import flare.vis.controls.Control;
	import flare.vis.data.DataSprite;
	import flare.vis.data.NodeSprite;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import ivis.controls.StateManager;
	import ivis.model.Graph;
	import ivis.model.Style;
	import ivis.util.Groups;
	import ivis.view.ui.NodeUIManager;
	
	import mx.core.Container;

	/**
	 * Main class to initialize the application.
	 * 
	 * @author Selcuk Onur Sumer
	 */ 
	public class ApplicationManager
	{
		protected var _graphManager:GraphManager;
		protected var _controlCenter:ControlCenter;
		
		//--------------------------- ACCESSORS --------------------------------
		
		/**
		 * Graph Manager.
		 */
		public function get graphManager():GraphManager
		{
			return _graphManager;
		}
		
		/**
		 * Control Center. 
		 */
		public function get controlCenter():ControlCenter
		{
			return _controlCenter;
		}
		
		//------------------------ CONSTRUCTOR ---------------------------------
		
		/**
		 * Initializes the application by instantiating graph manager and
		 * control center.
		 * 
		 * @param graph	graph for the application
		 */
		public function ApplicationManager(graph:Graph = null)
		{	
			// instantiate manager
			this._graphManager = new GraphManager(graph);
			
			// initialize control center for the visualization
			this._controlCenter = new ControlCenter(this._graphManager);
		}
		
		//---------------------- PUBLIC FUNCTIONS ------------------------------
		
		/**
		 * Sets the Container of the graph view.
		 * 
		 * @param container	container of the graph view
		 * @return			true if view is added to the given container
		 */ 
		public function setGraphContainer(container:Container):Boolean
		{
			var added:Boolean = false;
			
			if (this.graphManager.view.parent != container)
			{
				container.addChild(this.graphManager.view);
				added = true;
			}
			
			return added;
		}
		
		/**
		 * Sets the root container of the application.
		 * 
		 * @param container root container of the application
		 */
		public function setRootContainer(container:Container):void
		{
			var bgColor:uint = this.graphManager.globalConfig.getConfig(
				GlobalConfig.BACKGROUND_COLOR);

			// init style of the root container
			container.setStyle("backgroundColor", bgColor);
		}
		
		//------------------------------ DEBUG ---------------------------------
		// TODO move all of these functions to the example application
		
		public function printGraph():void
		{
			this.graphManager.graph.printGraph();
		}
		
		public function showInspector(event:MouseEvent):void
		{
			//var evt:MouseEvent = evt as MouseEvent;
			
			trace ("custom listener: " + event.localX + ", " + event.localY);
		}
		
		public function createTestGroup() : void
		{
			if (this.graphManager.graph.addGroup("TEST"))
			{
				trace("TEST group added to data");
			}
		}
		
		public function removeTestGroup() : void
		{
			if (this.graphManager.graph.removeGroup("TEST"))
			{
				trace("TEST group removed from data");
			}
		}
		
		public function clearTestGroup() : void
		{
			if (this.graphManager.graph.clearGroup("TEST"))
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
			
			this.graphManager.graphStyleManager.addGroupStyle("TEST",
				new Style(style));
			
			trace("TEST group style added..");
		}
		
		public function removeTestStyle() : void
		{
			this.graphManager.graphStyleManager.removeGroupStyle("TEST");
			
			trace("TEST group style removed..");
		}
		
		public function addToTestGroup() : void
		{
			for each (var ds:DataSprite in this.graphManager.graph.selectedNodes)
			{
				this.graphManager.graph.addToGroup("TEST", ds);
				
				trace("node " + ds.data.id + " added to TEST");
			}
		}
		
		public function removeFromTestGroup() : void
		{
			for each (var ds:DataSprite in this.graphManager.graph.selectedNodes)
			{
				if (this.graphManager.graph.removeFromGroup("TEST", ds))
				{
					trace("node " + ds.data.id + " removed from TEST");
				}
			}
		}
		
		public function addTestProperty() : void
		{
			this.graphManager.graphStyleManager.getGroupStyle("TEST").addProperty(
				"w", 200);
			
			trace("TEST property 'w' is set to 200");
		}
		
		public function removeTestProperty() : void
		{
			this.graphManager.graphStyleManager.getGroupStyle("TEST").removeProperty(
				"w");
			
			trace("TEST property 'w' removed");
		}
		
		// TODO also test specific styles
	}
}