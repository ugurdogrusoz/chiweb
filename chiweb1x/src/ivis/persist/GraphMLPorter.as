package ivis.persist
{
	import flare.vis.data.DataList;
	import flare.vis.data.DataSprite;
	import flare.vis.data.NodeSprite;
	
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
	import ivis.model.util.Edges;
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
		//--------------------------- CONSTANTS --------------------------------
		
		protected static const HEADER:String = 
			'<graphml xmlns="http://graphml.graphdrawing.org/xmlns" '  +
			'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' +
			'xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns ' +
			'http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd"/>';
		
		protected static const GROUPS:String = "groups";
		protected static const BENDPOINTS:String = "bendpoints";
		protected static const GRAPHML_TAG:String = "graphml";
		
		//--------------------------- VARIABLES --------------------------------
		
		/**
		 * Map to store key types.
		 */
		protected var _keyTypes:Object;
		
		//------------------------- CONSTRUCTOR --------------------------------
		
		public function GraphMLPorter()
		{
			// init map of key types
			this._keyTypes = new Object();
		}
		
		//---------------------- PUBLIC FUNCTIONS ------------------------------
		
		/** @inheritDoc */
		public function importGraph(inputData:Object,
			styleManager:GraphStyleManager = null,
			config:GlobalConfig = null):Graph
		{
			var graph:Graph = null;
			var xml:XML = null;
			
			var str:String = new String(inputData);
			
			// crop graphml header, otherwise child elements cannot be parsed
			// correctly (seems a flash bug)
			
			var index:int = str.indexOf(GRAPHML_TAG);
			
			if (index > 0)
			{
				str = str.substr(0, index + GRAPHML_TAG.length) + 
					str.substring(str.indexOf(">", index));
				
				xml = new XML(str);
			}
			else
			{
				trace ("[GraphMLPorter.importGraph] Invalid input type!");
			}
			
			// parse the input XML to create a new graph
			if (xml != null)
			{
				graph = this.parseInput(xml, styleManager, config);
			}
			
			return graph;
		}
		
		/** @inheritDoc */
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
			
			this.exportKeys(graphml, graph, styleManager, config);
			this.exportNodes(graphXml, graph, lookup);
			this.exportEdges(graphXml, graph, lookup);
			this.exportStyles(graphXml, styleManager);
			
			// TODO add global configuration as a <style/> or as a <config/> ?
			this.exportConfig(graphml, config);
			
			graphml.appendChild(graphXml);
			
			return graphml.toXMLString();
		}
		
		//---------------------- PROTECTED FUNCTIONS ---------------------------
		
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
			var subGraph:XML;
			
			// process only regular edges
			for each (edge in graph.graphData.group(Groups.REGULAR_EDGES))
			{
				// reset subgraph
				subGraph = null;
				
				// convert edge to XML
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
		 * @param styles	style manager containing group styles
		 * @param config	config containing global parameters
		 */
		protected function exportKeys(graphml:XML,
			graph:Graph,
			styles:GraphStyleManager = null,
			config:GlobalConfig = null):void
		{
			// add default keys for nodes
			graphml.appendChild(this.toKeyXml("x", "node", "x", "double"));
			graphml.appendChild(this.toKeyXml("y", "node", "y", "double"));
			
			var keys:Object = new Object();
			
			// collect style & data keys for nodes
			this.collectKeys(keys, graph.graphData.nodes);
			
			// add default keys for edges
			graphml.appendChild(
				this.toKeyXml(BENDPOINTS, "edge", BENDPOINTS, "string"));
			
			// collect style & data keys for edges
			this.collectKeys(keys, graph.graphData.edges);
			
			// add common keys for all elements
			graphml.appendChild(this.toKeyXml(
				GROUPS, "all", GROUPS, "string"));
			
			// collect keys for group styles
			if (styles != null)
			{
				var style:Style;
				
				for each (var group:String in styles.groupStyleNames)
				{
					style = styles.getGroupStyle(group);
					
					for each (var name:String in style.getPropNames())
					{
						keys[name] = this.toGraphmlType(style.getProperty(name));
					}
				}
			}
			
			// collect keys for global config
			if (config != null)
			{
				for each (var configName:String in config.configNames)
				{
					keys[configName] = this.toGraphmlType(
						config.getConfig(configName));
				}
			}
			
			// append key information to XML
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
			styles:GraphStyleManager):void
		{
			if (styles != null)
			{
				var style:Style;
				
				for each (var name:String in styles.groupStyleNames)
				{
					style = styles.getGroupStyle(name);
					
					graphXml.appendChild(this.toStyleXml(style, name));
				}
			}
		}
		
		/**
		 * Appends information of all global config parameters to the provided
		 * xml instance.
		 * 
		 * @param graphml	xml instance representing the GraphML
		 * @param config	global config containing all config parameters
		 */
		protected function exportConfig(graphml:XML,
			config:GlobalConfig):void
		{
			if (config != null)
			{
				var xml:XML = new XML(<config/>);
				xml.@["id"] = "globalConfig";
				
				for each (var name:String in config.configNames)
				{
					xml.appendChild(this.toDataXml(name,
						config.getConfig(name)));
				}
				
				graphml.appendChild(xml);
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
					// exclude ids from data
					if (propName != "id" ||
						propName != "sourceId" ||
						propName != "targetId")
					{
						keys[propName] = this.toGraphmlType(
							ds.data[propName]);
					}
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
			xml.appendChild(this.toDataXml(GROUPS, groups));
			
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
			
			// add bendpoints
			if (edge.hasBendPoints())
			{
				var bendpoints:String = this.bendsToString(edge);
				xml.appendChild(this.toDataXml(BENDPOINTS, bendpoints));
			}
			
			// add group data
			var groups:String = this.groupsToString(edge, graph);
			xml.appendChild(this.toDataXml(GROUPS, groups));
			
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
		 * Creates a list of groups containing the given data sprite as a
		 * string. Group names are separated by semicolons.
		 * 
		 * @param ds	data sprite whose groups are listed
		 * @param graph	graph containing data groups
		 * @return		string representation of groups
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
			
			// remove last semicolon
			groups = groups.substring(0, groups.length - 1);
			
			return groups;
		}
		
		/**
		 * Creates a list of bendpoints containing the given data sprite as a
		 * string. Bendpoints are separated from each other by semicolons,
		 * and bendpoint's x and y coordinates are separated by commas.
		 * 
		 * @param edge	edge containing bend points
		 * @return		string representation of bend points
		 */
		protected function bendsToString(edge:Edge):String
		{	
			var bends:String = new String();
			var bendCount:int = edge.getBendNodes().length;
			
			// first, find the segment adjacent to the source
			var segment:Edge = Edges.segmentAdjacentToSource(edge);
			
			// traverse segments until a central one
			
			var bendNode:Node;
			
			for (var i:int = 0; i < bendCount; i++)
			{
				// get the next bend node
				bendNode = segment.target as Node;
				
				// get the next segment
				for each (var incident:Edge in
					Nodes.incidentEdges(bendNode))
				{
					if (incident != segment)
					{
						segment = incident;
						break;
					}
				}
				
				// TODO may need to add more information about bends (for example specific style?)
				// TODO we may use <node> tags in a way similar to nodes in compounds  
				bends += bendNode.x + "," + bendNode.y + ";";
			}
			
			// remove last semicolon
			bends = bends.substring(0, bends.length - 1);
			
			return bends;
		}
		
		/**
		 * Parses the given xml input in GraphML format and creates a new Graph
		 * instance. Also updates group style information and global config.
		 * 
		 * @param xml			xml representing the GraphML file
		 * @param styleManager	graph style manager to update style info
		 * @param config		global configuration to update
		 * @return				Graph instance constructed from XML data
		 */
		protected function parseInput(xml:XML,
			styleManager:GraphStyleManager = null,
			config:GlobalConfig = null):Graph
		{
			var graph:Graph = new Graph();
			
			// parse keys to obtain data type info of the keys
			for each (var keyXml:XML in xml.key)
			{
				this.parseKey(keyXml, this._keyTypes);
			}
			
			// parse global config
			for each (var dataXml:XML in xml.config.data)
			{
				var key:String = dataXml.@["key"].toString();
				
				// convert string to corresponding data type by using the key
				var value:* = this.toDataType(key, dataXml[0].toString());
				
				// update global config values
				config.addConfig(key, value);
			}
			
			// TODO it may not be a good idea to reset styles here
			//styleManager.clearGroupStyles(); 
			
			//parse styles
			for each (var styleXml:XML in xml.graph.style)
			{
				// overwrite any existing style
				styleManager.addGroupStyle(styleXml.@["id"].toString(),
					this.parseStyle(styleXml));
			}
			
			// parse nodes
			for each (var nodeXml:XML in xml.graph.node)
			{
				this.parseNode(nodeXml, graph, styleManager);
			}
			
			// parse edges
			for each (var edgeXml:XML in xml.graph..edge)
			{
				this.parseEdge(edgeXml, graph, styleManager);
			}
			
			return graph;
		}
		
		
		/**
		 * Parses the given node xml to create a new Node instance.
		 * 
		 * @param xml		xml representing the node
		 * @param graph		graph to add the new Node instance
		 * @param styles	style manager containing group styles
		 * @return			a Node constructed from the given XML
		 */
		protected function parseNode(xml:XML,
			graph:Graph,
			styles:GraphStyleManager = null):Node
		{
			var nodeData:Object = new Object();
			var groups:Array;
			var x:Number;
			var y:Number;
			
			nodeData.id = xml.@["id"].toString();
			
			for each (var dataXml:XML in xml.data)
			{
				var key:String = dataXml.@["key"].toString();
				
				// convert string to corresponding data type by using the key
				var value:* = this.toDataType(key, dataXml[0].toString());
				
				if (key == GROUPS)
				{
					// group information require additional processing
					groups = dataXml[0].toString().split(";");
				}
				else if (key == "x")
				{
					// x should not go into data
					x = value;
				}
				else if (key == "y")
				{
					// y should not go into data
					y = value;
				}
				else
				{
					// all other <key, value> pairs should go into data
					nodeData[key] = value;
				}
			}
			
			var node:Node = graph.addNode(nodeData);
			node.x = x;
			node.y = y;
			
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
			
			// add the node to the required data groups and
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
			
			// if node has a child graph, then it is a compound node,
			// so recursively parse its child graph
			if (xml.child("graph").length() > 0)
			{
				var child:Node;
				
				for each (var childXml:XML in xml.graph.node)
				{
					child = this.parseNode(childXml,
						graph,
						styles);
					
					node.addNode(child);
				}
			}
			
			return node;
		}
		
		
		/**
		 * Parses the given edge xml to create a new Edge instance.
		 * 
		 * @param xml		xml representing the edge
		 * @param graph		graph to add the new Edge instance
		 * @param styles	style manager containing group styles
		 * @return			an Edge constructed from the given XML
		 */
		protected function parseEdge(xml:XML,
			graph:Graph,
			styles:GraphStyleManager = null):Edge
		{
			var edgeData:Object = new Object();
			var groups:Array = null;
			var bendpoints:Array = null;
			
			edgeData.id = xml.@["id"].toString();
			edgeData.sourceId = xml.@["source"].toString();
			edgeData.targetId = xml.@["target"].toString();
			
			for each (var dataXml:XML in xml.data)
			{
				var key:String = dataXml.@["key"].toString();
				
				// convert string to corresponding data type by using the key
				var value:* = this.toDataType(key, dataXml[0].toString());
				
				if (key == GROUPS)
				{
					groups = dataXml[0].toString().split(";");
				}
				else if (key == BENDPOINTS)
				{
					bendpoints = dataXml[0].toString().split(";");
				}
				else
				{
					edgeData[key] = value;
				}
			}
			
			var edge:Edge = graph.addEdge(edgeData);
			
			// add bendpoints
			if (bendpoints != null)
			{
				this.createBendPoints(edge,
					bendpoints,
					graph,
					styles);
			}
			
			var style:Style;
			
			// edge is added to EDGES group by default, so attach its style only
			if (styles != null)
			{
				style = styles.getGroupStyle(Groups.EDGES);
				
				if (style != null)
				{
					edge.attachStyle(Groups.EDGES, style);
				}
			}
			
			// add the edge to the required data groups and
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
		
		/**
		 * Creates bend points for the given edge by using the information
		 * provided by the bendpoints array.
		 * 
		 * @param edge		edge for which bendpoints and segments are created
		 * @param benpoints array of strings representing bendpoints
		 * @param graph		graph to add new bend nodes and segments
		 * @param styles	graph style manager containing group styles
		 */
		protected function createBendPoints(edge:Edge,
			bendpoints:Array,
			graph:Graph,
			styles:GraphStyleManager = null):void
		{
			var bendNode:Node;
			var segment:Edge;
			var segmentData:Object;
			var source:NodeSprite = edge.source;
			var bendData:Array;
			
			for each (var bendpoint:String in bendpoints)
			{
				// add a bend node to the graph
				bendNode = graph.addNode();
				
				// update bend point coordinates
				bendData = bendpoint.split(",");
				bendNode.x = Number(bendData[0]);
				bendNode.y = Number(bendData[1]);
				
				// update bend node's groups
				graph.addToGroup(Groups.BEND_NODES, bendNode);
				
				// update bend node's styles				
				if (styles != null)
				{
					var style:Style = styles.getGroupStyle(Groups.NODES);
					
					if (style != null)
					{
						bendNode.attachStyle(Groups.NODES, style);
					}
					
					style = styles.getGroupStyle(Groups.BEND_NODES);
					
					if (style != null)
					{
						bendNode.attachStyle(Groups.BEND_NODES, style);
					}
				}
				
				// add bendpoint to the edge
				edge.addBendNode(bendNode);
				
				// add a segment
				segmentData = new Object();
				segmentData.sourceId = source.data.id;
				segmentData.targetId = bendNode.data.id;
				segment = graph.addEdge(segmentData);
				
				// add segment to the edge
				edge.addSegment(segment);
				
				// update source for the next segment
				source = bendNode;
			}
			
			// add last segment
			segmentData = new Object();
			segmentData.sourceId = source.data.id;
			segmentData.targetId = edge.target.data.id;
			segment = graph.addEdge(segmentData);
			edge.addSegment(segment);
		}
		
		/**
		 * Parses the given style xml to create a new Style instance.
		 * 
		 * @param xml	xml representing the style
		 * @return		a Style constructed from the given XML
		 */
		protected function parseStyle(xml:XML):Style
		{
			var styleData:Object = new Object();
			
			for each (var dataXml:XML in xml.data)
			{
				var key:String = dataXml.@["key"].toString();
				
				// convert string to corresponding data type by using the key
				var value:* = this.toDataType(key, dataXml[0].toString());
				
				styleData[key] = value;
			}
			
			return new Style(styleData);
		}
		
		/**
		 * Parses the given key xml and adds its type information the given map.
		 * 
		 * @param xml	xml representing the key
		 * @param types	object to map <key, type> pairs 
		 */
		protected function parseKey(xml:XML, types:Object):void
		{
			// TODO not using all of these values for now...
			var id:String = xml.@["id"].toString();
			var group:String = xml.@["for"].toString();
			var attrName:String = xml.@["attr.name"].toString();
			var type:String = xml.@["attr.type"].toString();
			
			types[attrName] = type;
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
			// <xs:enumeration value="boolean"/>
			// <xs:enumeration value="int"/>
			// <xs:enumeration value="long"/>
			// <xs:enumeration value="float"/>
			// <xs:enumeration value="double"/>
			// <xs:enumeration value="string"/>
			
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
		
		/**
		 * Converts the given string value to its corresponding typed value by
		 * using the given key information.
		 * 
		 * @param key	name of the data key
		 * @param value	string representation of the value
		 * @return		typed value of the given string for the given key
		 */
		protected function toDataType(key:String, value:String):*
		{
			var type:String = this._keyTypes[key];
			
			// default type is string
			var typedValue:* = value;
			
			if (type == "boolean")
			{
				typedValue = Boolean(value);
			}
			else if (type == "int" ||
				type == "long")
			{
				typedValue = int(value);
			}
			else if (type == "float" ||
				type == "double")
			{
				typedValue = Number(value);
			}
			
			// return typed value
			return typedValue;
		}
	}
}