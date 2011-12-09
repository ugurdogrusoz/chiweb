package ivis.event
{
	import flash.events.Event;

	public class DataChangeEvent extends Event
	{
		public static const DS_ADDED_TO_GROUP:String = "dsAddedToGroup";
		public static const DS_REMOVED_FROM_GROUP:String = "dsRemovedFromGroup";
		public static const ADDED_GROUP_STYLE:String = "addedGroupStyle";
		public static const REMOVED_GROUP_STYLE:String = "removedGroupStyle";
		public static const ADDED_STYLE_PROP:String = "addedStyleProperty";
		public static const REMOVED_STYLE_PROP:String = "removedStyleProperty";
		
		private var _info:Object;
		
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
		
		public function DataChangeEvent(type:String,
			information:Object = null,
			bubbles:Boolean = false,
			cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.info = information;
		}
	}
}