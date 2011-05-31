package ivis.model.events
{
	import flash.events.Event;

	public class HeightChangeEvent extends Event
	{
		public static const TYPE: String = "heightChanged";

		public function HeightChangeEvent()
		{
			super(HeightChangeEvent.TYPE);
		}
		
	}
}