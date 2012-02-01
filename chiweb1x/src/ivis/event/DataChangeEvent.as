package ivis.event
{
	import flash.events.Event;

	/**
	 * This class is designed to manage data change events for both 
	 * the Graph data and the VisualSettings.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class DataChangeEvent extends ChiWebEvent
	{
		/** Event types related to data groups. */
		public static const ADDED_GROUP:String = "addedGroup";
		public static const REMOVED_GROUP:String = "removedGroup";
		public static const CLEARED_GROUP:String = "clearedGroup";
		public static const DS_ADDED_TO_GROUP:String = "dsAddedToGroup";
		public static const DS_REMOVED_FROM_GROUP:String = "dsRemovedFromGroup";
		
		/** Event types related to group styles. */
		public static const ADDED_GROUP_STYLE:String = "addedGroupStyle";
		public static const REMOVED_GROUP_STYLE:String = "removedGroupStyle";
		public static const CLEARED_GROUP_STYLES:String = "clearedGroupStyles";
		
		// -------------------------- CONSTRUCTOR ------------------------------
		
		public function DataChangeEvent(type:String,
			information:Object = null,
			bubbles:Boolean = false,
			cancelable:Boolean = false)
		{
			super(type, information, bubbles, cancelable);
		}
	}
}