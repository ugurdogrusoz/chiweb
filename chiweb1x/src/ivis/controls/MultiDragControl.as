package ivis.controls
{
	import flare.display.DirtySprite;
	import flare.vis.data.DataSprite;
	
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import ivis.model.Node;
	import ivis.util.Groups;
	import ivis.util.Nodes;
	import ivis.view.GraphView;

	/**
	 * Control class for dragging nodes. It supports multiple node dragging.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class MultiDragControl extends EventControl
	{
		private var _cur:Sprite;
		
		// x and y coordinates of the event target
		private var _mx:Number, _my:Number;
		
		/**
		 * The active item currently being dragged.
		 */
		public function get activeItem():Sprite
		{
			return _cur;
		}
		
		public function MultiDragControl(view:GraphView,
			filter:* = null)
		{
			super(view);
			this.filter = filter;
		}
		
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
			if (_object != null)
			{
				_object.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			}
			
			return super.detach();
		}
		
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
				_cur = s;
				
				// update event target coordinates
				_mx = _object.mouseX;
				_my = _object.mouseY;
				
				if (_cur is DataSprite)
				{
					(_cur as DataSprite).fix();
				}
				
				// add necessary listeners for the drag action
				
				_cur.stage.addEventListener(MouseEvent.MOUSE_MOVE, onDrag);
				_cur.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				
				event.stopPropagation();
			}
			
			this.view.resetMissingChildren();
		}
		
		protected function onDrag(event:Event) : void
		{
			// drag active item by updating x and y coordinates
			
			var x:Number = _object.mouseX;
			var y:Number = _object.mouseY;
			
			var amountX:Number = x - _mx;
			var amountY:Number = y - _my;
			
			_mx = x;
			_my = y;
			
			/*
			if (x != _mx)
			{
				_cur.x += (x - _mx);
				_mx = x;
			}			
			
			if (y != _my)
			{
				_cur.y += (y - _my);
				_my = y;
			}
			*/
			
			if (amountX == 0 &&
				amountY == 0)
			{
				// no need to update anything
				return;
			}
			
			var target:Node;
			
			if (_cur is Node)
			{
				// a node is being dragged
				target = _cur as Node;
			}
			else
			{
				// drag the sprite and return
				
				_cur.x += amountX;
				_cur.y += amountY;
				
				return;
			}
			
			// drag target node and all other necessary nodes as well
			
			var children:Array = new Array();
						
			if (target.props.selected)
			{
				// find missing children of selected nodes
				children = children.concat(this.view.getMissingChildren());
				// drag the other selected nodes as well
				children = children.concat(this.view.getSelectedNodes());
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
			
			//var amountX:Number = evt.amountX;
			//var amountY:Number = evt.amountY;
			
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
					n.props.selected)
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
							if (!node.props.selected
								|| (n == target && !n.props.selected))
							{
								// update the bounds of the compound node
								this.view.vis.updateCompoundBounds(node);
								
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
				this.view.vis.updateLabels(Groups.EDGES);
				
				// necessary for Flash 10.1
				DirtySprite.renderDirty();
			}
		}
		
		protected function onMouseUp(event:MouseEvent) : void
		{
			if (_cur != null)
			{
				// remove listeners after mouse up event
				_cur.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				_cur.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDrag);
				
				if (_cur is DataSprite)
				{
					(_cur as DataSprite).unfix();
				}
				
				event.stopPropagation();
				
				// update edge labels
				this.view.vis.updateLabels(Groups.EDGES);
			}
			
			// reset the active sprite
			_cur = null;
		}
	}
}