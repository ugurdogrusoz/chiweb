package ivis.model.events
{
	import flash.events.Event;

	public class WidthChangeEvent extends Event
	{
		public static const TYPE: String = "widthChanged";

		public function WidthChangeEvent()
		{
			super(WidthChangeEvent.TYPE);
		}
		
	}
}