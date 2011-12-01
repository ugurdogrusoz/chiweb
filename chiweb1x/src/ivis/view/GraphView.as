package ivis.view
{
	import flare.display.TextSprite;
	import flare.util.Shapes;
	import flare.vis.Visualization;
	import flare.vis.data.DataList;
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.data.render.ArrowType;
	
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import ivis.controls.ClickControl;
	import ivis.controls.MultiDragControl;
	import ivis.controls.SelectControl;
	import ivis.model.Edge;
	import ivis.model.Graph;
	import ivis.model.Node;
	import ivis.util.ArrowUIs;
	import ivis.util.CompoundUIs;
	import ivis.util.EdgeUIs;
	import ivis.util.GeneralUtils;
	import ivis.util.Groups;
	import ivis.util.NodeUIs;
	import ivis.util.Nodes;
	
	import mx.core.UIComponent;

	/**
	 * This class is designed to represent the view of the graph.
	 */
	public class GraphView extends UIComponent
	{
		protected var _vis:GraphVisualization;
		protected var _graph:Graph;
		
		// source node used for the edge creating process
		protected var _sourceNode:Node;
		
		//--------------------------- ACCESSORS --------------------------------
		
		/**
		 * Visualization instance for this graph.
		 */
		public function get vis():GraphVisualization
		{
			return _vis;
		}

		/**
		 * Graph model.
		 */
		public function get graph():Graph
		{
			return _graph;
		}
		
		public function set graph(graph:Graph):void
		{
			_graph = graph;
		}
		
		//------------------------- CONSTRUCTOR --------------------------------
		
		public function GraphView()
		{
			this.graph = new Graph();
			
			_sourceNode = null;
			
			_vis = new GraphVisualization(this.graph.graphData);

			this.addChild(this.vis);
		}
		
		//---------------------- PUBLIC FUNCTIONS ------------------------------
		
		/**
		 * Creates a new Node instance and adds it to the location specified by
		 * x and y coordinates. If the event target is another node, the new 
		 * node will be added into the target node as a child.
		 * 
		 * @param x				x coordinate of the event
		 * @param y				y coordinate of the event
		 * @param eventTarget	target object of the event
		 * @param data			(optional) data to be associated with the node
		 * @return				newly created node as a DataSprite
		 */
		public function addNode(x:Number, y:Number,
			eventTarget:Object = null,
			data:Object = null):DataSprite
		{
			// add node to the graph
			var node:Node = this.graph.addNode(data);
			var compound:Node;
			var group:DataList = this.graph.graphData.group(
				Groups.COMPOUND_NODES);
			
			// update node position
			node.x = x;
			node.y = y;
			
			// TODO initialize visual properties (size, shape, etc) of node (and
			// render the node before updating compound bounds?)
			// TODO test values for debugging purposes, these values should be
			// set by another class (with an init function)
			node.renderer = NodeRenderer.instance;
			node.shape = NodeUIs.ROUND_RECTANGLE;
			//node.shape = "gradientRect";
			node.size = 10;
			node.w = 20;
			node.h = 10;
			node.alpha = 0.9;
			node.fillColor = 0xff8a1b0b;
			node.lineColor = 0xff333333;
			node.lineWidth = 1;
			node.props.labelText = node.data.id;
			node.props.labelOffsetX = 0;
			node.props.labelOffsetY = 0;
			node.props.labelHorizontalAnchor = TextSprite.CENTER;
			node.props.labelVerticalAnchor = TextSprite.MIDDLE;
			
			// if event target is a compound node, add node to the compound as
			// a child and update compound bounds.
			if (eventTarget is Node && !(eventTarget as Node).isBendNode)
			{
				compound = eventTarget as Node;
				
				if (!compound.isInitialized())
				{
					group.add(compound);
					// TODO also initialize visual properties of compound
					// (shape, size, color, padding values etc)
					// TODO test values for debugging purposes, default values
					// should be set by another class (with an init function)
					compound.shape = CompoundUIs.RECTANGLE;
					//compound.shape = CompoundUIs.ROUND_RECTANGLE;
					compound.renderer = CompoundNodeRenderer.instance;
					compound.paddingLeft = 10;
					compound.paddingRight = 10;
					compound.paddingTop = 10;
					compound.paddingBottom = 10;
					compound.fillColor = 0xff9ed1dc;
					compound.props.labelText = compound.data.id;
					compound.props.labelVerticalAnchor = TextSprite.TOP;
				}
				
				// add the node as a child
				compound.addNode(node);
				
				// update bounds of the target compound node up to the root
				
				while (compound != null)
				{
					// update the bounds of the compound node
					this.vis.updateCompoundBounds(compound);
					
					// render the compound node with new bounds
					compound.render();
					
					// advance to the next parent node
					compound = compound.parentN;
				}
			}
			
			// update the visualization
			this.vis.update();
			
			return node;
		}
		
		/**
		 * Creates a new Edge instance and adds it to the graph data. The data
		 * to be associated with the edge should be provided with valid source
		 * and target values.
		 * 
		 * @param data	data to be associated with the edge
		 * @return		newly created edge as a DataSprite
		 */
		public function addEdge(data:Object):DataSprite
		{
			var edge:Edge = this.graph.addEdge(data);
			
			// TODO initialize visual properties of the edge
			// TODO test values for debugging purposes, default values
			// should be set by another class (with an init function)
			edge.shape = EdgeUIs.LINE;			
			edge.lineColor = 0xff000000;
			edge.lineAlpha = 0.8;
			edge.alpha = 0.8;
			edge.lineWidth = 1;
			edge.renderer = EdgeRenderer.instance;
			
			edge.props.sourceArrowType = ArrowUIs.SIMPLE_ARROW;
			edge.props.targetArrowType = ArrowUIs.SIMPLE_ARROW;
			
			edge.props.labelText = edge.data.id;
			edge.props.labelPos = EdgeLabeler.TARGET;
			edge.props.labelDistanceCalculation = EdgeLabeler.PERCENT_DISTANCE;
			edge.props.labelDistanceFromNode = 30;
			edge.props.labelOffsetX = 0;
			edge.props.labelOffsetY = 0;
			edge.props.labelHorizontalAnchor = TextSprite.CENTER;
			edge.props.labelVerticalAnchor = TextSprite.MIDDLE;
			
			// bring the new edge to the front
			GeneralUtils.bringToFront(edge);
			
			return edge;
		}
		
		/**
		 * If the event target is a simple or compound node (but not a bend
		 * node) and if the source node is set, this function adds and edge
		 * between the target node and the source node. If no source is set yet,
		 * then this function sets the source node as the event target. 
		 * 
		 * @param eventTarget	target object of the event
		 * @return				newly added edge if successful, null otherwise
		 */
		public function addEdgeFor(eventTarget:Object):DataSprite
		{
			var node:Node = null;
			var edge:DataSprite = null;
			var data:Object;
			
			if ((eventTarget is Node)
				&& !(eventTarget as Node).isBendNode)
			{
				node = eventTarget as Node;
			}
			
			if (node == null)
			{
				edge = null;
			}
			else if (this._sourceNode == null)
			{
				// event target will be the source of the edge
				this._sourceNode = node;
			}
			else
			{
				// source is set, so event target will be target of the edge
				data = new Object();
				data.sourceId = this._sourceNode.data.id;
				data.targetId = node.data.id;
				
				edge = addEdge(data);
				
				// add the edge to the group of regular edges
				this.graph.graphData.group(Groups.REGULAR_EDGES).add(edge);
				
				// reset source node
				this._sourceNode = null;
			}
			
			// update the visualization
			this.vis.update();
			
			return edge;
		}
		
		/**
		 * Creates a bendpoint as a Node instance and adds it to the given
		 * target edge. If eventTarget is not an edge, no bendpoint is added.
		 * 
		 * @param eventTarget	target object of event
		 * @return				newly created bendpoint as a DataSprite
		 */
		public function addBendPoint(eventTarget:Object):DataSprite
		{
			var edge:Edge;
			
			if (eventTarget is Edge)
			{
				edge = eventTarget as Edge;
			}
			else
			{
				return null;
			}
			
			var source:NodeSprite = edge.source;
			var target:NodeSprite = edge.target;
			
			var edgeData:Object;
			var parent:Edge;
			
			// check if target edge is an actual edge or a segment
			if (edge.isSegment)
			{
				// edge is a segment
				parent = edge.parentE;
			}
			else
			{
				// edge is an actual edge
				parent = edge;
			}
			
			// create bend node to represent bendpoint
			var bendNode:Node = this.addBendNode(edge);
			parent.addBendNode(bendNode);
			
			// create first segment
			edgeData = new Object();
			edgeData.sourceId = source.data.id;
			edgeData.targetId = bendNode.data.id;
			var segment1:DataSprite = this.addEdge(edgeData);
			parent.addSegment(segment1 as Edge);
			
			// create second segment
			edgeData = new Object();
			edgeData.sourceId = bendNode.data.id;
			edgeData.targetId = target.data.id;
			var segment2:DataSprite = this.addEdge(edgeData);
			parent.addSegment(segment2 as Edge);
			
			// target edge is a segment
			if (edge.isSegment)
			{
				// remove the (old) segment from the graph
				this.graph.removeEdge(edge);
			}
			// target edge is an actual edge
			else
			{
				// in order to hide the actual edge, it should be rendered 
				edge.render();
			}
			
			// bring new segments to the front
			bendNode.visitEdges(GeneralUtils.bringToFront);
			
			// bring new bendpoint to the front
			GeneralUtils.bringToFront(bendNode);
			
			// update the visualization
			this.vis.update();
			
			return bendNode;
		}
		
		/**
		 * Removes the specified element (node or edge) from the graph. If the
		 * update flag is set, updates the bounds of all compound nodes, if
		 * the remove operation is succesful.
		 * 
		 * @param eventTarget	target element to be deleted 
		 * @param update		flag that indicates compound bound update,
		 * 						default value is true.
		 * @return				true if successful, false otherwise
		 */
		public function removeElement(eventTarget:Object,
			update:Boolean = true):Boolean
		{
			var result:Boolean = false;
			
			var edge:Edge;
			var node:Node;
			
			if (eventTarget is Node)
			{
				node = eventTarget as Node;
				
				// for a bendpoint (bend node), remove the bend node and two
				// incident edges, and add one new segment between the two
				// neighbor bend nodes.
				if (node.isBendNode)
				{
					result = this.removeBendNode(node);
				}
				// for a node, remove all children & all incident edges
				// (with their bendpoints and segments)
				else
				{
					result = this.removeNode(node);
				}
			}
			// for an edge, remove all segments & bendpoints
			else if (eventTarget is Edge)
			{
				edge = eventTarget as Edge;
				
				result = this.removeEdge(edge);
			}
			
			if (result && update)
			{
				this.vis.updateAllCompoundBounds();
				this.vis.update();
			}
			
			return result;
		}
		
		/**
		 * If the given graph element (node or edge) is not selected, selects it
		 * by setting corresponding flags and adding the element to the
		 * corresponding data group. If the graph element is already selected,
		 * unselects it by resetting flags and removing element from the
		 * corresponding data group.
		 * 
		 * @param eventTarget	target object to be selected/unselected
		 * @return				true if successful, false otherwise
		 */
		public function toggleSelect(eventTarget:Object):Boolean
		{
			var result:Boolean = false;
			
			if (eventTarget is DataSprite)
			{
				// deselect the node
				if ((eventTarget as DataSprite).props.selected)
				{
					result = this.deselectElement(eventTarget);
				}
				// select the node
				else
				{
					result = this.selectElement(eventTarget);
				}
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
			
			if (eventTarget is DataSprite)
			{
				trace("[GraphView.selectElement] " + 
					(eventTarget as DataSprite).data.id + " is selected");
				
				if (eventTarget is Node)
				{
					this.selectNode(eventTarget as Node);
				}
				else if (eventTarget is Edge)
				{
					this.selectEdge(eventTarget as Edge);
				}
				
				result = true;
			}
			
			return result;
		}
		
		/**
		 * If the given graph element (node or edge) is selected, deselects it
		 * by resetting corresponding flags and removing the element from the
		 * corresponding data group.
		 * 
		 * @param eventTarget	target object to be selected
		 * @return				true if successful, false otherwise
		 */
		public function deselectElement(eventTarget:Object):Boolean
		{
			var result:Boolean = false;
			
			if (eventTarget is DataSprite)
			{
				trace("[GraphView.deselectElement] " + 
					(eventTarget as DataSprite).data.id + " is deselected");
				
				if (eventTarget is Node)
				{
					this.deselectNode(eventTarget as Node);
				}
				else if (eventTarget is Edge)
				{
					this.deselectEdge(eventTarget as Edge);
				}
				
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
			trace("all selections are cleared");
			
			for each (var node:NodeSprite in this.graph.selectedNodes)
			{
				node.props.selected = false;
				
				// TODO remove glow filter only..
				node.filters = null;
			}
			
			for each (var edge:EdgeSprite in this.graph.selectedEdges)
			{
				edge.props.selected = false;
				
				// TODO remove glow filter only..
				edge.filters = null;
			}
			
			this.graph.graphData.group(Groups.SELECTED_NODES).clear();
			this.graph.graphData.group(Groups.SELECTED_EDGES).clear();
		}
		
		/**
		 * Removes all of the selected elements from the graph.
		 */
		public function deleteSelected():void
		{
			var deleted:Boolean = false;
			
			for each (var node:NodeSprite in this.graph.selectedNodes)
			{
				// remove node, but not update bounds
				deleted = this.removeElement(node, false);
			}
			
			for each (var edge:EdgeSprite in this.graph.selectedEdges)
			{
				// remove node, but not update bounds
				deleted = this.removeElement(edge, false) || deleted;
			}
			
			// if delete operation is successful, update all compound bounds
			if (deleted)
			{
				this.vis.updateAllCompoundBounds();
				this.vis.update();
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
			
			var filters:Array;
			var filter:GlowFilter;
			var alpha:Number;
			var blur:Number;
			var strength:Number;
			var color:uint;
			
			if (eventTarget is Node)
			{
				var node:Node = eventTarget as Node;
				// TODO all these values should be taken from elsewhere
				// (settings, properties, etc.). These are test values for
				// debug purposes
				filters = new Array();
				filter = null;
				alpha = node.alpha;
				blur = 8;
				strength = 6; 
				
				if (alpha > 0 &&
					blur > 0 &&
					strength > 0)
				{
					color = 0x00ffff33;  // "#ffff33"
					trace("glow filter is added to node " + node.data.id);
					filter = new GlowFilter(color, alpha, blur, blur, strength);
					filters.push(filter);
					node.filters = filters;
				}
				
				ds = node;
			}
			else if (eventTarget is Edge)
			{
				var edge:Edge = eventTarget as Edge;
				// TODO all these values should be taken from elsewhere
				// (settings, properties, etc.). These are test values for
				// debug purposes
				filters = new Array();
				filter = null;
				alpha = edge.alpha;
				blur = 4;
				strength = 10; 
				
				if (alpha > 0 &&
					blur > 0 &&
					strength > 0)
				{
					color = 0x00ffff33;  // "#ffff33"
					trace("glow filter is added to edge " + edge.data.id);
					filter = new GlowFilter(color, alpha, blur, blur, strength);
					filters.push(filter);
					edge.filters = filters;
				}
				
				ds = edge;
			}
			
			return ds;
		}
		
		/**
		 * Resets the missing children list.
		 */
		public function resetMissingChildren():void
		{
			this.graph.resetMissingChildren();
		}
		
		/**
		 * Retrieves an array of missing children.
		 */
		public function getMissingChildren():Array
		{
			return this.graph.missingChildren;
		}
		
		/**
		 * Retrieves an array of currently selected nodes.
		 */
		public function getSelectedNodes():Array
		{
			return this.graph.selectedNodes;
		}
		
		//---------------------- PROTECTED FUNCTIONS ---------------------------
		
		/**
		 * Creates a Node instance and initializes its position according to the
		 * start&end points of the target edge. Also, initializes visual
		 * properties of the bend node.
		 * 
		 * @param edge		the target edge
		 * @return			newly created bendpoint as a Node
		 */
		protected function addBendNode(edge:Edge):Node
		{
			var bendNode:Node = this.graph.addNode();
			var group:DataList = this.graph.graphData.group(
				Groups.BEND_NODES);
			
			// set the position of the bendpoint as the mid-point of
			// the start&end points of the target edge
			
			if (edge.props.startPoint == null ||
				edge.props.endPoint == null)
			{
				// if no start or end point defined for the edge, use source
				// and target node poistions
				bendNode.x = (edge.source.x + edge.target.x) / 2;
				bendNode.y = (edge.source.y + edge.target.y) / 2;
			}
			else
			{
				// use start&end points of the edge to set new
				var startPoint:Point = (edge.props.startPoint as Point);
				var endPoint:Point = (edge.props.endPoint as Point);
					
				bendNode.x = (startPoint.x + endPoint.x) / 2;
				bendNode.y = (startPoint.y + endPoint.y) / 2;
			}
			
			// add node to the data group
			group.add(bendNode);
			
			// TODO initialize visual properties (size, shape, etc) of node
			// TODO test values for debugging purposes, these values should be
			// taken from elsewhere (with an init function)
			bendNode.renderer = NodeRenderer.instance;
			bendNode.shape = Shapes.CIRCLE;
			bendNode.size = 1;
			bendNode.alpha = 1.0;
			bendNode.fillColor = 0xff000000;
			//node.lineColor = 0xff000000;
			//node.lineWidth = 1;
			
			return bendNode;
		}
		
		/**
		 * Removes the bend node (bendpoint) from its parent edge and removes  
		 * the two incident edges of the bend node from the graph. Also,
		 * adds one new segment between the two neighbors of the bend node, if
		 * required.
		 * 
		 * @param node	bend node to be removed
		 * @return		true if successfully removed, false otherwise
		 */
		protected function removeBendNode(node:Node):Boolean
		{
			var result:Boolean = false;
			
			// array of edges to be removed
			var fallenEdges:Array = new Array();
			
			// array of nodes to be removed
			var fallenNodes:Array = new Array();
			
			// add the bendpoint to the list of nodes to be removed
			fallenNodes.push(node);
			
			var edge:Edge;
			var edgeData:Object = new Object();
			
			for each (edge in Nodes.incidentEdges(node))
			{
				// add incident edges to the list of edged to be removed
				fallenEdges.push(edge);
				
				// obtain source and target ids for a new segment
				
				if (edgeData.sourceId == null)
				{
					if (edge.source == node)
					{
						edgeData.sourceId = edge.target.data.id;
					}
					else
					{
						edgeData.sourceId = edge.source.data.id;
					}
				}
				else if (edgeData.targetId == null)
				{
					if (edge.source == node)
					{
						edgeData.targetId = edge.target.data.id;
					}
					else
					{
						edgeData.targetId = edge.source.data.id;
					}
				}
			}
			
			// add a new segment to the parent edge, if necessary
			
			if (node.parentE.getBendNodes().length > 1)
			{
				var ds:DataSprite = this.addEdge(edgeData);
				node.parentE.addSegment(ds as Edge);
			}
			
			// remove required nodes from the graph 
			
			for each (node in fallenNodes)
			{
				// remove node
				result = this.graph.removeNode(node) || result;
				
				// remove its label
				if (node.props.label != null)
				{
					this.vis.labels.removeChild(node.props.label);
					node.props.label = null;
				}
				
			}
			
			// remove required edges from the graph
			
			for each (edge in fallenEdges)
			{
				// remove edge
				result = this.graph.removeEdge(edge) || result;
				
				// remove its label
				if (edge.props.label != null)
				{
					this.vis.labels.removeChild(edge.props.label);
					edge.props.label = null;
				}
			}
			
			// check if parent has any more bendpoints
			
			if (!node.parentE.hasBendPoints())
			{
				// it is required to render the actual edge if all bendpoints
				// are removed from the edge
				node.parentE.render();
			}
			
			return result;
		}
		
		/**
		 * Removes the specified node from the graph. Also, removes the node 
		 * from its parent's child list, removes all (direct and indirect)
		 * children of the node and the edges (together with their bendpoints
		 * and segments) incident with the node and all its children from 
		 * the graph.
		 * 
		 * @param node	node to be removed
		 * @return		true if successfully removed, false otherwise
		 */
		protected function removeNode(node:Node):Boolean
		{
			var result:Boolean = false;
			
			// array of edges to be removed
			var fallenEdges:Array = new Array();
			
			// array of nodes to be removed
			var fallenNodes:Array = new Array();
			
			// collect all children of the node to be deleted
			var children:Array = Nodes.getChildren(node);
			
			// collect incident edges of node to be deleted
			var edges:Array = Nodes.incidentEdges(node);
			
			// collect all incident edges of child nodes
			for each(var child:Node in children)
			{
				edges = edges.concat(Nodes.incidentEdges(child));
			}
			
			var edge:Edge;
			
			// collect all bendpoints and segments on all incident edges
			for each(edge in edges)
			{
				// add bendpoints of the current edge to the list
				fallenNodes = fallenNodes.concat(edge.getBendNodes());
				// add segments of the current edge to the list
				fallenEdges = fallenEdges.concat(edge.getSegments());
			}
			
			// add incident edges to the list
			fallenEdges = fallenEdges.concat(edges);
			// add child nodes to the list
			fallenNodes = fallenNodes.concat(children);
			// add the node itself
			fallenNodes.push(node);
			
			// remove required nodes from the graph 
			for each (node in fallenNodes)
			{
				// remove node
				result = this.graph.removeNode(node) || result;
				
				// remove its label
				if (node.props.label != null)
				{
					this.vis.labels.removeChild(node.props.label);
					node.props.label = null;
				}
			}
			
			// remove required edges from the graph
			for each (edge in fallenEdges)
			{
				// remove edge
				result = this.graph.removeEdge(edge) || result;
				
				// remove its label
				if (edge.props.label != null)
				{
					this.vis.labels.removeChild(edge.props.label);
					edge.props.label = null;
				}
			}
			
			return result;
		}
		
		/**
		 * If the specified edge is an actual edge, removes the edge from 
		 * the graph. Also, removes the edge from its parent's child list, 
		 * removes all segments and bendpoints of the edge from the graph.
		 * If the specified edge is a segment, no remove operation is performed,
		 * since segments cannot be removed separately.
		 * 
		 * @param edge	edge to be removed
		 * @return		true if successfully removed, false otherwise
		 */
		protected function removeEdge(edge:Edge):Boolean
		{
			var result:Boolean = false;
			
			// array of edges to be removed
			var fallenEdges:Array = new Array();
			
			// array of nodes to be removed
			var fallenNodes:Array = new Array();
			
			// a segment cannot be removed by itself, so only process
			// actual edges
			if (!edge.isSegment)
			{
				fallenNodes = fallenNodes.concat(edge.getBendNodes());
				fallenEdges = fallenEdges.concat(edge.getSegments());
				fallenEdges.push(edge);
				
				// remove required nodes from the graph 
				for each (var node:Node in fallenNodes)
				{
					// remove node
					result = this.graph.removeNode(node) || result;
					
					// remove its label
					if (node.props.label != null)
					{
						this.vis.labels.removeChild(node.props.label);
						node.props.label = null;
					}
				}
				
				// remove required edges from the graph
				for each (edge in fallenEdges)
				{
					// remove edge
					result = this.graph.removeEdge(edge) || result;
					
					// remove its label
					if (edge.props.label != null)
					{
						this.vis.labels.removeChild(edge.props.label);
						edge.props.label = null;
					}
				}
			}
			
			return result;
		}
		
		/**
		 * Selects the specified node by highlighting it.
		 * 
		 * @param node	node to be selected
		 */
		protected function selectNode(node:Node):void
		{
			if (!node.props.selected)
			{
				// mark node as selected
				node.props.selected = true;
				
				// add node to the corresponding data group
				this.graph.graphData.group(Groups.SELECTED_NODES).add(node);
				
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
			
			if (!edge.props.selected)
			{
				// edge is a segment, so select other segments of the
				// parent edge
				if (edge.isSegment)
				{
					for each (var segment:Edge in edge.parentE.getSegments())
					{
						segment.props.selected = true;
						
						this.graph.graphData.group(
							Groups.SELECTED_EDGES).add(segment);
						
						this.highlight(segment);
					}
					
					parent = edge.parentE;
				}
				
				// select the parent edge
				parent.props.selected = true;
				this.graph.graphData.group(Groups.SELECTED_EDGES).add(parent);			
				
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
			if (node.props.selected)
			{
				// mark node as unselected
				node.props.selected = false;
				
				// remove node from the corresponding data group
				this.graph.graphData.group(Groups.SELECTED_NODES).remove(node);
				
				// TODO remove highlight of the node (remove glow filter only)
				node.filters = null;
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
			
			if (edge.props.selected)
			{
				// edge is a segment, so deselect other segments of the
				// parent edge
				if (edge.isSegment)
				{
					for each (var segment:Edge in edge.parentE.getSegments())
					{
						segment.props.selected = false;
						
						this.graph.graphData.group(
							Groups.SELECTED_EDGES).remove(segment);
						
						// TODO remove highlight of the segment
						// (remove glow filter only)
						segment.filters = null;
					}
					
					parent = edge;
				}
				
				// unselect the parent edge
				parent.props.selected = false;
				
				this.graph.graphData.group(
					Groups.SELECTED_EDGES).remove(parent);
				
				// TODO remove highlight of the edge (remove glow filter only)
				parent.filters = null;
			}
		}
	}
}