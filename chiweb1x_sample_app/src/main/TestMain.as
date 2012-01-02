package main
{
	import flare.display.TextSprite;
	import flare.vis.data.DataSprite;
	
	import flash.events.MouseEvent;
	
	import ivis.manager.ApplicationManager;
	import ivis.model.Style;
	import ivis.view.ui.NodeUIManager;

	public class TestMain
	{
		public var appManager:ApplicationManager;
		
		public function printGraph():void
		{
			this.appManager.graphManager.graph.printGraph();
		}
		
		public function showInspector(event:MouseEvent):void
		{
			//var evt:MouseEvent = evt as MouseEvent;
			
			trace ("custom listener: " + event.localX + ", " + event.localY);
		}
		
		public function createTestGroup() : void
		{
			if (this.appManager.graphManager.graph.addGroup("TEST"))
			{
				trace("TEST group added to data");
			}
		}
		
		public function removeTestGroup() : void
		{
			if (this.appManager.graphManager.graph.removeGroup("TEST"))
			{
				trace("TEST group removed from data");
			}
		}
		
		public function clearTestGroup() : void
		{
			if (this.appManager.graphManager.graph.clearGroup("TEST"))
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
			
			this.appManager.graphManager.graphStyleManager.addGroupStyle("TEST",
				new Style(style));
			
			trace("TEST group style added..");
		}
		
		public function removeTestStyle() : void
		{
			this.appManager.graphManager.graphStyleManager.removeGroupStyle(
				"TEST");
			
			trace("TEST group style removed..");
		}
		
		public function addToTestGroup() : void
		{
			for each (var ds:DataSprite in
				this.appManager.graphManager.graph.selectedNodes)
			{
				this.appManager.graphManager.graph.addToGroup("TEST", ds);
				
				trace("node " + ds.data.id + " added to TEST");
			}
		}
		
		public function removeFromTestGroup() : void
		{
			for each (var ds:DataSprite in
				this.appManager.graphManager.graph.selectedNodes)
			{
				if (this.appManager.graphManager.graph.removeFromGroup(
					"TEST", ds))
				{
					trace("node " + ds.data.id + " removed from TEST");
				}
			}
		}
		
		public function addTestProperty() : void
		{
			this.appManager.graphManager.graphStyleManager.getGroupStyle(
				"TEST").addProperty("w", 200);
			
			trace("TEST property 'w' is set to 200");
		}
		
		public function removeTestProperty() : void
		{
			this.appManager.graphManager.graphStyleManager.getGroupStyle(
				"TEST").removeProperty("w");
			
			trace("TEST property 'w' removed");
		}
		
		// TODO also test specific styles
	}
}