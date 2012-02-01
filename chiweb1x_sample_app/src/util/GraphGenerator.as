package util
{
	import ivis.manager.GraphStyleManager;
	import ivis.model.Edge;
	import ivis.model.Graph;
	import ivis.model.Node;
	import ivis.model.Style;
	import ivis.model.util.Styles;
	import ivis.util.Groups;
	

	/**
	 * This class is designed to create graphs programmaticaly as an alternative
	 * to manual graph creation via application GUI.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class GraphGenerator
	{
		
		public function GraphGenerator()
		{
			throw new Error("GraphGenerator is an abstract class.");
		}
		
		/**
		 * Creates a (fixed) sample graph with one gradient node and one circle
		 * node within a compound node, and an image node at root level.
		 * Also creates two edges, one dashed and one with two bends.
		 * 
		 * @param styles	graph style manager to attach styles to elements
		 * @return 			a fixed sample graph
		 */
		public static function sampleGraph(
			styles:GraphStyleManager = null):Graph
		{
			var node:Node;
			var edge:Edge;
			var compound:Node;
			var parent:Edge;
			var graph:Graph = new Graph();
			
			// node n1 (compound)
			node = newNode(graph, "n1", "n1",
				[Groups.COMPOUND_NODES], styles);
			compound = node;
			
			// node n2 (simple)
			node = newNode(graph, "n2", "n2",
				[Constants.CIRCULAR_NODE], styles);
			compound.addNode(node);
			node.x = 80;
			
			// node n3 (simple)
			node = newNode(graph, "n3", "n3",
				[Constants.GRADIENT_RECT], styles);
			compound.addNode(node);
			node.x = -80;
			
			// edge e1 (regular dashed)
			edge = newEdge(graph, "e1", "n2", "n3", "edge1",
				[Groups.REGULAR_EDGES, Constants.DASHED_EDGE], styles);
			
			// node n4 (gradient)
			node = newNode(graph, "n4", "n4",
				[Constants.IMAGE_NODE], styles);
			node.y = -160;
			
			// edge e2 (regular default)
			edge = newEdge(graph, "e2", "n1", "n4", "edge2",
				[Groups.REGULAR_EDGES], styles);
			parent = edge;
			
			// node n5 (bendpoint)
			node = newNode(graph, "n5", null,
				[Groups.BEND_NODES], styles);
			parent.addBendNode(node);
			node.y = -80;
			
			// node n6 (bendpoint)
			node = newNode(graph, "n6", null,
				[Groups.BEND_NODES], styles);
			parent.addBendNode(node);
			node.y = -100;
			
			// edge e3 (segment default)
			edge = newEdge(graph, "e3", "n1", "n5");
			parent.addSegment(edge);
			
			// edge e4 (segment default)
			edge = newEdge(graph, "e4", "n5", "n6");
			parent.addSegment(edge);
			
			// edge e5 (segment default)
			edge = newEdge(graph, "e5", "n6", "n4");
			parent.addSegment(edge);
			
			return graph;
		}
		
		/**
		 * Adds a new node with provided attributes to the given graph. If
		 * groups and styles are also provided, then attaches corresponding
		 * styles for the given groups to the new node.
		 * 
		 * @param graph		graph in which a new node is added
		 * @param id		id of the new node
		 * @param label		label of the node
		 * @param groups	array of data group names to which the node belongs
		 * @param styles	style manager for the group styles
		 */
		public static function newNode(graph:Graph,
			id:String,
			label:String = null,
			groups:Array = null,
			styles:GraphStyleManager = null):Node
		{
			var nodeData:Object = new Object();
			nodeData.id = id;
			nodeData.label = label;
			
			var node:Node = graph.addNode(nodeData);
			
			var style:Style;
			
			// node is added to NODES group by default, so attach its style only
			if (styles != null)
			{
				style = styles.getGroupStyle(Groups.NODES);
				
				if (style != null)
				{
					node.attachStyle(Groups.NODES, style);
				}
			}
			
			// add the node to the given data groups and
			// attach corresponding styles
			if (groups != null)
			{
				for each (var group:String in groups)
				{
					graph.addToGroup(group, node);
					
					if (styles != null)
					{
						style = styles.getGroupStyle(group);
						
						if (style != null)
						{
							node.attachStyle(group, style);
						}
					}
				}
			}
			
			return node;
		}
		
		/**
		 * Adds a new edge with provided attributes to the given graph. If
		 * groups and styles are also provided, then attaches corresponding
		 * styles for the given groups to the new edge.
		 * 
		 * @param graph		graph in which a new edge is added
		 * @param id		id of the new edge
		 * @param source	id of the edge's source node
		 * @param target	id of the edge's target node
		 * @param label		label of the edge
		 * @param groups	array of data group names to which the edge belongs
		 * @param styles	style manager for the group styles
		 */
		public static function newEdge(graph:Graph,
			id:String,
			source:String,
			target:String,
			label:String = null,
			groups:Array = null,
			styles:GraphStyleManager = null):Edge
		{
			var edgeData:Object = new Object();
			edgeData.id = id;
			edgeData.sourceId = source;
			edgeData.targetId = target;
			edgeData.label = label;
			
			var edge:Edge = graph.addEdge(edgeData);
			
			var style:Style;
			
			// edde is added to EDGES group by default, so attach its style only
			if (styles != null)
			{
				style = styles.getGroupStyle(Groups.EDGES);
				
				if (style != null)
				{
					edge.attachStyle(Groups.EDGES, style);
				}
			}
			
			// add the edge to the given data groups and
			// attach corresponding styles
			if (groups != null)
			{
				for each (var group:String in groups)
				{
					graph.addToGroup(group, edge);
					
					if (styles != null)
					{
						style = styles.getGroupStyle(group);
						
						if (style != null)
						{
							edge.attachStyle(group, style);
						}
					}
				}
			}
			
			return edge;
		}
	}
}