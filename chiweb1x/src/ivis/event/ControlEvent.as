package ivis.event
{
	public class ControlEvent extends ChiWebEvent
	{
		public static const DRAG_START:String = "dragStart";
		public static const DRAG_END:String = "dragEnd";
		public static const SELECT_START:String = "selectStart";
		public static const SELECT_END:String = "selectEnd";
		public static const PAN_START:String = "panStart";
		public static const PAN_END:String = "panEnd";
		
		public function ControlEvent(type:String,
			information:Object = null,
			bubbles:Boolean = false,
			cancelable:Boolean = false)
		{
			super(type, information, bubbles, cancelable);
		}
	}
}