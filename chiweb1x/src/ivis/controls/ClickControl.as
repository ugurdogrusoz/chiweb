package ivis.controls
{
	import flare.display.TextSprite;
	import flare.vis.controls.Control;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	
	import ivis.manager.GraphManager;
	import ivis.model.Edge;
	import ivis.model.Node;
	import ivis.model.util.Edges;
	import ivis.model.util.Nodes;

	/**
	 * Control class for the single click action.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class ClickControl extends EventControl
	{
		// x-cooridnate of the click event
		protected var _evtX:Number;
		
		// y-coordinate of the click event
		protected var _evtY:Number;
		
		// -------------------------- CONSTRUCTOR ------------------------------
		
		public function ClickControl(graphManager:GraphManager,
			stateManager:StateManager,									 
			filter:* = null)
		{
			super(graphManager, stateManager);
			this.filter = filter;
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
				obj.addEventListener(MouseEvent.CLICK, onClick);
				obj.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			}
		}
		
		/** @inheritDoc */
		public override function detach():InteractiveObject
		{
			if (this.object != null)
			{
				this.object.removeEventListener(MouseEvent.CLICK, onClick);
				this.object.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
			}
			
			return super.detach();
		}
		
		//----------------------- PROTECTED FUNCTIONS --------------------------
		
		/**
		 * Listener function for MOUSE_DOWN event. Stores the event cooridantes
		 * when the event is dispatched on the interactive object.
		 * 
		 * @param evt	MouseEvent that triggered the action
		 */
		protected function onDown(evt:MouseEvent):void
		{
			var target:DisplayObject = evt.target as DisplayObject;
			
			this._evtX = evt.stageX;
			this._evtY = evt.stageY;
		}
		
		/**
		 * Listener function for MOUSE_DOWN event. Performs the required action
		 * according to the active state of the StateManager.
		 * 
		 * @param evt	MouseEvent that triggered the action
		 */
		protected function onClick(evt:MouseEvent):void
		{
			var target:DisplayObject = evt.target as DisplayObject;
			
			// check if mouse down & mouse up on same location
			if (this._evtX != evt.stageX ||
				this._evtY != evt.stageY)
			{
				// TODO mouse up on a different location
				return;
			}
			
			// "select" flag is on
			if (this.stateManager.checkState(StateManager.SELECT))
			{
				if (!this.stateManager.checkState(StateManager.SELECT_KEY_DOWN))
				//if (!evt.ctrlKey)
				{
					this.graphManager.resetSelected();
				}
				
				this.graphManager.toggleSelect(target);
			}
			
			// "add node" flag is on
			if (this.stateManager.checkState(StateManager.ADD_NODE))
			{
				// if the event target is another node, then we should add
				// the new node as a child node to the target
				if (target is Node)
				{
					this.graphManager.addNode(this.object.mouseX,
						this.object.mouseY,
						target);
				}
				// if the event target is not a node, then simply add node to
				// the root
				else
				{
					this.graphManager.addNode(this.object.mouseX,
						this.object.mouseY);
				}
			}
			
			// "add bend point" flag is on
			if (this.stateManager.checkState(StateManager.ADD_BENDPOINT))
			{
				// if the event target is an edge, then add a bend point to
				// the target edge
				if (target is Edge)
				{
					this.graphManager.addBendPoint(this.object.mouseX,
						this.object.mouseY,
						target);
				}
			}
			
			// "add edge" flag is on
			if (this.stateManager.checkState(StateManager.ADD_EDGE))
			{
				// if the event target is a node, then add an edge for the
				// target node
				if (target is Node)
				{
					this.graphManager.addEdgeFor(target);
				}
			}
			
			if (target is Node)
			{
				Nodes.bringNodeToFront(target as Node);
			}
			else if (target is Edge)
			{
				var edge:Edge = target as Edge;
				
				if (edge.isSegment)
				{
					// get the parent edge in order to bring all segments and 
					// bend points to front
					Edges.bringEdgeToFront(edge.parentE);
				}
				else
				{
					// just bring the actual edge to front
					Edges.bringEdgeToFront(edge);
				}
			}
			
			// TODO debug
			if (target is Node)
			{
				trace("[ClickControl.onClick] node: " + target);
				
				if ((target as Node).props.label != null)
				{
					var label:TextSprite = (target as Node).props.label
						as TextSprite;
					
					trace("\t" + "lx: " + label.x + " ly: " + label.y +
						" lw: " + label.width + " lh: " + label.height);
				}
			}
			else if (target is Edge)
			{
				trace("[ClickControl.onClick] edge: " + target);
			}
			else
			{
				trace("[ClickControl.onClick] target: " + target + 
					" x:" + evt.stageX + " y:" + evt.stageY);
			}
		}
	}
}