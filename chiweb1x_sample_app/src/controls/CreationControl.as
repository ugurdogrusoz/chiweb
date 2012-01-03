package controls
{
	
	import flash.display.InteractiveObject;
	
	import ivis.controls.EventControl;
	import ivis.event.ControlEvent;
	import ivis.model.Edge;
	import ivis.model.Node;
	import ivis.model.Style;
	import ivis.model.util.Styles;
	
	import util.Constants;

	/**
	 * This class is designed as an EventControl class to manage node and edge
	 * creation. Attaches required styles to the created node or edge according
	 * to the selection.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class CreationControl extends EventControl
	{		
		/** @inheritDoc */
		public override function attach(obj:InteractiveObject):void
		{
			if (obj == null)
			{
				detach();
				return;
			}
			
			super.attach(obj);
			
			if (obj != null)
			{
				obj.addEventListener(ControlEvent.ADDED_NODE, onAddNode);
				obj.addEventListener(ControlEvent.ADDED_EDGE, onAddEdge);
			}
		}
		
		/** @inheritDoc */
		public override function detach():InteractiveObject
		{
			if (this.object != null)
			{
				this.object.removeEventListener(ControlEvent.ADDED_NODE,
					onAddNode);
				
				this.object.removeEventListener(ControlEvent.ADDED_EDGE,
					onAddEdge);
			}
			
			return super.detach();
		}
		
		/**
		 * Listener function for ADDED_NODE event. Sets the style of the new
		 * node according to the selection (state of a clicked button).
		 * 
		 * @param evt	ControlEvent that triggered the action 
		 */
		protected function onAddNode(evt:ControlEvent):void
		{
			var node:Node = evt.info.sprite as Node;
			
			if (this.stateManager.checkState(Constants.ADD_GRADIENT))
			{
				trace ("[AddNodeControl.onAddNode] gradient: " +
					node.data.id);
				
				// adds the node to the corresponding group
				this.graphManager.graph.addToGroup(Constants.GRADIENT_RECT,
					node);
			}
			else if (this.stateManager.checkState(Constants.ADD_DASHED_TRI))
			{
				trace ("[AddNodeControl.onAddNode] dashed triangle: " +
					node.data.id);
				
				// adds the node to the corresponding group
				this.graphManager.graph.addToGroup(Constants.DASHED_TRIANGLE,
					node);
			}
			else if (this.stateManager.checkState(Constants.ADD_IMAGE_NODE))
			{
				trace ("[AddNodeControl.onAddNode] image node: " +
					node.data.id);
				
				// adds the node to the corresponding group
				this.graphManager.graph.addToGroup(Constants.IMAGE_NODE,
					node);
			}
			
			
			// this style is actually to define a node-specific label using
			// its id property as label text
			var style:Object = {labelText: node.data.id};
			
			// attach node-specific style to this node
			node.attachStyle(Styles.SPECIFIC_STYLE, new Style(style));
			
			// re-apply styles for the node to reflect the changes
			Styles.reApplyStyles(node);
			this.graphManager.view.update();
		}
		
		/**
		 * Listener function for ADDED_EDGE event. Sets the style of the new
		 * edge according to the selection (state of a clicked button).
		 * 
		 * @param evt	ControlEvent that triggered the action 
		 */
		protected function onAddEdge(evt:ControlEvent):void
		{
			var edge:Edge = evt.info.sprite as Edge;
			
			if (this.stateManager.checkState(Constants.ADD_DASHED_EDGE))
			{
				trace ("[AddNodeControl.onAddEdge] dashed: " + edge.data.id);
				
				// adds the edge to the corresponding group
				this.graphManager.graph.addToGroup(Constants.DASHED_EDGE,
					edge);
			}
			
			// this style is actually to define an edge-specific label using
			// its id property as label text
			var style:Object = {labelText: edge.data.id};
			
			// attach node-specific style to this node
			edge.attachStyle(Styles.SPECIFIC_STYLE, new Style(style));
			
			// re-apply styles for the node to reflect the changes
			Styles.reApplyStyles(edge);
			this.graphManager.view.update();
		}
	}
}