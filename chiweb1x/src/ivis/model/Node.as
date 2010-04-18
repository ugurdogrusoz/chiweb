package ivis.model
{
	import flash.geom.Rectangle;
	
	import ivis.model.events.HeightChangeEvent;
	import ivis.model.events.WidthChangeEvent;
	
	/**
	 * 
	 * @author Ebrahim Rajabzadeh
	 */
	public class Node extends GraphObject
	{
		/**
		 * 
		 * @default 
		 */
		public static const DEAFULT_WIDTH: Number = 60;
		/**
		 * 
		 * @default 
		 */
		public static const DEAFULT_HEIGHT: Number = 60;
		 
		private var _width: Number;
		private var _height: Number;
		private var _clusterId: uint;
		private var _parent: CompoundNode;

		/**
		 * 
		 * @param id
		 * @param x
		 * @param y
		 * @param data
		 */
		public function Node(id:String = null, x:Number = 0, y:Number = 0, data:Object=null)
		{
			super(id, x, y, data);
			
			this._width = Node.DEAFULT_WIDTH;
			this._height = Node.DEAFULT_HEIGHT;
			this._parent = null;
		}

		//
		// getters and setters
		//
		
		/**
		 * 
		 * @return 
		 */
		public function get width(): Number
		{
			return this._width;
		}
		
		/**
		 * 
		 * @param width
		 */
		public function set width(width: Number): void
		{
			if(this._width == width)
				return;
				
			this._width = width;
			this.dispatchEvent(new WidthChangeEvent);
		}
		
		/**
		 * 
		 * @return 
		 */
		public function get height(): Number
		{
			return this._height;
		}
		
		/**
		 * 
		 * @param height
		 */
		public function set height(height: Number): void
		{
			if(this._height == height)
				return;
				
			this._height = height;
			this.dispatchEvent(new HeightChangeEvent);
		}
		
		/**
		 * 
		 * @return 
		 */
		public function get clusterId(): uint
		{
			return this._clusterId;
		}
		
		//
		// public methods
		//
		
		/**
		 * 
		 * @return 
		 */
		public function isCompound(): Boolean
		{
			return false;
		}
		
		//
		// overriden public methods
		//

		/**
		 * 
		 * @return 
		 */
		override public function bounds(): Rectangle
		{
			return new Rectangle(this._x, this._y, this._width, this._height);
		}

	}
}