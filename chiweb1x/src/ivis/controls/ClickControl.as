package ivis.controls
{
	import flare.display.TextSprite;
	import flare.vis.controls.Control;
	import flare.vis.data.DataSprite;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	
	import ivis.event.ControlEvent;
	import ivis.manager.GraphManager;
	import ivis.model.Edge;
	import ivis.model.Node;
	import ivis.model.util.Edges;
	import ivis.model.util.Nodes;

	/**
	 * Control class for the single click event.
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
				obj.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			}
		}
		
		/** @inheritDoc */
		public override function detach():InteractiveObject
		{
			if (this.object != null)
			{
				this.object.removeEventListener(MouseEvent.CLICK, onClick);
				this.object.removeEventListener(MouseEvent.MOUSE_DOWN,
					onMouseDown);
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
		protected function onMouseDown(evt:MouseEvent):void
		{
			var target:DisplayObject = evt.target as DisplayObject;
			
			this._evtX = evt.stageX;
			this._evtY = evt.stageY;
		}
		
		/**
		 * Listener function for CLICK event. Performs the required action
		 * according to the active state of the StateManager.
		 * 
		 * @param evt	MouseEvent that triggered the action
		 */
		protected function onClick(evt:MouseEvent):void
		{
			var target:DisplayObject = evt.target as DisplayObject;
			var eventType:String = null;
			var ds:DataSprite = null;
			
			// check if mouse down & mouse up on same location
			if (this._evtX != evt.stageX ||
				this._evtY != evt.stageY)
			{
				// mouse up on a different location, so the action should not
				// considered as a click...
				return;
			}
			
			// SELECT flag is on
			if (this.stateManager.checkState(StateManager.SELECT))
			{
				if (!this.stateManager.checkState(StateManager.SELECT_KEY_DOWN))
				{
					this.graphManager.resetSelected();
				}
				
				if (this.graphManager.toggleSelect(target))
				{
					ds = target as DataSprite;
					eventType = ControlEvent.TOGGLED_SELECTION;
				}
			}
			
			// ADD_NODE flag is on
			if (this.stateManager.checkState(StateManager.ADD_NODE))
			{
				// if AUTO_COMPOUND flag is set, then clicking on another node
				// will add the new node as a child node to the target node
				if (this.stateManager.checkState(StateManager.AUTO_COMPOUND)
					&& target is Node)
				{
					ds = this.graphManager.addNode(this.object.mouseX,
						this.object.mouseY,
						target);
				}
				// if AUTO_COMPOUND flag is false, or the event target is not
				// a node, then simply add node to the root
				else
				{
					ds = this.graphManager.addNode(this.object.mouseX,
						this.object.mouseY);
				}
				
				eventType = ControlEvent.ADDED_NODE;
			}
			
			// ADD_BENDPOINT flag is on
			if (this.stateManager.checkState(StateManager.ADD_BENDPOINT))
			{
				// if the event target is an edge, then add a bend point to
				// the target edge
				if (target is Edge)
				{
					ds = this.graphManager.addBendPoint(this.object.mouseX,
						this.object.mouseY,
						target);
					
					eventType = ControlEvent.ADDED_BEND;
				}
			}
			
			// ADD_EDGE flag is on
			if (this.stateManager.checkState(StateManager.ADD_EDGE))
			{
				// try to add an edge for the event target
				ds = this.graphManager.addEdgeFor(target);
				
				// if the event target is not a node, or it is a bend point,
				// then the return value (ds) will be null
				if (ds != null)
				{
					if (ds is Node)
					{
						// if ds is Node, it means source node is set, so
						// the event to dispatch should be ADDING_EDGE
						eventType = ControlEvent.ADDING_EDGE;
						
						this.stateManager.setState(StateManager.ADDING_EDGE,
							true);
						
						// add listener to handle cancel between two clicks
						this.stateManager.addEventListener(
							ControlEvent.RESET_STATES,
							onResetStates);
					}
					else // ds is Edge
					{
						// if ds is Edge, it means edge added successfully, so
						// the event to dispatch should be ADDED_EDGE
						eventType = ControlEvent.ADDED_EDGE;
						
						this.stateManager.setState(StateManager.ADDING_EDGE,
							false);
						
						// remove state listener
						this.stateManager.removeEventListener(
							ControlEvent.RESET_STATES,
							onResetStates);
					}
				}
			}
			
			// bring target sprite to front 
			
			if (target is Node)
			{
				// bring target node to the front
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
			
			// DEBUG: click information
			if (target is Node)
			{
				trace("[ClickControl.onClick] node: " + target);
				
				if ((target as Node).props.$label != null)
				{
					var label:TextSprite = (target as Node).props.$label
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
			
			// dispatch a new control event
			if (eventType != null
				&& this.object.hasEventListener(eventType))
			{
				if (ds == null)
				{
					this.object.dispatchEvent(new ControlEvent(eventType));
				}
				else
				{
					this.object.dispatchEvent(new ControlEvent(eventType,
						{sprite: ds}));
				}
			}
		}
		
		/**
		 * Function to listen event of type RESET_STATES. This function is to
		 * reset sourceNode of edge adding process, if the process is cancelled
		 * after clicking the source node. 
		 */
		protected function onResetStates(event:ControlEvent):void
		{
			// this is required if edge adding process is cancelled
			// after clicking the first (source) node.
			this.graphManager.resetSourceNode();
		}
	}
}