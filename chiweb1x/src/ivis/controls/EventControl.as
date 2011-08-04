package ivis.controls
{
	import flare.vis.controls.Control;
	
	import ivis.view.GraphView;

	/**
	 * Base class for other control classes.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class EventControl extends Control
	{
		private var _view:GraphView;
		private var _state:ActionState;
		
		public function get state():ActionState
		{
			return _state;
		}
		
		public function set state(value:ActionState):void
		{
			_state = value;
		}
		
		public function get view():GraphView
		{
			return _view;
		}
		
		public function set view(value:GraphView):void
		{
			_view = value;
		}
		
		public function EventControl(view:GraphView = null)
		{
			super();
			_view = view;
		}

	}
}