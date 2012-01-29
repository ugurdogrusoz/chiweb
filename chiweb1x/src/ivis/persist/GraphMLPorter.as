package ivis.persist
{
	import flare.vis.data.DataList;
	import flare.vis.data.DataSprite;
	
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	import ivis.manager.GlobalConfig;
	import ivis.manager.GraphStyleManager;
	import ivis.model.Edge;
	import ivis.model.Graph;
	import ivis.model.IStyleAttachable;
	import ivis.model.Node;
	import ivis.model.Style;
	import ivis.model.util.Nodes;
	import ivis.model.util.Styles;
	import ivis.util.Groups;

	/**
	 * Importer/Exporter for an extended GraphML file format.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class GraphMLPorter implements IGraphPorter
	{
		public static const HEADER:String = 
			"<graphml xmlns=\"http://graphml.graphdrawing.org/xmlns\" "  +
			"xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" " +
			"xsi:schemaLocation=\"http://graphml.graphdrawing.org/xmlns " +
			"http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd\"/>";
		
		public function importGraph(inputData:Object,
			styleManager:GraphStyleManager = null,
			config:GlobalConfig = null):Graph
		{
			var graph:Graph = null;
			
			if (inputData is String)
			{
				graph = new Graph();
				
				// TODO process data
			}
			
			return graph;
		}
		
		public function exportGraph(graph:Graph,
			styleManager:GraphStyleManager = null,
			config:GlobalConfig = null):Object
		{
			// init GraphML
			var graphml:XML = new XML(HEADER);
			var lookup:Object = new Object();
			var graphXml:XML = new XML(<graph/>);
			
			// TODO directed or undirected?
			//graphXml.@["edgeDefault"] = ?;
			
			this.exportKeys(graphml, graph);
			this.exportNodes(graphXml, graph, lookup);
			this.exportEdges(graphXml, graph, lookup);
			this.exportStyles(graphXml, styleManager);
			
			graphml.appendChild(graphXml);
			
			trace(graphml);
			
			return graphml.toXMLString();
		}
		
		/**
		 * Appends information of all nodes in the graph to the given xml
		 * instance. Also populates the given lookup object to create a map for
		 * <node, subgraph> pairs.
		 * 
		 * @param graphXml	xml instance representing a graph
		 * @param graph		graph containing node and edges
		 * @param lookup	object to map <node, subgraph> pairs
		 */
		protected function exportNodes(graphXml:XML,
			graph:Graph,
			lookup:Object):void
		{
			var node:Node;
			var nodeXml:XML;
			
			for each (node in graph.graphData.nodes)
			{
				// process only parentless nodes, a node within a compound node 
				// will be processed recursively
				if (node.parentN == null &&
					!node.isBendNode)
				{
					nodeXml = this.toNodeXml(node, graph, lookup);
					graphXml.appendChild(nodeXml);
				}
			}
		}
		
		/**
		 * Appends information of all edges in the graph to the given xml
		 * instance.
		 * 
		 * @param graphXml	xml instance representing a graph
		 * @param graph		graph containing node and edges
		 * @param lookup	map of <node, subgraph> pairs
		 */
		protected function exportEdges(graphXml:XML,
			graph:Graph,
			lookup:Object):void
		{
			var edge:Edge;
			var edgeXml:XML;
			var node:Node;
			var subGraph:XML = null;
			
			// process only parentless nodes, a node within another node 
			// will be processed recursively
			for each (edge in graph.graphData.group(Groups.REGULAR_EDGES))
			{
				edgeXml = this.toEdgeXml(edge, graph, lookup);
				
				// find lowest common ancestor for the source and target of
				// the edge
				node = Nodes.calcLowestCommonAncestor(
					graph.getNode(edge.data.sourceId),
					graph.getNode(edge.data.targetId));
				
				// add edge to the corresponding sub-graph
				
				if (node != null &&
					lookup != null)
				{
					subGraph = lookup[node.data.id];
				}
				
				if (subGraph == null)
				{
					subGraph = graphXml;
				}
				
				subGraph.appendChild(edgeXml);
			}
		}
		
		/**
		 * Appends information of data keys of the graph to the given xml
		 * instance.
		 * 
		 * @param graphml	xml instance representing the GraphML
		 * @param graph		graph containing node and edges
		 */
		protected function exportKeys(graphml:XML,
			graph:Graph):void
		{
			// add default keys for nodes
			graphml.appendChild(this.toKeyXml("x", "node", "x", "double"));
			graphml.appendChild(this.toKeyXml("y", "node", "y", "double"));
			
			var keys:Object = new Object();
			
			// collect style & data keys for nodes
			this.collectKeys(keys, graph.graphData.nodes);
			
			// add default keys for edges
			graphml.appendChild(
				this.toKeyXml("bendpoints", "edge", "bendpoints", "string"));
			
			// collect style & data keys for edges
			this.collectKeys(keys, graph.graphData.edges);
			
			// add common keys
			
			graphml.appendChild(this.toKeyXml(
				"groups", "all", "groups", "string"));
			
			// TODO also collect keys for group styles
			
			for (var propName:String in keys)
			{
				graphml.appendChild(this.toKeyXml(
					propName, "all", propName, keys[propName]));
			}
			
			
		}
		
		/**
		 * Appends information of all styles in the given style manager to
		 * the provided xml instance.
		 * 
		 * @param graphXml		xml instance representing a graph
		 * @param styleManager	graph style manager containing group styles
		 */
		protected function exportStyles(graphXml:XML,
			styleManager:GraphStyleManager):void
		{
			var style:Style;
			
			for each (var name:String in styleManager.groupStyleNames)
			{
				style = styleManager.getGroupStyle(name);
				
				graphXml.appendChild(this.toStyleXml(style, name));
			}
		}
		
		/**
		 * Extracts data keys for the given data list and appends the keys
		 * to the provided object.
		 * 
		 * @param keys	object to map <key, type> pairs
		 * @param list	data list containing data sprites 
		 */
		protected function collectKeys(keys:Object,
			list:DataList):void
		{
			var style:Style;
			var propName:String;
			
			// collect property names within specific styles of all elements
			// in the given data list
			for each (var element:IStyleAttachable in list)
			{
				style = element.getStyle(Styles.SPECIFIC_STYLE);
				
				if (style != null)
				{
					for each (propName in style.getPropNames())
					{
						keys[propName] = this.toGraphmlType(
							style.getProperty(propName));
					}
				}
			}
			
			// also collect data field names of all data sprites in the given
			// data list
			for each (var ds:DataSprite in list)
			{
				for (propName in ds.data)
				{
					keys[propName] = this.toGraphmlType(
						ds.data[propName]);
				}
			}
		}
		
		/**
		 * Converts the given node to its XML representation for GraphML. Also
		 * populates the given lookup object with <id, subgraph> pairs for
		 * compound nodes.
		 * 
		 * @param node		node as a data sprite
		 * @param graph		graph containing the given node
		 * @param lookup	object to map <id, subgraph> pairs
		 * @return			XML representation of the node
		 */
		protected function toNodeXml(node:Node,
			graph:Graph,
			lookup:Object = null):XML
		{
			var xml:XML = new XML(<node/>);
			var propName:String;
			
			xml.@["id"] = node.data.id;
			
			xml.appendChild(this.toDataXml("x", node.x));
			xml.appendChild(this.toDataXml("y", node.y));
			
			// add all data values except id
			for (propName in node.data)
			{
				if (propName != "id")
				{
					xml.appendChild(this.toDataXml(propName,
						node.data[propName]));
				}
			}
			
			// add specific style values
			var style:Style = node.getStyle(Styles.SPECIFIC_STYLE);
			
			if (style != null)
			{
				xml.appendChild(this.toStyleXml(style, node.data.id + "s"));
			}
			
			// add group data
			var groups:String = this.groupsToString(node, graph);
			xml.appendChild(this.toDataXml("groups", groups));
			
			// recursively create child nodes for compounds
			if (node.isInitialized())
			{
				var subGraph:XML = new XML(<graph/>);
				// TODO directed info?
				
				// update lookup for the new subgraph
				lookup[node.data.id] = subGraph;
				
				for each (var child:Node in node.getNodes())
				{
					subGraph.appendChild(
						this.toNodeXml(child, graph, lookup));
				}
				
				xml.appendChild(subGraph);
			}
			
			return xml;
		}
		
		/**
		 * Converts the given edge to its XML representation for GraphML.
		 * 
		 * @param node		node as a data sprite
		 * @param graph		graph containing the given edge
		 * @param lookup	map of <id, subgraph> pairs
		 * @return			XML representation of the edge
		 */
		protected function toEdgeXml(edge:Edge,
			graph:Graph,
			lookup:Object = null):XML
		{
			var xml:XML = new XML(<edge/>);
			var propName:String;
			
			xml.@["id"] = edge.data.id;
			xml.@["source"] = edge.data.sourceId;
			xml.@["target"] = edge.data.targetId;
			
			// add all data values except id, source & target
			for (propName in edge.data)
			{
				if (propName == "id" ||
					propName == "sourceId" ||
					propName == "targetId")
				{
					continue;
				}
				
				xml.appendChild(this.toDataXml(propName,
					edge.data[propName]));
			}
			
			// add specific style values
			
			var style:Style = edge.getStyle(Styles.SPECIFIC_STYLE);
			
			if (style != null)
			{
				xml.appendChild(this.toStyleXml(style, edge.data.id + "s"));
			}
			
			// TODO bendpoints
			
			// add group data
			var groups:String = this.groupsToString(edge, graph);
			xml.appendChild(this.toDataXml("groups", groups));
			
			return xml;
		}
		
		/**
		 * Converts the given style to its XML representation for GraphML.
		 * 
		 * @param style	Style instance
		 * @param id	id (name) of the style
		 * @return		XML representation of the style
		 */
		protected function toStyleXml(style:Style,
			id:String):XML
		{
			var xml:XML = new XML(<style/>);
			
			for each (var propName:String in style.getPropNames())
			{
				xml.@["id"] = id;
				xml.appendChild(this.toDataXml(propName,
					style.getProperty(propName)));
			}
			
			return xml;
		}
		
		/**
		 * Creates an XML representation of a data field for the given key name
		 * and data value.
		 * 
		 * @param key	key (name) of the data
		 * @param value	value of the data
		 * @return		XML representation of the data
		 */
		protected function toDataXml(key:String, value:*):XML
		{
			var data:XML = new XML(<data/>);
			
			data.@["key"] = key;
			data.appendChild(value);
			
			return data;
		}
		
		/**
		 * Creates an XML representation of a GraphML key for the given
		 * parameters.
		 * 
		 * @param id			id of the key
		 * @param group			group for which the key is valid
		 * @param type			data type corresponding to the key
		 * @param defaultValue	default value of the data
		 * @return				XML representation of the key							
		 */
		protected function toKeyXml(id:String,
			group:String,
			name:String,
			type:String,
			defaultVal:String = null):XML
		{
			var key:XML = new XML(<key/>);
			
			key.@["id"] = id;
			key.@["for"] = group;
			key.@["attr.name"] = name;
			key.@["attr.type"] = type;
			
			// TODO default value of the key?
			
			return key;
		}
		
		/**
		 * 
		 */
		protected function groupsToString(ds:DataSprite, graph:Graph):String
		{
			var groups:String = new String();
			
			for each (var group:String in graph.groupNames)
			{
				if (graph.graphData.group(group).contains(ds))
				{
					groups += group + ";"
				}
			}
			
			return groups;
		}
		
		/**
		 * Converts the type of the given value to its corresponding GraphML
		 * type.
		 * 
		 * @param value	a data value of arbitrary type
		 * @return		corresponding GraphML type as a string
		 */
		protected function toGraphmlType(value:*):String
		{
			/*
			* <xs:enumeration value="boolean"/>
			* <xs:enumeration value="int"/>
			* <xs:enumeration value="long"/>
			* <xs:enumeration value="float"/>
			* <xs:enumeration value="double"/>
			* <xs:enumeration value="string"/>
			*/
			
			var type:String;
			
			if (value is Boolean)
			{
				type = "boolean";
			}
			else if (value is int)
			{
				type = "int";
			}
			else if (value is Number)
			{
				type = "double";
			}
			else // default type is string
			{
				type = "string";
			}
			
			// return string representation of the type for GraphML
			return type;
		}
	}
}