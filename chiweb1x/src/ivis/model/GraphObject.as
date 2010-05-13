package ivis.model
{
	// imports
	import flash.events.EventDispatcher;

	/**
	 * 
	 * @author Ebrahim Rajabzadeh 
	 */
	public class GraphObject extends EventDispatcher
	{
		/**
		 * 
		 * @default 
		 */
		protected var _id: String;
		
		/**
		 * 
		 * @default 
		 */
		protected var _data: Object;
		
		/**
		 * 
		 * @default 
		 */
		private static var _idCounter: uint = 0;
		 
		/**
		 * 
		 * @param id
		 * @param data
		 */
		public function GraphObject(id: String = null, data: Object = null)
		{
			super(null);
			
			this._id = id != null ? id : generateId();
			this._data = data;
		}
	
		//
		// getters and setters
		//
		
		/**
		 * 
		 * @return 
		 */
		public function get id(): String
		{
			return this._id;
		}
		
		/**
		 * 
		 * @return 
		 */
		public function get data(): Object
		{
			return this._data;
		}
		
		/**
		 * 
		 * @param data
		 */
		public function set data(data: Object): void
		{
			this._data = data;
		}
		
		//
		// public methods
		//
		
		//
		// protected methods
		//
		/**
		 * 
		 * @return 
		 */
		protected static function generateId(): String
		{
			return String(++_idCounter);
		}
		
	}
}