package ivis.event
{
	/**
	 * This class is designed to manage property changes in a VisualStyle
	 * instance.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class StyleChangeEvent extends ChiWebEvent
	{
		public static const ADDED_STYLE_PROP:String = "addedStyleProperty";
		public static const REMOVED_STYLE_PROP:String = "removedStyleProperty";
		public static const ADDED_GLOBAL_CONFIG:String = "addedGlobalConfig";
		public static const REMOVED_GLOBAL_CONFIG:String = "removedGlobalConfig";
		public static const HIGH_PRIORITY:int = 10;
		public static const LOW_PRIORITY:int = 0;
		
		public function StyleChangeEvent(type:String,
			information:Object = null,
			bubbles:Boolean = false,
			cancelable:Boolean = false)
		{
			super(type, information, bubbles, cancelable);
		}
	}
}