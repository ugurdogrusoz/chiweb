package ivis.model
{
	// imports
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	
	import ivis.model.events.XChangeEvent;
	import ivis.model.events.YChangeEvent;

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
		 * @param id
		 * @param data
		 */
		public function GraphObject(id: String = null, data: Object = null)
		{
			super(null);
			
			this._id = id != null ? id : ""/*this.getNewId()*/;
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
		// private methods
		//
		private static function generateId(): String
		{
			// TODO: id generation code goes here (use int, string hash?)
			return null;
		}
		
	}
}