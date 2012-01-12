package layout
{
	import flare.animate.Transitioner;
	import flare.vis.data.Data;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.utils.ByteArray;
	
	import ivis.manager.GraphManager;
	import ivis.model.Edge;
	import ivis.model.Node;
	import ivis.operators.LayoutOperator;
	import ivis.util.Groups;
	
	import mx.managers.CursorManager;
	
	import util.MultipartURLLoader;

	/**
	 * This class is designed to perform remote CoSE & CiSE layouts which are 
	 * deployed on the server http://139.179.21.69/
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class RemoteLayout extends LayoutOperator
	{
		//---------------------------- CONSTANTS -------------------------------
		
		/** Default general options. */	
		public static const PROOF_QUALITY:int = 0;
		public static const DEFAULT_QUALITY:int = 1;
		public static const DRAFT_QUALITY:int = 2;
		public static const DEFAULT_ANIMATION_ON_LAYOUT:Boolean = true;
		public static const DEFAULT_INCREMENTAL:Boolean = false;
		public static const DEFAULT_CREATE_BENDS:Boolean = false;
		public static const DEFAULT_UNIFORM_LEAF_NODE_SIZE:Boolean = false;
		
		/** Default CoSE options. */
		public static const DEFAULT_SPRING_STRENGTH:Number = 50;
		public static const DEFAULT_REPULSION_STRENGTH:Number = 50;
		public static const DEFAULT_GRAVITY_STRENGTH:Number = 50;
		public static const DEFAULT_GRAVITY_RANGE:Number = 50;
		public static const DEFAULT_COMPOUND_GRAVITY_STRENGTH:Number = 50;
		public static const DEFAULT_COMPOUND_GRAVITY_RANGE:Number = 50;
		public static const DEFAULT_EDGE_LENGTH:uint = 50;
		public static const DEFAULT_FR_GRID_VARIANT:Boolean = true;
		public static const DEFAULT_SMART_EDGE_LENGTH_CALC:Boolean = true;
		public static const DEFAULT_MULTI_LEVEL_SCALING:Boolean = false;
		
		/** Default CiSE options. */
		public static const DEFAULT_NODE_SEPARATION:uint = 12;
		public static const DEFAULT_CISE_EDGE_LENGTH:uint = 50;
		public static const DEFAULT_INTER_CLUSTER_EDGE_LENGTH_FACTOR:Number = 50;
		public static const DEFAULT_ALLOW_NODES_INSIDE_CIRCLE:Boolean = false;
		public static const DEFAULT_MAX_RATIO_OF_NODES_INSIDE_CIRCLE:Number = 20;
		
		
		/** Default Layout Style. */
		public static const DEFAULT_LAYOUT_STYLE:String = "CoSE";
		
		/** Default Layout URLs. */
		public static const DEFAULT_COSE_URL:String =
			"http://139.179.21.69/chilay2x/layout.jsp";
		public static const DEFAULT_CISE_URL:String =
			"http://139.179.21.69/chilay2x/layout.jsp";
		
		//---------------------------- VARIABLES -------------------------------
		
		/**
		 * Remote layout style.
		 */
		protected var _layoutStyle:String;
		
		/**
		 * General layout options.
		 */
		protected var _generalOptions:Object;
		
		/**
		 * CoSE layout options.
		 */
		protected var _coseOptions:Object;
		
		/**
		 * CiSE layout options.
		 */
		protected var _ciseOptions:Object;
		
		/**
		 * Loader for remote connection.
		 */
		protected var _loader:MultipartURLLoader;
		
		/**
		 * Flag to indicate whether waiting for layout to complete
		 */
		protected var _waitingToComplete:Boolean;
		
		protected var _coseUrl:String;
		protected var _ciseUrl:String;
		
		//---------------------------- ACCESSORS -------------------------------
		
		/**
		 * Layout options.
		 */
		public function get options():Object
		{
			var opts:Object = {general: _generalOptions,
				cose: _coseOptions,
				cise: _ciseOptions};
			
			return opts;
		}
		
		public function set options(value:Object):void
		{
			_generalOptions = value.general;
			_coseOptions = value.cose;
			_ciseOptions = value.cise;
		}
		
		/**
		 * Layout style.
		 */
		public function set layoutStyle(value:String):void
		{
			_layoutStyle = value;
		}
		
		/**
		 * URL for CoSE layout.
		 */
		public function set coseUrl(value:String):void
		{
			_coseUrl = value;
		}
		
		/**
		 * URL for CiSE layout.
		 */
		public function set ciseUrl(value:String):void
		{
			_ciseUrl = value;
		}
		
		//-------------------------- CONSTRUCTOR -------------------------------
		
		/**
		 * Instantiates a new RemoteLayout instance for the provided graph
		 * manager.
		 * 
		 * @param graphManager	graphManager to associate with the layout
		 * @param options		layout options object
		 */
		public function RemoteLayout(graphManager:GraphManager = null,
			options:Object = null,
			layoutStyle:String = DEFAULT_LAYOUT_STYLE,
			coseUrl:String = DEFAULT_COSE_URL,
			ciseUrl:String = DEFAULT_CISE_URL)
		{
			super(graphManager);
			
			// init loader
			this._loader = new MultipartURLLoader();
			
			// init layout style
			this._layoutStyle = layoutStyle;
			
			// init URLs
			this._coseUrl = coseUrl;
			this._ciseUrl = ciseUrl;
			
			// init options
			if (options == null)
			{
				this._generalOptions = {
					quality: DEFAULT_QUALITY,
					animateOnLayout: DEFAULT_ANIMATION_ON_LAYOUT,
					incremental: DEFAULT_INCREMENTAL,
					createBends: DEFAULT_CREATE_BENDS,
					uniformLeafNodeSize: DEFAULT_UNIFORM_LEAF_NODE_SIZE
				};
				
				this._coseOptions = {
					springStrength: DEFAULT_SPRING_STRENGTH,
					repulsionStrength: DEFAULT_REPULSION_STRENGTH,
					gravityStrength: DEFAULT_GRAVITY_STRENGTH,
					gravityRange: DEFAULT_GRAVITY_RANGE,
					compoundGravityStrength: DEFAULT_COMPOUND_GRAVITY_STRENGTH,
					compoundGravityRange: DEFAULT_COMPOUND_GRAVITY_RANGE,
					idealCoSEEdgeLength: DEFAULT_EDGE_LENGTH,
					frGridVariant: DEFAULT_FR_GRID_VARIANT,
					smartEdgeLengthCalc: DEFAULT_SMART_EDGE_LENGTH_CALC,
					multiLevelScaling: DEFAULT_MULTI_LEVEL_SCALING
				};
				
				this._ciseOptions = {
					nodeSeparation: DEFAULT_NODE_SEPARATION,
					idealCiSEEdgeLength: DEFAULT_CISE_EDGE_LENGTH,
					interClusterEdgeLengthFactor: DEFAULT_INTER_CLUSTER_EDGE_LENGTH_FACTOR,
					allowNodesInsideCircle: DEFAULT_ALLOW_NODES_INSIDE_CIRCLE,
					maxRatioOfNodesInsideCircle: DEFAULT_MAX_RATIO_OF_NODES_INSIDE_CIRCLE
				};	
			}
			else
			{
				// assuming options object has a correct structure
				this._generalOptions = options.general;
				this._coseOptions = options.cose;
				this._ciseOptions = options.cise;
			}
			
			// add listeners for the loader
			this._loader.addEventListener(Event.COMPLETE, onLayoutComplete);
			this._loader.addEventListener(IOErrorEvent.IO_ERROR, onLayoutError);
			
			// init flag
			this._waitingToComplete = false;
		}
		
		//------------------------ PROTECTED FUNCTIONS -------------------------
		
		/**
		 * Initializes the layout by a remote request.
		 */
		protected override function layout():void
		{
			if (!this._waitingToComplete)
			{
				this.requestLayout();
			}
		}
		
		/**
		 * Requests layout from the remote layout (CoSE) server.
		 */
		protected function requestLayout():void
		{
			var bytes:ByteArray = new ByteArray();
			var xml:XML = this.toXML(this.graphManager.graph.graphData);
			
			bytes.writeUTFBytes(xml.toXMLString());
			this._loader.addFile(bytes, "graph");
			
			
			// append options
			var go:Object = this._generalOptions;
			
			this._loader.addVariable("layoutQuality", go.quality);
			this._loader.addVariable("animateOnLayout", go.animateOnLayout);
			this._loader.addVariable("incremental", go.incremental);
			this._loader.addVariable("createBendsAsNeeded", go.createBends);
			this._loader.addVariable("uniformLeafNodeSizes", go.uniformLeafNodeSize);
			
			CursorManager.setBusyCursor();
			//coseLayoutButton.enabled = false;
			
			if (this._layoutStyle == "CoSE")
			{	
				var co:Object = this._coseOptions;
				
				this._loader.addVariable("springStrength", co.springStrength);
				this._loader.addVariable("repulsionStrength", co.repulsionStrength);
				this._loader.addVariable("gravityStrength", co.gravityStrength);
				this._loader.addVariable("gravityRange", co.gravityRange);
				this._loader.addVariable("compoundGravityStrength", co.compoundGravityStrength);
				this._loader.addVariable("compoundGravityRange", co.compoundGravityRange);
				this._loader.addVariable("idealEdgeLength", co.idealCoSEEdgeLength);
				this._loader.addVariable("smartRepulsionRangeCalc", co.frGridVariant);
				this._loader.addVariable("smartEdgeLengthCalc", co.smartEdgeLengthCalc);
				this._loader.addVariable("multiLevelScaling", co.multiLevelScaling);
				this._loader.addVariable("layoutStyle", "cose");
				
				this._waitingToComplete = true;
				this._loader.load(this._coseUrl);
			}
			else if (this._layoutStyle == "CiSE")
			{
				var ci:Object = this._ciseOptions;
				
				this._loader.addVariable("nodeSeparation", ci.nodeSeparation);
				this._loader.addVariable("desiredEdgeLength", ci.idealCiSEEdgeLength);
				this._loader.addVariable("interClusterEdgeLengthFactor", ci.interClusterEdgeLengthFactor);
				this._loader.addVariable("allowNodesInsideCircle", ci.allowNodesInsideCircle);
				this._loader.addVariable("maxRatioOfNodesInsideCircle", ci.maxRatioOfNodesInsideCircle/100);
				
				this._waitingToComplete = true;
				this._loader.load(this._ciseUrl);
			}
		}
		
		/**
		 * Listener function for COMPLETE event. Performs update after remote
		 * layout is completed.
		 */
		protected function onLayoutComplete(event: Event):void
		{
			var response:XML = XML(this._loader.getResponse());
			//g.animateToNewPositions(response);
			
			var nodes:String = "";
			var edges:String = "";
			
			// TODO animateOnLayout?
			
			for each(var xmlNode:XML in response..node)
			{
				// TODO debug (new node info)
				nodes += " " + xmlNode.@id + 
					"(" + xmlNode.bounds.@x + "," + xmlNode.bounds.@y + ")";
				
				var node:Node = this.graphManager.graph.getNode(xmlNode.@id);
				node.x = Number(xmlNode.bounds.@x);
				node.y = Number(xmlNode.bounds.@y);
			}
			
			// reset flag
			this._waitingToComplete = false;
			
			// TODO debug (edge info)
			for each(var xmlEdge:XML in response..edge)
			{
				
				edges += " " + xmlEdge.@id;
				
				//var edge:Edge = this.graphManager.graph.getEdge(xmlEdge.@id);
			}
			
			trace("[RemoteLayout.onLayoutComplete] nodes: " + nodes);
			trace("[RemoteLayout.onLayoutComplete] edges: " + edges);
			
			/*
			coseLayoutButton.enabled = true;
			ciseLayoutButton.enabled = true;
			*/
			
			CursorManager.removeBusyCursor();
			
			
			// since this is a remote layout, it will complete after graph
			// manager updates the view, so view should also be updated here
			this.graphManager.view.update();
			this.graphManager.centerView();
		}
		
		/**
		 * Listener function for IO_ERROR event. Resets waitingToComplete flag.
		 */
		protected function onLayoutError(event: Event): void
		{
			this._waitingToComplete = false;
			CursorManager.removeBusyCursor();
			
			throw new Error("Failed to perform remote " + this._layoutStyle);
			
			trace("error: " + event);
			/*
			coseLayoutButton.enabled = true;
			ciseLayoutButton.enabled = true;
			CursorManager.removeBusyCursor();
			*/
		}
		
		/**
		 * Creates an XML representation for the given graph data. Created XML
		 * comforms to the XML schema defined for chilay2x.
		 * 
		 * @param graphData	graph data to be processed
		 * @return			XML representation of the graph data
		 */
		protected function toXML(graphData:Data):XML
		{
			var xmlStr:String = 
				'<?xml version="1.0" encoding="UTF-8" standalone="yes"?><view>';
			
			for each(var node:Node in graphData.nodes)
			{
				if (!node.isBendNode &&
					node.parentN == null)
				{
					xmlStr += this.nodeToXML(node);
				}
			}
			
			for each(var edge:Edge in graphData.group(Groups.REGULAR_EDGES))
			{
				xmlStr += this.edgeToXML(edge);
			}
			
			xmlStr += "</view>"
			
			return XML(xmlStr);
		}
		
		/**
		 * Creates an XML representation of the given node.
		 * 
		 * @param node	node to be processed
		 * @return		XML representation of the node
		 */
		protected function nodeToXML(node:Node):String
		{
			var xmlStr:String = '<node id="' + node.data.id + '" ' + 
				'clusterID="' + node.data.clusterID + '">' + 
				'<bounds height="' + node.height + 
				'" width="' + node.width + 
				'" x="' + node.x + 
				'" y="' + node.y + 
				'" />';
			
			
			if (node.isInitialized() &&
				node.getNodes().length > 0)
			{
				xmlStr += '<children>';
				
				for each(var child:Node in node.getNodes())
				{
					xmlStr += this.nodeToXML(child);
				}
				
				xmlStr += '</children>';
			}
			
			xmlStr += '</node>'
			
			return XML(xmlStr);
		}
		
		/**
		 * Creates an XML representation of the given edge.
		 * 
		 * @param edge	edge to be processed
		 * @return		XML representation of the edge
		 */
		protected function edgeToXML(edge:Edge):String
		{
			return '<edge id="' + edge.data.id + '">' + 
				'<sourceNode id="' + edge.source.data.id + '"/>' + 
				'<targetNode id="' + edge.target.data.id + '"/>' +
				'</edge>';
		}
	}
}