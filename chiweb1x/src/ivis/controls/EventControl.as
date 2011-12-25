package ivis.controls
{
	import flare.vis.controls.Control;
	
	import ivis.manager.GraphManager;

	/**
	 * Base class for other control classes.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class EventControl extends Control
	{
		private var _graphManager:GraphManager;
		private var _stateManager:StateManager;
		
		//---------------------------- ACCESSORS -------------------------------
		
		/**
		 * State manager to monitor action states.
		 */
		public function get stateManager():StateManager
		{
			return _stateManager;
		}
		
		public function set stateManager(value:StateManager):void
		{
			_stateManager = value;
		}
		
		/**
		 * Graph manager to perform graph related operations. 
		 */
		public function get graphManager():GraphManager
		{
			return _graphManager;
		}
		
		public function set graphManager(value:GraphManager):void
		{
			_graphManager = value;
		}
		
		//-------------------------- CONSTRUCTOR -------------------------------
		
		/**
		 * Initializes an EventControl instance with the given graph and state
		 * managers.
		 * 
		 * @param graphManager	GraphManager instance
		 * @param stateManager	StateManager instance
		 */
		public function EventControl(graphManager:GraphManager = null,
			stateManager:StateManager = null)
		{
			super();
			this._graphManager = graphManager;
			this._stateManager = stateManager;
		}

	}
}