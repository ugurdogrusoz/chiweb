package ivis.event
{
	public class StyleChangeEvent extends ChiWebEvent
	{
		public static const ADDED_STYLE_PROP:String = "addedStyleProperty";
		public static const REMOVED_STYLE_PROP:String = "removedStyleProperty";
		
		public function StyleChangeEvent(type:String,
			information:Object = null,
			bubbles:Boolean = false,
			cancelable:Boolean = false)
		{
			super(type, information, bubbles, cancelable);
		}
	}
}