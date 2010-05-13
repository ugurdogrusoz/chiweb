package ivis.layout
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import ivis.ui.GraphComponent;
	
	import mx.controls.Alert;
	
	import ru.inspirit.net.MultipartURLLoader;
	
	/**
	 * 
	 * @author Ebrahim
	 */
	public class CoSELayoutService implements ILayoutService
	{
		/**
		 * 
		 * @default 
		 */
		public static const DEFAULT_URL: String = "http://139.179.21.69/chilay1x/layout.jsp";

		/**
		 * 
		 * @default 
		 */
		private var _options: Object;
		
		/**
		 * 
		 * @default 
		 */
		private var _url: String;
		
		/**
		 * 
		 * @default 
		 */
		private var _loader: MultipartURLLoader;
		
		/**
		 * 
		 * @default 
		 */
		private var _graph: GraphComponent;
		
		private var _callback: Function;
		
		/**
		 * 
		 */
		public function CoSELayoutService(graph: GraphComponent = null, url: String = null)
		{
			this._options = new Object;
			this._url = url != null ? url : DEFAULT_URL;
			this._loader = new MultipartURLLoader;
			this._loader.addEventListener("complete", invokeCallback);
			this._loader.addEventListener("ioError", onLayoutError);
			this.graph = graph;
			this._callback = null;
		}

		//
		// getters & setters
		//
		
		/**
		 * 
		 * @return 
		 */
		public function get graph(): GraphComponent
		{
			return this._graph;
		}
		
		/**
		 * 
		 * @param g
		 */
		public function set graph(g: GraphComponent): void
		{
			this._graph = g;
		}
		
		/**
		 * 
		 * @return 
		 */
		public function get options():Object
		{
			return null;
		}
		
		/**
		 * 
		 * @param o
		 */
		public function set options(o:Object):void
		{
		}
		
		/**
		 * 
		 * @return 
		 */
		public function get URL(): String
		{
			return this._url;
		}
		
		/**
		 * 
		 * @param url
		 */
		public function set URL(url: String): void
		{
			this._url = url;
		}

		//
		// public methods
		//
		
		/**
		 * 
		 * @param g
		 * @return 
		 */
		public function layout(callback: Function):void
		{
			this._loader.clearFiles();
			this._loader.clearVariables();
			this._callback = callback;

			var ba: ByteArray = new ByteArray;

			ba.writeUTFBytes(this.graph.asXML().toXMLString());

			this._loader.addFile(ba, "graph");
			this._loader.addVariable("layoutStyle", "cose")
			
			this._loader.load(this._url);
		}
		
		//
		// private methods
		//

		private function invokeCallback(e: Event): void
		{
			if(this._callback == null)
				return;
				
			this._callback.call(this, this._loader.getResponse());
		}
		
		/**
		 * 
		 * @param e
		 */
		private function onLayoutError(e: Event): void
		{
			Alert.show("An IO error occured during layout");
		}

	}
}