package ivis.model.events
{
	import flash.events.Event;

	public class XChangeEvent extends Event
	{
		public static const TYPE: String = "xChanged";

		public function XChangeEvent()
		{
			super(XChangeEvent.TYPE);
		}
		
	}
}