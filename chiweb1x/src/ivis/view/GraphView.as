package ivis.view
{
	import flare.display.DirtySprite;
	import flare.util.Displays;
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	
	import flash.display.DisplayObject;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	
	import ivis.model.Edge;
	import ivis.model.Graph;
	import ivis.model.Node;
	import ivis.model.util.Edges;
	import ivis.model.util.Nodes;
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
		public function get vis():GraphVisualization
		{
			return _vis;
		}
		
		//------------------------- CONSTRUCTOR --------------------------------
		
		/**
		 * Instantiates a new GraphView for the given graph
		 * 
		 * @param graph	graph model for the view
		 */
		public function GraphView(graph:Graph)
		{
			this._graph = graph;
			
			// init visualization
			this._vis = new GraphVisualization(this.graph.graphData);
			this.addChild(this._vis);
			
			// init labelers
			this._vis.nodeLabeler = new NodeLabeler();
			this._vis.compoundLabeler = new CompoundNodeLabeler();
			this._vis.edgeLabeler = new EdgeLabeler();
		}
		
		//---------------------- PUBLIC FUNCTIONS ------------------------------
		
		/**
		 * Updates the view.
		 */
		public function update(updateBounds:Boolean = true) : void
		{
			//this._vis.update();
			DirtySprite.renderDirty();
			
			if (updateBounds)
			{
				this.updateAllCompoundBounds();
				DirtySprite.renderDirty();
			}
			
			this.updateLabels();
		}
		
		/**
		 * Updates labels for the given data group.
		 * 
		 * @param group	name of the data group
		 */
		public function updateLabels(group:String = Groups.ALL):void
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
		 * Updates visibility of nodes and edges.
		 */
		public function updateVisibility():void
		{
			for each (var node:NodeSprite in this.graph.graphData.nodes)
			{
				node.visible = !Nodes.isFiltered(node as Node);
			}
			
			for each (var edge:EdgeSprite in this.graph.graphData.edges)
			{
				edge.visible = !Edges.isFiltered(edge as Edge);
			}
		}
		
		/**
		 * Updates the hit area of the visualization.
		 */
		public function updateHitArea():void
		{
			var bounds:Rectangle;
			var width:Number;
			var height:Number;
			var x:Number;
			var y:Number;
			
			// adjust width & height of the hit area with respect to width &
			// height of the parent container
			
			if (this.vis.scaleX > 1)
			{
				width = this.parent.width;
			}
			else
			{
				width = this.parent.width / this.vis.scaleX;
			}
			
			if (this.vis.scaleY > 1)
			{
				height = this.parent.height;
			}
			else
			{
				height = this.parent.height / this.vis.scaleY;
			}
			
			// adjust x & y coordiantes of the hit area with respect to the
			// x & y coordiantes of the visualization
			
			x = -width / 2 - this.vis.x / this.vis.scaleX;
			y = -height / 2 - this.vis.y / this.vis.scaleY;
			
			// set bounds for the hit area 
			bounds = new Rectangle(x, y, width, height);
			
			trace ("[GraphView.updateHitArea] bounds: (" + bounds.x + "," +
				  bounds.y + "," + ") ["+ bounds.width + "x" + 
				  bounds.height + "]");
			
			this.vis.updateHitArea(bounds);
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
		public function selectElement(eventTarget:DataSprite):Boolean
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
		
		/**
		 * Filters the given data sprite by setting corresponding flag to true.
		 * 
		 * @param eventTarget	target sprite to be filtered out
		 * @return				true if successful, false otherwise
		 */
		public function filterElement(eventTarget:DataSprite):Boolean
		{
			var result:Boolean = true;
			
			if (eventTarget is Node)
			{
				this.filterNode(eventTarget as Node);
			}
			else if (eventTarget is Edge)
			{
				this.filterEdge(eventTarget as Edge);
			}
			else
			{
				eventTarget.props.$filtered = true;
			}
			
			return result;
		}
		
		/**
		 * Unfilters the given data sprite by setting corresponding flag
		 * to false.
		 * 
		 * @param eventTarget	target sprite to be unfiltered
		 * @return				true if successful, false otherwise
		 */
		public function unfilterElement(eventTarget:DataSprite):Boolean
		{
			var result:Boolean = true;
			
			if (eventTarget is Node)
			{
				this.unfilterNode(eventTarget as Node);
			}
			else if (eventTarget is Edge)
			{
				this.unfilterEdge(eventTarget as Edge);
			}
			else
			{
				eventTarget.props.$filtered = false;
			}
			
			return result;
		}
		
		/**
		 * Resets all the filtered graph elements (nodes and edges) by setting
		 * corresponding flag to false.
		 */ 
		public function resetFilters():void
		{
			for each (var node:NodeSprite in this.graph.graphData.nodes)
			{
				node.props.$filtered = false;
			}
			
			for each (var edge:EdgeSprite in this.graph.graphData.edges)
			{
				edge.props.$filtered = false;
			}
		}
		
		/**
		 * Performs the current layout on the graph.
		 * 
		 * @return true if layout performed succesfully, false otherwise
		 */
		public function performLayout():Boolean
		{
			var result:Boolean = false;
			
			if (this.vis.layout != null)
			{
				this.vis.layout.operate();
				result = true;
			}
			
			return result;
		}
		
		/**
		 * Pans the visualization component by the given amount.
		 * 
		 * @param amountX	vertical pan amount
		 * @param amountY	horizontla pan amount 
		 */
		public function panBy(amountX:Number, amountY:Number):void
		{
			Displays.panBy(this.vis,
				amountX, amountY);
		}
		
		/**
		 * Zooms the visualization with respect to the given scale value.
		 * 
		 * @param scale scale value for the zoom
		 * @param x		the x-coordinate around which to zoom
		 * @param y		the y-coordinate around which to zoom
		 */
		public function zoomBy(scale:Number,
			x:Number = NaN,
			y:Number = NaN):void
		{
			Displays.zoomBy(this.vis, scale, x, y);
		}
		
		/**
		 * Centers the view to the center of the rectangular bounds of 
		 * all visible sprites.
		 */
		public function centerView():void
		{
			var bounds:Rectangle = this.vis.contentBounds();
			
			trace("[GraphView.centerView] content bounds: (" + bounds.x + "," +
				bounds.y + ") " + bounds.width + "x" + bounds.height);
			
			var centerX:Number = bounds.x + bounds.width / 2;
			var centerY:Number = bounds.y + bounds.height / 2;
			var amountX:Number = -this.vis.x - centerX * this.vis.scaleX; 
			var amountY:Number = -this.vis.y - centerY * this.vis.scaleY;
				
			this.panBy(amountX, amountY);
		}
		
		
		/**
		 * Zooms the graph view to fit all visible sprites into 
		 * the visible area.
		 */
		public function zoomToFit():void
		{
			// bounds of visible content
			var bounds:Rectangle = this.vis.contentBounds();

			// center coordinates of content bounds
			var centerX:Number = bounds.x + bounds.width / 2;
			var centerY:Number = bounds.y + bounds.height / 2;
			
			// distance of content center to visibile area center??
			var dx:Number = Math.abs(-this.vis.x - centerX); 
			var dy:Number = Math.abs(-this.vis.y - centerY);
			
			// TODO if graph is not centered, scales should be adjusted
			var scaleX:Number = this.parent.width / bounds.width;
			var scaleY:Number = this.parent.height / bounds.height;
			
			// TODO below code does not work properly yet
			//var scaleX:Number = this.parent.width / (bounds.width + 2 * dx) ;
			//var scaleY:Number = this.parent.height / (bounds.height + 2 * dy);
			
			this.zoomBy(Math.min(scaleX, scaleY) / this.vis.scaleX);
		}
		
		/**
		 * Zooms the view to its actual scale.
		 */
		public function zoomToActual():void
		{
			//this.vis.scaleX = 1.0;
			//this.vis.scaleY = 1.0;
			
			// TODO is it safe? isn't there a chance for precision loss?
			// both this.vis.scaleX and this.vis.scaleY should be 1.0 when the
			// zoom level is actual.
			this.zoomBy(1.0 / this.vis.scaleX);
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
		
		/**
		 * Filters the specified node.
		 * 
		 * @param node	node to be filtered
		 */
		protected function filterNode(node:Node):void
		{
			if (node.isBendNode)
			{
				this.filterEdge(node.parentE);
			}
			
			node.props.$filtered = true;
		}
		
		/**
		 * Filters the specified edge.
		 * 
		 * @param edge	edge to be filtered
		 */
		protected function filterEdge(edge:Edge):void
		{
			if (edge.isSegment)
			{
				this.filterEdge(edge.parentE);
			}
			
			edge.props.$filtered = true;
		}
		
		/**
		 * Unfilters the specified node.
		 * 
		 * @param node	node to be unfiltered
		 */
		protected function unfilterNode(node:Node):void
		{
			if (node.isBendNode)
			{
				this.unfilterEdge(node.parentE);
			}
			
			node.props.$filtered = false;
		}
		
		/**
		 * Unfilters the specified edge.
		 * 
		 * @param edge	edge to be unfiltered
		 */
		protected function unfilterEdge(edge:Edge):void
		{
			if (edge.isSegment)
			{
				this.unfilterEdge(edge.parentE);
			}
			
			edge.props.$filtered = false;
		}
		
		//------------------------- DEBUG FUNCTIONS ----------------------------
		
		/**
		 * Prints geometric information of the view components.
		 */
		public function printView():void
		{
			var info:String = new String();
			var bounds:Rectangle = this.vis.contentBounds();
			
			info += "====VIEW PROPERTIES====\n";
			info += "GraphView: ("+ this.x + "," + this.y + ") " +
				"[" + this.width + "x" + this.height + "]\n";
			info += "Parent: (" + this.parent.x + "," + this.parent.y + ") " +
				"[" + this.parent.width + "x" + this.parent.height + "]\n";
			info += "GraphVis: (" + this.vis.x + "," + this.vis.y + ") " +
				"[" + this.vis.width + "x" + this.vis.height + "]\n";
			info += "GraphVis Scale: (" + this.vis.scaleX + "," +
				this.vis.scaleY + ")\n";
			
			if (this.vis.hitArea != null)
			{
				info += "GrapVis HitArea: (" + this.vis.hitArea.x + "," + 
					this.vis.hitArea.y + ") " +
					"[" + this.vis.hitArea.width + "x" + 
					this.vis.hitArea.height + "]\n";
			}
			
			info += "VisibleBounds: (" + bounds.x + "," + bounds.y + ") " +
				"[" + bounds.width + "x" + bounds.height + "]\n";
			
			trace(info);
		}
	}
}