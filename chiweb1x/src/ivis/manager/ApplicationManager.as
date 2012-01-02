package ivis.manager
{

	import ivis.model.Graph;
	
	import mx.core.Container;

	/**
	 * Main class to initialize the application.
	 * 
	 * @author Selcuk Onur Sumer
	 */ 
	public class ApplicationManager
	{
		protected var _graphManager:GraphManager;
		protected var _controlCenter:ControlCenter;
		
		//--------------------------- ACCESSORS --------------------------------
		
		/**
		 * Graph Manager.
		 */
		public function get graphManager():GraphManager
		{
			return _graphManager;
		}
		
		/**
		 * Control Center. 
		 */
		public function get controlCenter():ControlCenter
		{
			return _controlCenter;
		}
		
		//------------------------ CONSTRUCTOR ---------------------------------
		
		/**
		 * Initializes the application by instantiating graph manager and
		 * control center.
		 * 
		 * @param graph	graph for the application
		 */
		public function ApplicationManager(graph:Graph = null)
		{	
			// instantiate manager
			this._graphManager = new GraphManager(graph);
			
			// initialize control center for the visualization
			this._controlCenter = new ControlCenter(this._graphManager);
		}
		
		//---------------------- PUBLIC FUNCTIONS ------------------------------
		
		/**
		 * Sets the Container of the graph view.
		 * 
		 * @param container	container of the graph view
		 * @return			true if view is added to the given container
		 */ 
		public function setGraphContainer(container:Container):Boolean
		{
			var added:Boolean = false;
			
			if (this.graphManager.view.parent != container)
			{
				container.addChild(this.graphManager.view);
				added = true;
			}
			
			return added;
		}
		
		/**
		 * Sets the root container of the application.
		 * 
		 * @param container root container of the application
		 */
		public function setRootContainer(container:Container):void
		{
			this.graphManager.rootContainer = container;
		}
	}
}