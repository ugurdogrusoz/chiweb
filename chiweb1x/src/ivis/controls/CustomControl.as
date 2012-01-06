package ivis.controls
{
	import flare.vis.controls.Control;
	
	import flash.display.InteractiveObject;
	import flash.events.Event;

	/**
	 * Wrapper control class for custom event listeners. This class is designed
	 * to introduce a custom listener function for a single event. In order to
	 * define an advanced control system for multiple events, it is better to
	 * extend EventControl class or Flare's Control class.
	 * 
	 * @author Selcuk Onur Sumer  
	 */
	public class CustomControl extends Control
	{
		protected var _listenerFn:Function;
		protected var _eventName:String;
		
		/**
		 * Creates a new control for the given event name and listener function.
		 * 
		 * @param eventName		name of the event
		 * @param listenerFn	function to handle the event
		 * @param filter		Boolean function to filter target items
		 */
		public function CustomControl(eventName:String,
			listenerFn:Function,
			filter:* = null)
		{
			super();
			
			this.filter = filter;
			this._listenerFn = listenerFn;
			this._eventName = eventName;
		}
		
		/** @inheritDoc */
		public override function attach(obj:InteractiveObject):void
		{
			if (obj == null)
			{
				detach();
				return;
			}
			
			super.attach(obj);
			
			if (obj != null)
			{
				// add the event listener
				obj.addEventListener(this._eventName,
					onEvent);
			}
		}
		
		/** @inheritDoc */
		public override function detach():InteractiveObject
		{
			if (_object != null)
			{
				_object.removeEventListener(this._eventName,
					onEvent);
			}
			
			return super.detach();
		}
		
		/**
		 * Function to be called for the specified event. This function simply
		 * applies the filter for the event target and calls the associated
		 * function if necessary.
		 * 
		 * @param event	 event instance produced by the action
		 */
		protected function onEvent(evt:Event):void
		{	
			// apply filter before calling the listener function
			if (_filter == null || _filter(evt.target))
			{
				// call the listener function with the current event
				this._listenerFn(evt);
			}
		}
	}
}