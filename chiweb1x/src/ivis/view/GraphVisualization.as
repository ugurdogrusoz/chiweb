package ivis.view
{
	import flare.vis.Visualization;
	import flare.vis.axis.Axes;
	import flare.vis.data.Data;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.operator.label.Labeler;
	
	import flash.geom.Rectangle;
	
	import ivis.model.Edge;
	import ivis.model.Node;
	import ivis.util.Groups;
	import ivis.util.Nodes;

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
		
		//----------------------------- ACCESSORS ------------------------------
		
		/**
		 * Labeler for the edges.
		 */
		public function get edgeLabeler():Labeler
		{
			return _edgeLabeler;
		}
		
		public function set edgeLabeler(value:Labeler):void
		{
			_edgeLabeler = value;
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
			
			var children:Array = Nodes.getChildren(compound);
			
			var directChildren:Array = compound.getNodes();
			
			// for each direct child of the compound node, decide which
			// bendpoints should be taken into account for the bounds 
			for each (var node:Node in directChildren)
			{
				// process each incident edge of the current node
				for each (var edge:Edge in Nodes.incidentEdges(node))
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
			
			if (compound.getNodes().length > 0)
			{
				// calculate&update bounds of the compound node 
				bounds = this.calculateBounds(compound);
				compound.updateBounds(bounds);
			}
			else
			{
				// empty compound, so reset bounds
				compound.resetBounds();
			}
		}
		
		/**
		 * Finds all parentless compounds, and recursively update bounds
		 * in a bottom-up manner.
		 */
		public function updateAllCompoundBounds() : void
		{
			for each (var compound:Node in
				data.group(Groups.COMPOUND_NODES))
			{
				if (compound.isInitialized() && compound.parentN == null)
				{
					// call the recursive function
					updateAllBounds(compound);
				}
			}
		}
		
		//------------------------ PRIVATE FUNCTIONS ---------------------------
		
		/**
		 * Updates the bounds of the given compound, and all its children
		 * recursively, in a bottom-up manner.
		 * 
		 * @param compound	compound node to be updated
		 */
		protected function updateAllBounds(compound:Node) : void
		{	
			for each (var node:Node in compound.getNodes())
			{
				if (node.isInitialized())
				{
					updateAllBounds(node);
				}
			}
			
			this.updateCompoundBounds(compound);
			compound.render();
		}
	}
}