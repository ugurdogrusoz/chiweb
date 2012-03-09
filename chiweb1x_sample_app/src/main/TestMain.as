package main
{
	import flare.display.TextSprite;
	import flare.vis.data.DataSprite;
	
	import flash.events.MouseEvent;
	
	import ivis.controls.StateManager;
	import ivis.manager.ApplicationManager;
	import ivis.model.Graph;
	import ivis.model.Node;
	import ivis.model.Style;
	import ivis.util.Groups;
	import ivis.view.ui.CompoundUIManager;
	import ivis.view.ui.NodeUIManager;

	/**
	 * A class designed for debug purposes.
	 */
	public class TestMain
	{
		public var appManager:ApplicationManager;
		
		public function TestMain(app:ApplicationManager)
		{
			this.appManager = app;
			
			/*
			var style:Object;
			
			style = {labelHorizontalAnchor: TextSprite.LEFT,
				labelVerticalAnchor: TextSprite.BOTTOM};
			
			this.appManager.graphManager.graphStyleManager.addGroupStyle(
				Groups.NODES, new Style(style));
			
			style = {shape: CompoundUIManager.ROUND_RECTANGLE,
				labelHorizontalAnchor: TextSprite.RIGHT,
				labelVerticalAnchor: TextSprite.TOP,
				paddingLeft: 16,
				paddingRight: 16,
				paddingTop: 16,
				paddingBottom: 16};
			
			this.appManager.graphManager.graphStyleManager.addGroupStyle(
				Groups.COMPOUND_NODES, new Style(style));
			*/
		}
		
		public function printGraph():void
		{
			this.appManager.graphManager.graph.printGraph();
		}
		
		public function printView():void
		{
			this.appManager.graphManager.view.printView();
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
		
		public function convertSelected() : void
		{
			for each (var node:Node in
				this.appManager.graphManager.graph.selectedNodes)
			{
				if (!node.isInitialized())
				{
					this.appManager.graphManager.initCompound(node);
				}
			}
		}
		
		public function revertSelected() : void
		{
			for each (var node:Node in
				this.appManager.graphManager.graph.selectedNodes)
			{
				if (node.isInitialized())
				{
					this.appManager.graphManager.resetCompound(node);
				}
			}
		}
		
		public function reloadGraph(graph:Graph):void
		{
			this.appManager.graphManager.resetGraph(graph);
		}
	}
}