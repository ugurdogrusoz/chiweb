package ivis.event
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class DataChangeDispatcher extends EventDispatcher
	{
		/**
		 * Singleton instance. 
		 */
		private static var _instance:DataChangeDispatcher =
			new DataChangeDispatcher();
		
		public static function get instance() : DataChangeDispatcher
		{
			return _instance;
		}
		
		
		public function DataChangeDispatcher(target:IEventDispatcher = null)
		{
			super(target);
		}
	}
}