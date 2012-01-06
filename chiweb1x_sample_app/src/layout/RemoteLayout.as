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
	
	import util.MultipartURLLoader;

	/**
	 * This class is designed to perform remote CoSE layout which is deployed
	 * on the server http://139.179.21.69/
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class RemoteLayout extends LayoutOperator
	{
		/** Default general options. */		
		public static const PROOF_QUALITY:int = 0;
		public static const DEFAULT_QUALITY:int = 1;
		public static const DRAFT_QUALITY:int = 2;
		
		/** Default CoSE options. */
		public static const DEFAULT_EDGE_LENGTH:uint = 40;
		public static const DEFAULT_SPRING_STRENGTH:Number = 50;
		public static const DEFAULT_REPULSION_STRENGTH:Number = 50;
		public static const DEFAULT_GRAVITY_STRENGTH:Number = 50;
		public static const DEFAULT_COMPOUND_GRAVITY_STRENGTH:Number = 50;
		
		/** Default CoSE URL. */
		public static const COSE_URL:String =
			"http://139.179.21.69/chilay2x/layout.jsp";
		
		/**
		 * URL to request CoSE layout.
		 */
		protected var _coseUrl:String;		
		
		/**
		 * General layout options.
		 */
		protected var _generalOptions:Object;
		
		/**
		 * CoSE layout options.
		 */
		protected var _coseOptions:Object;
		
		/**
		 * Loader for remote connection.
		 */
		protected var _loader:MultipartURLLoader;
		
		/**
		 * Flag to indicate whether waiting for layout to complete
		 */
		protected var _waitingToComplete:Boolean;
		
		//---------------------------- ACCESSORS -------------------------------
		
		/**
		 * Layout options.
		 */
		public function get options():Object
		{
			var opts:Object = {general: _generalOptions,
				cose: _coseOptions};
			
			return opts;
		}
		
		public function set options(value:Object):void
		{
			_generalOptions = value.general;
			_coseOptions = value.cose;
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
			coseUrl:String = null)
		{
			super(graphManager);
			
			// init loader
			this._loader = new MultipartURLLoader();
			
			if (coseUrl == null)
			{
				this._coseUrl = COSE_URL;
			}
			else
			{
				this._coseUrl = coseUrl;
			}
			
			// init options
			if (options == null)
			{
				this._generalOptions = {quality: DEFAULT_QUALITY,
					animateOnLayout: false,
					incremental: false};
				
				this._coseOptions = {springStrength: DEFAULT_SPRING_STRENGTH,
					repulsionStrength: DEFAULT_REPULSION_STRENGTH,
					gravityStrength: DEFAULT_GRAVITY_STRENGTH,
					compoundGravityStrength: DEFAULT_COMPOUND_GRAVITY_STRENGTH,
					idealEdgeLength: DEFAULT_EDGE_LENGTH};
			}
			else
			{
				// assuming options object has a correct structure
				this._generalOptions = options.general;
				this._coseOptions = options.cose;
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
			//				loader.addVariable("uniformNodeSize", go.uniformNodeSize)
			
			//CursorManager.setBusyCursor();
			//coseLayoutButton.enabled = false;
			
			var co:Object = this._coseOptions;
			this._loader.addVariable("springStrength", co.springStrength);
			this._loader.addVariable("repulsionStrength", co.repulsionStrength);
			this._loader.addVariable("gravityStrength", co.gravityStrength);
			this._loader.addVariable("compoundGravityStrength", co.compoundGravityStrength);
			this._loader.addVariable("idealEdgeLength", co.idealEdgeLength);
			
			this._loader.addVariable("layoutStyle", "cose");
			
			this._waitingToComplete = true;
			this._loader.load(this._coseUrl);
			
			/*
			else
			{
				// CiSE options
				ciseLayoutButton.enabled = false;
				var ci:* = g.CiSEOptions
				loader.addVariable("nodeSeparation", ci.nodeSeparation)
				loader.addVariable("desiredEdgeLength", ci.desiredEdgeLength)
				loader.addVariable("interClusterEdgeLengthFactor", ci.interClusterEdgeLengthFactor)
				loader.addVariable("layoutStyle", "cise")
				loader.load(ciseUrl);
			}
			*/
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
			
			for each(var xmlNode:XML in response..node)
			{
				// TODO debug
				nodes += " " + xmlNode.@id + 
					"(" + xmlNode.bounds.@x + "," + xmlNode.bounds.@y + ")";
				
				var node:Node = this.graphManager.graph.getNode(xmlNode.@id);
				node.x = Number(xmlNode.bounds.@x);
				node.y = Number(xmlNode.bounds.@y);
			}
			
			// reset flag
			this._waitingToComplete = false;
			
			
			for each(var xmlEdge:XML in response..edge)
			{
				// TODO debug
				edges += " " + xmlEdge.@id;
				
				//var edge:Edge = this.graphManager.graph.getEdge(xmlEdge.@id);
			}
			
			trace("[RemoteLayout.onLayoutComplete] nodes: " + nodes);
			trace("[RemoteLayout.onLayoutComplete] nodes: " + edges);
			
			/*
			coseLayoutButton.enabled = true;
			ciseLayoutButton.enabled = true;
			CursorManager.removeBusyCursor();
			*/
			
			// since this is a remote layout, it will complete after graph
			// manager updates the view, so view should also be updated here
			
			this.graphManager.view.update();
		}
		
		/**
		 * Listener function for IO_ERROR event. Resets waitingToComplete flag.
		 */
		protected function onLayoutError(event: Event): void
		{
			this._waitingToComplete = false;
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