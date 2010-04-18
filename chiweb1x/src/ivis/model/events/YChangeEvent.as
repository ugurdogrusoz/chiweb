package ivis.model.events
{
	import flash.events.Event;

	public class YChangeEvent extends Event
	{
		public static const TYPE: String = "yChanged";
		
		public function YChangeEvent()
		{
			super(YChangeEvent.TYPE);
		}
		
	}
}