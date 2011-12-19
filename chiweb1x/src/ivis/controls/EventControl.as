package ivis.controls
{
	import flare.vis.controls.Control;
	
	import ivis.view.GraphManager;

	/**
	 * Base class for other control classes.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class EventControl extends Control
	{
		private var _manager:GraphManager;
		private var _state:ActionState;
		
		public function get state():ActionState
		{
			return _state;
		}
		
		public function set state(value:ActionState):void
		{
			_state = value;
		}
		
		public function get manager():GraphManager
		{
			return _manager;
		}
		
		public function set manager(value:GraphManager):void
		{
			_manager = value;
		}
		
		public function EventControl(manager:GraphManager = null)
		{
			super();
			_manager = manager;
		}

	}
}