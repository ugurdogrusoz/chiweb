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
		protected var _x: Number;
		
		/**
		 * 
		 * @default 
		 */
		protected var _y: Number;
		
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
		 * @param x
		 * @param y
		 * @param data
		 */
		public function GraphObject(id: String = null, x: Number = 0, y: Number = 0, data: Object = null)
		{
			super(null);
			
			this._id = id != null ? id ? this.generateId();
			this._data = data;
			this._x = x;
			this._y = y;
		}
	
		//
		// getters and setters
		//
		
		/**
		 * 
		 * @return 
		 */
		public function get x(): Number
		{
			return this._x;
		}
		
		/**
		 * 
		 * @param x
		 */
		public function set x(x: Number): void
		{
			if(this._x == x)
				return;
				
			this._x = x;
			this.dispatchEvent(new XChangeEvent());
		}
		
		/**
		 * 
		 * @return 
		 */
		public function get y(): Number
		{
			return this._y;
		}
		
		/**
		 * 
		 * @param y
		 */
		public function set(y: Number): void
		{
			if(this._y == y)
				return;
				
			this._y = y;
			this.dispatchEvent(new YChangeEvent());
		}
		
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
		
		/**
		 * 
		 * @return 
		 */
		public function bounds(): Rectangle
		{
			// TODO: stub 
			return null;
		}
		
		/**
		 * 
		 * @return 
		 */
		public function asXML(): XML
		{
			// TODO: stub
			return null;
		}
		
		/**
		 * 
		 * @return 
		 */
		public function asGraphML(): XML
		{
			// TODO: stub
			return null;			
		}
		
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