package ivis.event
{
	import flash.events.Event;

	public class DataChangeEvent extends ChiWebEvent
	{
		
		
		public static const ADDED_GROUP:String = "addedGroup";
		public static const REMOVED_GROUP:String = "removedGroup";
		public static const CLEARED_GROUP:String = "clearedGroup";
		
		public static const DS_ADDED_TO_GROUP:String = "dsAddedToGroup";
		public static const DS_REMOVED_FROM_GROUP:String = "dsRemovedFromGroup";
		
		public static const ADDED_GROUP_STYLE:String = "addedGroupStyle";
		public static const REMOVED_GROUP_STYLE:String = "removedGroupStyle";
		
		public function DataChangeEvent(type:String,
			information:Object = null,
			bubbles:Boolean = false,
			cancelable:Boolean = false)
		{
			super(type, information, bubbles, cancelable);
		}
	}
}