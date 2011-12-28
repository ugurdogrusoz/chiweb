package ivis.view
{
	import flare.vis.Visualization;
	import flare.vis.axis.Axes;
	import flare.vis.data.Data;
	import flare.vis.data.NodeSprite;
	import flare.vis.operator.label.Labeler;
	import flare.vis.operator.layout.Layout;
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import ivis.model.Edge;
	import ivis.model.Node;
	import ivis.model.util.Nodes;
	import ivis.util.Groups;

	/**
	 * Visualization instance for the graph data.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class GraphVisualization extends Visualization
	{
		protected var _nodeLabeler:Labeler;
		protected var _compoundLabeler:Labeler;
		protected var _edgeLabeler:Labeler;
		protected var _layout:Layout;
		
		//----------------------------- ACCESSORS ------------------------------
		
		/**
		 * Labeler for the edges.
		 */
		public function get edgeLabeler():Labeler
		{
			if (this._edgeLabeler == null)
			{
				this._edgeLabeler = new EdgeLabeler(); 
			}
			
			return _edgeLabeler;
		}
		
		public function set edgeLabeler(labeler:Labeler):void
		{
			// remove the old labeler
			if (this._edgeLabeler != null)
			{
				this.operators.remove(this._edgeLabeler);
			}
			
			// add new labeler
			if (labeler != null)
			{
				this.operators.add(labeler);
			}
			
			// set the labeler
			this._edgeLabeler = labeler;
		}
		
		/**
		 * Labeler for the compound nodes.
		 */
		public function get compoundLabeler():Labeler
		{
			if (this._compoundLabeler == null)
			{
				this._compoundLabeler = new CompoundNodeLabeler(); 
			}
			
			return _compoundLabeler;
		}
		
		public function set compoundLabeler(labeler:Labeler):void
		{
			// remove the old labeler
			if (this._compoundLabeler != null)
			{
				this.operators.remove(this._compoundLabeler);
			}
			
			// add new labeler
			if (labeler != null)
			{
				this.operators.add(labeler);
			}
			
			// set the labeler
			this._compoundLabeler = labeler;
		}
		
		/**
		 * Labeler for simple (regular) nodes.
		 */
		public function get nodeLabeler():Labeler
		{
			if (this._nodeLabeler == null)
			{
				this._nodeLabeler = new NodeLabeler(); 
			}
			
			return _nodeLabeler;
		}
		
		public function set nodeLabeler(labeler:Labeler):void
		{
			// remove the old labeler
			if (this._nodeLabeler != null)
			{
				this.operators.remove(this._nodeLabeler);
			}
			
			// add new labeler
			if (labeler != null)
			{
				this.operators.add(labeler);
			}
			
			// set the labeler
			this._nodeLabeler = labeler;
		}
		
		/**
		 * Layout operator for the graph.
		 */
		public function get layout():Layout
		{
			return _layout;
		}
		
		public function set layout(layout:Layout):void
		{
			// remove the old layout
			if (this._layout != null)
			{
				this.operators.remove(this._layout);
			}
			
			// add new layout
			if (layout != null)
			{
				this.operators.add(layout);
			}
			
			// set the layout
			this._layout = layout;
		}
		
		//------------------------ CONSTRUCTOR ---------------------------------
		
		/**
		 * Creates a new visualization instance for the provided graph data.
		 * 
		 * @param data	graph data to be visualized
		 */
		public function GraphVisualization(data:Data = null,
			axes:Axes = null)
		{
			super(data, axes);
			
			this._nodeLabeler = null;
			this._compoundLabeler = null;
			this._edgeLabeler = null;
		}
		
		
		//------------------------ PUBLIC FUNCTIONS ----------------------------

		/**
		 * Updates the git area of the visualization with respect to the
		 * given rectangular bounds.
		 * 
		 * @param bounds	rectangular bounds
		 */
		public function updateHitArea(bounds:Rectangle):void
		{
			// get the hit area sprite
			var hit:Sprite = this.getChildByName("_hitArea") as Sprite;
			
			if (bounds == null)
			{
				return;
			}
			
			// if no hit area is created before, create a new one
			if (hit == null)
			{
				hit = new Sprite();
				hit.name = "_hitArea";
				this.addChildAt(hit, 0);
			}
		
			// adjust the hit area
			hit.visible = false;
			hit.mouseEnabled = false;
			hit.graphics.clear();
			hit.graphics.beginFill(0xffffff, 1);
			hit.graphics.drawRect(bounds.x,
				bounds.y,
				bounds.width,
				bounds.height);
			
			// set updated hit area for the visualization
			this.hitArea = hit;
		}
		
		/**
		 * Calculates the bounds of the given compound node. The result of this
		 * calculation is the smaller rectangle surrounding all of the child 
		 * nodes and the edges inside the compound.
		 * 
		 * @param compound	compound node whose bounds to be calculated
		 * @return			calculated rectangular bounds
		 */
		public function calculateBounds(compound:Node):Rectangle
		{
			// operate node labelers
			this.nodeLabeler.operate();
			this.compoundLabeler.operate();
			
			var bounds:Rectangle = new Rectangle();
			
			// do not add invisible children
			var children:Array = Nodes.getChildren(compound, Nodes.VISIBLE);
			
			var directChildren:Array = compound.getNodes(false);
			
			// for each direct child of the compound node, decide which
			// bendpoints should be taken into account for the bounds 
			for each (var node:Node in directChildren)
			{
				// process each incident edge of the current node
				for each (var edge:Edge in
					Nodes.incidentEdges(node, Nodes.VISIBLE))
				{
					// if edge is an actual edge, calculate the lowest common
					// ancestor for the source and target of the edge
					if (!edge.isSegment)
					{
						var lca:NodeSprite = Nodes.calcLowestCommonAncestor(
							edge.source as Node, edge.target as Node);
						
						// if the lca of the nodes is the compound node, then
						// all bend nodes of the edge should also be included
						// into the child list for bounds calculation.
						if (lca === compound)
						{
							children = children.concat(edge.getBendNodes());
						}
					}
				}
			}
			
			var leftBorder:Number = Nodes.borderValue(children, Nodes.LEFT);
			var rightBorder:Number = Nodes.borderValue(children, Nodes.RIGHT);
			var topBorder:Number = Nodes.borderValue(children, Nodes.TOP);
			var bottomBorder:Number = Nodes.borderValue(children, Nodes.BOTTOM);
			
			var width:Number = rightBorder - leftBorder;
			var height:Number = bottomBorder - topBorder;
			
			bounds.x = leftBorder;
			bounds.y = topBorder;
			bounds.width = width;
			bounds.height = height;
			
			return bounds;
		}
		
		/**
		 * Updates the bounds of the given compound node sprite using bounds of
		 * its child nodes. This function does NOT recursively update bounds of
		 * its child compounds, in other words the bounds of all child nodes are
		 * assumed to be up-to-date. This method also updates the coordinates
		 * of the given compound node sprite according to the newly calculated
		 * bounds.
		 * 
		 * @param cns	compound node sprite
		 */
		public function updateCompoundBounds(compound:Node) : void
		{
			var bounds:Rectangle;
			
			if (compound.getNodes(false).length > 0)
			{
				// calculate&update bounds of the compound node 
				bounds = this.calculateBounds(compound);
				compound.updateBounds(bounds);
			}
			else
			{
				// compound has no visible child,
				// update bounds with default width and height values
				compound.bounds.width = compound.w;
				compound.bounds.height = compound.h;
				compound.bounds.x = compound.x - compound.w/2;
				compound.bounds.y = compound.y - compound.h/2;
				
				// update compound node labels
				compoundLabeler.operate();
			}
		}
		
		/**
		 * Finds all parentless visible compounds, and recursively updates
		 * bounds in a bottom-up manner.
		 */
		public function updateAllCompoundBounds() : void
		{
			for each (var compound:Node in
				data.group(Groups.COMPOUND_NODES))
			{
				if (compound.isInitialized() &&
					compound.visible &&
					compound.parentN == null)
				{
					// call the recursive function
					this.updateAllBounds(compound);
				}
			}
		}
		
		/**
		 * Updates the label of the specified data group. If no group is
		 * specified, updates all labels.
		 * 
		 * @param group	data group, valid data groups are:
		 * 				Groups.EDGES, Groups.NODES, and Groups.COMPOUND_NODES.
		 */
		public function updateLabels(group:String = Groups.ALL) : void
		{
			if (group === null ||
				group === Groups.ALL)
			{
				this.edgeLabeler.operate();
				this.nodeLabeler.operate();
				this.compoundLabeler.operate();
			}
			else if (group === Groups.EDGES)
			{
				this.edgeLabeler.operate();
			}
			else if (group === Groups.NODES)
			{
				this.nodeLabeler.operate();
			}
			else if (group === Groups.COMPOUND_NODES)
			{
				this.compoundLabeler.operate();
			}
		}
		
		//------------------------ PROTECTED FUNCTIONS ---------------------------
		
		/**
		 * Updates the bounds of the given compound, and all its children
		 * recursively, in a bottom-up manner.
		 * 
		 * @param compound	compound node to be updated
		 */
		protected function updateAllBounds(compound:Node) : void
		{	
			// get all visible children
			for each (var node:Node in compound.getNodes(false))
			{
				if (node.isInitialized())
				{
					this.updateAllBounds(node);
				}
			}
			
			// recursive call
			this.updateCompoundBounds(compound);
			
			// set compound as dirty
			compound.dirty();
			
			// set all visible incident edges as dirty
			for each (var edge:Edge in
				Nodes.incidentEdges(compound, Nodes.VISIBLE))
			{
				edge.dirty();
			}
		}
	}
}