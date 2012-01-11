package ivis.event
{
	/**
	 * This class is designed to manage events for Control classes.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class ControlEvent extends ChiWebEvent
	{
		/** StateManager events. */
		public static const RESET_STATES:String = "resetStates";
		public static const CHANGED_STATE:String = "changedState";
		
		/** MultiDragControl events. */
		public static const DRAG_START:String = "dragStart";
		public static const DRAG_END:String = "dragEnd";
		
		/** SelectControl events. */
		public static const SELECT_START:String = "selectStart";
		public static const SELECT_END:String = "selectEnd";
		
		/** PanControl events. */
		public static const PAN_START:String = "panStart";
		public static const PAN_END:String = "panEnd";
		
		/** ClickControl events. */
		public static const ADDED_NODE:String = "addedNode";
		public static const ADDED_EDGE:String = "addedEdge";
		public static const ADDING_EDGE:String = "addingEdge";
		public static const ADDED_BEND:String = "addedBend";
		public static const TOGGLED_SELECTION:String = "toggledSelection";
		
		// -------------------------- CONSTRUCTOR ------------------------------
		
		public function ControlEvent(type:String,
			information:Object = null,
			bubbles:Boolean = false,
			cancelable:Boolean = false)
		{
			super(type, information, bubbles, cancelable);
		}
	}
}