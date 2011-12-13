package ivis.event
{
	import flash.events.Event;

	/**
	 * Base class for other Event classes.
	 */
	public class ChiWebEvent extends Event
	{
		protected var _info:Object;
		
		// -------------------------- ACCESSORS --------------------------------
		
		/**
		 * Object to attach additional information about the event
		 */
		public function get info():Object
		{
			return _info; 
		}
		
		public function set info(information:Object) : void
		{
			_info = information;
		}
		
		// -------------------------- CONSTRUCTOR ------------------------------
		
		/**
		 * Initializes new ChiWebEvent instance.
		 * 
		 * @param type			type of the event
		 * @param information	object holding additional info
		 */
		public function ChiWebEvent(type:String,
			information:Object = null,
			bubbles:Boolean = false,
			cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.info = information;
		}
	}
}