package ivis.controls
{
	import flare.display.DirtySprite;
	import flare.vis.data.DataSprite;
	
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import ivis.model.Node;
	import ivis.model.util.Nodes;
	import ivis.util.Groups;
	import ivis.manager.GraphManager;

	/**
	 * Control class for dragging nodes. It supports multiple node dragging.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class MultiDragControl extends EventControl
	{
		protected var _cur:Sprite;
		
		/**
		 * x-coordinate of the event target.
		 */
		protected var _mx:Number;
		
		/**
		 * y-coordinate of the event target.
		 */
		protected var _my:Number;
		
		/**
		 * The active item currently being dragged.
		 */
		public function get activeItem():Sprite
		{
			return _cur;
		}
		
		//-------------------------- CONSTRUCTOR -------------------------------
		
		public function MultiDragControl(graphManager:GraphManager,
			stateManager:StateManager = null,
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
				obj.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			}
		}
		
		/** @inheritDoc */
		public override function detach() : InteractiveObject
		{
			if (this.object != null)
			{
				this.object.removeEventListener(MouseEvent.MOUSE_DOWN,
					onMouseDown);
			}
			
			return super.detach();
		}
		
		//----------------------- PROTECTED FUNCTIONS --------------------------
		
		/**
		 * Listener function for MOUSE_DOWN event.
		 * 
		 * @param evt	MouseEvent that triggered the action
		 */
		protected function onMouseDown(event:MouseEvent) : void
		{
			var s:Sprite = event.target as Sprite;
			
			if (s  == null)
			{
				// exit if not a sprite
				return;
			}
			
			if (_filter == null || _filter(s))
			{
				// update current target
				this._cur = s;
				
				// update event target coordinates
				this._mx = this.object.mouseX;
				this._my = this.object.mouseY;
				
				if (this._cur is DataSprite)
				{
					(this._cur as DataSprite).fix();
				}
				
				// add necessary listeners for the drag action
				this._cur.stage.addEventListener(MouseEvent.MOUSE_MOVE,
					onDrag);
				this._cur.stage.addEventListener(MouseEvent.MOUSE_UP,
					onMouseUp);
				
				event.stopPropagation();
			}
			
			this.graphManager.resetMissingChildren();
		}
		
		/**
		 * Listener function for MOUSE_MOVE event. Updates the coordiantes
		 * of the elements to drag.
		 * 
		 * @param evt	MouseEvent that triggered the action
		 */
		protected function onDrag(event:Event) : void
		{
			// drag active item by updating x and y coordinates
			
			var x:Number = this.object.mouseX;
			var y:Number = this.object.mouseY;
			
			var amountX:Number = x - this._mx;
			var amountY:Number = y - this._my;
			
			this._mx = x;
			this._my = y;
			
			if (amountX == 0 &&
				amountY == 0)
			{
				// no need to update anything
				return;
			}
			
			var target:Node;
			
			if (this._cur is Node)
			{
				// a node is being dragged
				target = this._cur as Node;
			}
			else
			{
				// drag the sprite and return
				this._cur.x += amountX;
				this._cur.y += amountY;
				
				return;
			}
			
			// drag target node and all other necessary nodes as well
			
			var children:Array = new Array();
						
			if (target.props.$selected)
			{
				// find missing children of selected nodes
				children = children.concat(this.graphManager.getMissingChildren());
				// drag the other selected nodes as well
				children = children.concat(this.graphManager.getSelectedNodes());
			}
			else
			{
				// drag all direct & indirect children of the target node
				children = children.concat(Nodes.getChildren(target));
				// also drag inner bendpoints (bend nodes) of the target
				children = children.concat(Nodes.innerBends(target));
				// and, drag the target node...
				children = children.concat([target]);
			}
			
			//updateCursor();
			
			var node:Node;
			var n:Node;
			
			// drag all necessary nodes & labels
			
			for each (n in children)
			{
				/*
				if (n != target)
				{
					n.x += amountX;
					n.y += amountY;
				}
				*/
				
				n.x += amountX;
				n.y += amountY;
				
				// move node labels, bacause they have "LAYER" policy
				if (n.props.label != null)
				{
					n.props.label.x += amountX;
					n.props.label.y += amountY;
				}
				
				var parent:Node;
				
				// update parent compound node(s) bounds if necessary
				// if n is target node, then its parents may need to be updated.
				// if n is a selected node, then other selected nodes' parents
				// also need to be updated. (it causes problems to update bounds
				// of a compound node which is also being dragged, therefore
				// bounds updating should only be applied on the compound nodes
				// which are not being dragged)
				
				if (n == target ||
					n.props.$selected)
				{
					node = n;
					
					// if node to be dragged is a bend node, parent should be
					// set as the corresponding lca
					if (node.isBendNode)
					{
						parent = Nodes.calcLowestCommonAncestor(
							node.parentE.source as Node,
							node.parentE.target as Node);
					} 
					else
					{
						parent = node.parentN;
					}
					
					while (parent != null)
					{	
						node = parent;
						
						if (node != null)
						{
							// only update if the parent is not also being
							// dragged
							if (!node.props.$selected
								|| (n == target && !n.props.$selected))
							{
								// update the bounds of the compound node
								this.graphManager.view.updateCompoundBounds(node);
								
								// render the compound node with the new bounds
								node.render();
							}
							
							parent = node.parentN;
						}
						else
						{
							// reached top, no more parent
							parent = null;
						}
					}
				}
				
				// update bound coordinates of dragged compound nodes
				
				if (n.bounds != null)
				{
					n.bounds.x += amountX;
					n.bounds.y += amountY;
				}
				
				// update edge labels
				this.graphManager.view.updateLabels(Groups.EDGES);
				
				// necessary for Flash 10.1
				DirtySprite.renderDirty();
			}
		}
		
		
		/**
		 * Listener function for MOUSE_UP event.
		 * 
		 * @param evt	MouseEvent that triggered the action
		 */
		protected function onMouseUp(event:MouseEvent) : void
		{
			if (this._cur != null)
			{
				// remove listeners after mouse up event
				this._cur.stage.removeEventListener(MouseEvent.MOUSE_UP,
					onMouseUp);
				this._cur.stage.removeEventListener(MouseEvent.MOUSE_MOVE,
					onDrag);
				
				if (this._cur is DataSprite)
				{
					(this._cur as DataSprite).unfix();
				}
				
				// TODO is this necessary?
				event.stopPropagation();
				
				// update edge labels
				this.graphManager.view.updateLabels(Groups.EDGES);
			}
			
			// reset the active sprite
			this._cur = null;
		}
	}
}