package controls
{
	
	import flare.vis.data.DataSprite;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.InteractiveObject;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	
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
		/**
		 * Shape to animate edge adding process.
		 */
		protected var _previewEdge:Shape;
		
		/**
		 * Source node required as a starting point to animate edge adding.
		 */
		protected var _sourceNode:DataSprite;
		
		//-------------------------- CONSTRUCTOR -------------------------------
		
		public function CreationControl()
		{
			super();
			
			this._previewEdge = new Shape();
		}
		
		//----------------------- PUBLIC FUNCTIONS -----------------------------
		
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
				obj.addEventListener(ControlEvent.ADDING_EDGE, onAddingEdge);
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
		
		//----------------------- PROTECTED FUNCTIONS --------------------------
		
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
			else if (this.stateManager.checkState(Constants.ADD_CIRCULAR_NODE))
			{
				trace ("[AddNodeControl.onAddNode] dashed triangle: " +
					node.data.id);
				
				// adds the node to the corresponding group
				this.graphManager.graph.addToGroup(Constants.CIRCULAR_NODE,
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
			else if (this.stateManager.checkState(Constants.ADD_COMPOUND_NODE))
			{
				trace ("[AddNodeControl.onAddNode] compound node: " +
					node.data.id);
				
				// initializes node as an empty compound node
				this.graphManager.initCompound(node);
			}
			
			// define a node-specific label using its id property
			node.data.label = node.data.id;
			
			// define a node-specific style
			//var style:Object = {labelText: node.data.id};
			
			// attach node-specific style to this node
			//node.attachStyle(Styles.SPECIFIC_STYLE, new Style(style));
			
			// re-apply styles for the node to reflect the changes
			//Styles.reApplyStyles(node);
			
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
			
			if (this.object != null &&
				this.object is DisplayObjectContainer)
			{
				// remove listeners (for the animation of preview edge)
				
				this.object.removeEventListener(MouseEvent.MOUSE_MOVE,
					onMouseMove);
				
				if (this.stateManager != null)
				{
					this.stateManager.removeEventListener(
						ControlEvent.RESET_STATES,
						onResetStates);
				}
				
				// disable preview edge
				
				this._previewEdge.graphics.clear();
				
				(this.object as DisplayObjectContainer).removeChild(
					this._previewEdge);
			}
			
			if (this.stateManager.checkState(Constants.ADD_DASHED_EDGE))
			{
				trace ("[AddNodeControl.onAddEdge] dashed: " + edge.data.id);
				
				// adds the edge to the corresponding group
				this.graphManager.graph.addToGroup(Constants.DASHED_EDGE,
					edge);
			}
			
			// define an edge-specific label using its id property
			edge.data.label = edge.data.id;
			
			// define an edge-specific style
			//var style:Object = {labelText: edge.data.id};
			
			// attach edge-specific style to this edge
			//edge.attachStyle(Styles.SPECIFIC_STYLE, new Style(style));
			
			// re-apply styles for the edge to reflect the changes
			//Styles.reApplyStyles(edge);
			
			this.graphManager.view.update();
		}
		
		/**
		 * Listener function for ADDING_EDGE event. Adds listener for MOUSE_MOVE
		 * event to enable preview of the edge between two clicks of edge 
		 * adding process.
		 * 
		 * @param evt	ControlEvent that triggered the action
		 */
		protected function onAddingEdge(evt:ControlEvent):void
		{
			if (this.object != null &&
				this.object is DisplayObjectContainer)
			{
				// update source node
				this._sourceNode = evt.info.sprite;
				
				// enable preview edge
				(this.object as DisplayObjectContainer).addChild(
					this._previewEdge);
				
				// add mouse listener for the animation of the preview edge
				this.object.addEventListener(MouseEvent.MOUSE_MOVE,
					onMouseMove);
				
				// add listener for state manager to reset edge animation when
				// states reset
				if (this.stateManager != null)
				{
					this.stateManager.addEventListener(
						ControlEvent.RESET_STATES,
						onResetStates);
				}
			}
		}
		
		/**
		 * Listener function for MOUSE_MOVE event. Renders a preview edge
		 * from the center of the source node to the current location of the
		 * mouse.
		 * 
		 * @param evt	MouseEvent that triggered the action  
		 */
		protected function onMouseMove(evt:MouseEvent):void
		{
			var g:Graphics = this._previewEdge.graphics;
			
			var startX:Number = this._sourceNode.x;
			var startY:Number = this._sourceNode.y;
			
			var endX:Number = this.object.mouseX;
			var endY:Number = this.object.mouseY;
			
			g.clear();
			
			// TODO also customize preview edge with global configuration?
			g.lineStyle(1, 0xff222222, 0.5);
			//g.lineStyle(lineWidth, color, lineAlpha, 
			//	pixelHinting, scaleMode, caps, joints, miterLimit);
			
			g.moveTo(startX, startY);
			g.lineTo(endX, endY);
		}
		
		/**
		 * Listener for RESET_STATES event. This function is to disable preview
		 * edge if the edge creation process is cancelled after clicking on
		 * the first (source) node.
		 */
		protected function onResetStates(evt:ControlEvent):void
		{
			if (this.object != null)
			{
				// disable preview edge
				this._previewEdge.graphics.clear();
			
				(this.object as DisplayObjectContainer).removeChild(
					this._previewEdge);
				
				// remove MOUSE_MOVE listener
				this.object.removeEventListener(MouseEvent.MOUSE_MOVE,
					onMouseMove);
			}
			
			if (this.stateManager != null)
			{
				// remove this listener
				this.stateManager.removeEventListener(
					ControlEvent.RESET_STATES,
					onResetStates);
			}
		}
	}
}