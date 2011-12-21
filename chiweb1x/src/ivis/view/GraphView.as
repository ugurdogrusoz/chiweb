package ivis.view
{
	import flare.vis.Visualization;
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	
	import flash.display.DisplayObject;
	import flash.filters.GlowFilter;
	
	import ivis.model.Edge;
	import ivis.model.Graph;
	import ivis.model.Node;
	import ivis.util.GeneralUtils;
	import ivis.util.Groups;
	
	import mx.core.UIComponent;

	/**
	 * This class is designed to represent the view of the graph.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class GraphView extends UIComponent
	{
		protected var _graph:Graph;
		
		protected var _vis:GraphVisualization;
		
		//--------------------------- ACCESSORS --------------------------------

		// TODO it may be better to make graph inaccessible outside GraphView
		/**
		 * Graph model.
		 */
		public function get graph():Graph
		{
			return _graph;
		}
		
		/**
		 * Visualization instance for this graph.
		 */
		public function get vis():Visualization
		{
			return _vis;
		}
		
		//------------------------- CONSTRUCTOR --------------------------------
		
		public function GraphView(graph:Graph)
		{
			this._graph = graph;
			this._vis = new GraphVisualization(this.graph.graphData);
			this.addChild(this._vis);
			
			// TODO props.labelText as default?
			this._vis.nodeLabeler = new NodeLabeler("props.labelText");
			this._vis.compoundLabeler = new CompoundNodeLabeler("props.labelText");
			this._vis.edgeLabeler = new EdgeLabeler("props.labelText");
		}
		
		//---------------------- PUBLIC FUNCTIONS ------------------------------
		
		/**
		 * Updates the view.
		 */
		public function update():void
		{
			this._vis.update();
		}
		
		/**
		 * Removes the given label from the view.
		 * 
		 * @param label	label to be removed
		 */
		public function removeLabel(label:DisplayObject):void
		{
			this._vis.labels.removeChild(label);
		}
		
		/**
		 * Updates labels for the given data group.
		 * 
		 * @param group	name of the data group
		 */
		public function updateLabels(group:String):void
		{
			this._vis.updateLabels(group);
		}
		
		/**
		 * Updates bounds of all compound nodes.
		 */
		public function updateAllCompoundBounds():void
		{
			this._vis.updateAllCompoundBounds();
		}
		
		/**
		 * Updates the bounds of the given compound node.
		 * 
		 * @param compound	compound node to be updated
		 */
		public function updateCompoundBounds(compound:Node):void
		{
			this._vis.updateCompoundBounds(compound);
		}
		
		/**
		 * If the given graph element (node or edge) is not selected, selects it
		 * by setting corresponding flags and adding the element to the
		 * corresponding data group. If the graph element is already selected,
		 * unselects it by resetting flags and removing element from the
		 * corresponding data group.
		 * 
		 * @param eventTarget	target sprite to be selected/unselected
		 * @return				true if successful, false otherwise
		 */
		public function toggleSelect(eventTarget:DataSprite):Boolean
		{
			var result:Boolean = false;
			
			// deselect the sprite
			if (eventTarget.props.$selected)
			{
				result = this.deselectElement(eventTarget);
			}
			// select the sprite
			else
			{
				result = this.selectElement(eventTarget);
			}
			
			return result;
		}
		
		/**
		 * If the given graph element (node or edge) is not selected, selects it
		 * by setting corresponding flags and adding the element to the
		 * corresponding data group.
		 * 
		 * @param eventTarget	target object to be selected
		 * @return				true if successful, false otherwise
		 */
		public function selectElement(eventTarget:Object):Boolean
		{
			var result:Boolean = false;
			
			if (eventTarget is Node)
			{
				this.selectNode(eventTarget as Node);
				result = true;
			}
			else if (eventTarget is Edge)
			{
				this.selectEdge(eventTarget as Edge);
				result = true;
			}
			
			return result;
		}
		
		/**
		 * If the given graph element (node or edge) is selected, deselects it
		 * by resetting corresponding flags and removing the element from the
		 * corresponding data group.
		 * 
		 * @param eventTarget	target sprite to be selected
		 * @return				true if successful, false otherwise
		 */
		public function deselectElement(eventTarget:DataSprite):Boolean
		{
			var result:Boolean = false;
			
			if (eventTarget is Node)
			{
				this.deselectNode(eventTarget as Node);
				result = true;
			}
			else if (eventTarget is Edge)
			{
				this.deselectEdge(eventTarget as Edge);
				result = true;
			}
			
			return result;
		}
		
		/**
		 * Resets all the selected graph elements (nodes and edges) by setting
		 * corresponding flag to false, and clearing corresponding data groups.
		 */ 
		public function resetSelected():void
		{
			for each (var node:NodeSprite in this.graph.selectedNodes)
			{
				node.props.$selected = false;
				
				// remove glow filter
				GeneralUtils.removeFilter(node, node.props.$glowFilter);
				
			}
			
			for each (var edge:EdgeSprite in this.graph.selectedEdges)
			{
				edge.props.$selected = false;
				
				// remove glow filter
				GeneralUtils.removeFilter(edge, edge.props.$glowFilter);
			}
		}
		
		/**
		 * Highlights the given target Node or Edge by adding a GlowFilter to
		 * the sprite. If the eventTarget is not an Node or Edge instance,
		 * it is not highlighted.
		 * 
		 * @param eventTarget	target object to be highlighted
		 * @return				highlighted DataSprite if successful, null o.w.
		 */
		public function highlight(eventTarget:Object):DataSprite
		{
			var ds:DataSprite = null;
			
			var filter:GlowFilter;
			var alpha:Number;
			var blur:Number;
			var strength:Number;
			var color:uint;
			
			// TODO other selection properties? 
			/*
				selectionLineColor: "#8888ff",
				selectionLineOpacity: 0.8,
				selectionLineWidth: 1,
				selectionFillColor: "#8888ff",
				selectionFillOpacity: 0.1
			*/
			
			if (eventTarget is DataSprite)
			{
				ds = eventTarget as DataSprite;
				
				alpha = ds.props.selectionGlowAlpha;
				blur = ds.props.selectionGlowBlur;
				strength = ds.props.selectionGlowStrength; 
				
				if (alpha > 0 &&
					blur > 0 &&
					strength > 0)
				{
					color = ds.props.selectionGlowColor;
					filter = new GlowFilter(color, alpha, blur, blur, strength);
					
					ds.props.$glowFilter = filter;
					GeneralUtils.addFilter(ds, filter);
				}
			}
			
			return ds;
		}
		
		//---------------------- PROTECTED FUNCTIONS ---------------------------
		
		/**
		 * Selects the specified node by highlighting it.
		 * 
		 * @param node	node to be selected
		 */
		protected function selectNode(node:Node):void
		{
			if (!node.props.$selected)
			{
				// mark node as selected
				node.props.$selected = true;
				
				// add node to the corresponding data group
				this.graph.addToGroup(Groups.SELECTED_NODES, node);
				
				// highlight selected node
				this.highlight(node);
			}
		}
		
		/**
		 * Selects the specified edge by highlighting the edge itself and
		 * child components (bend points and segments) if necessary.
		 * 
		 * @param edge	edge to be selected
		 */
		protected function selectEdge(edge:Edge):void
		{
			var parent:Edge = edge;
			
			if (!edge.props.$selected)
			{
				// edge is a segment, so select other segments of the
				// parent edge
				if (edge.isSegment)
				{
					for each (var segment:Edge in edge.parentE.getSegments())
					{
						segment.props.$selected = true;
						
						this.graph.addToGroup(Groups.SELECTED_EDGES, segment);
						
						this.highlight(segment);
					}
					
					parent = edge.parentE;
				}
				
				// select the parent edge
				parent.props.$selected = true;
				this.graph.addToGroup(Groups.SELECTED_EDGES, parent);			
				
				// highligh edge if it is visible 
				if (parent == edge)
				{
					this.highlight(parent);
				}
			}
		}
		
		/**
		 * Removes the selection of the specified node.
		 * 
		 * @param node	node to be deselected
		 */ 
		protected function deselectNode(node:Node):void
		{
			if (node.props.$selected)
			{
				// mark node as unselected
				node.props.$selected = false;
				
				// remove node from the corresponding data group
				this.graph.removeFromGroup(Groups.SELECTED_NODES, node);
				
				// remove highlight of the node (remove glow filter)
				GeneralUtils.removeFilter(node, node.props.$glowFilter);
			}
		}
		
		/**
		 * Removes the selection of the specified edge.
		 * 
		 * @param edge	edge to be deselected
		 */
		protected function deselectEdge(edge:Edge):void
		{
			var parent:Edge = edge;
			var idx:int;
			
			if (edge.props.$selected)
			{
				// edge is a segment, so deselect other segments of the
				// parent edge
				if (edge.isSegment)
				{
					for each (var segment:Edge in edge.parentE.getSegments())
					{
						// mark segment as unselected
						segment.props.$selected = false;
						
						// remove segment from corresponding data group
						this.graph.removeFromGroup(Groups.SELECTED_EDGES,
							segment);
						
						// remove highlight of the segment (remove glow filter)
						GeneralUtils.removeFilter(segment,
							segment.props.$glowFilter);
						
					}
					
					parent = edge.parentE;
				}
				
				// unselect the parent edge
				parent.props.$selected = false;
				
				this.graph.removeFromGroup(Groups.SELECTED_EDGES, parent);
				
				// remove highlight of the parent (remove glow filter)
				GeneralUtils.removeFilter(parent, parent.props.$glowFilter);
			}
		}
	}
}