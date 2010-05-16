package ivis.ui
{
	import flash.geom.Point;
	
	/**
	 * 
	 * @author Ebrahim
	 */
	public class Label
	{
		
		/**
		 * 
		 * @default 
		 */
		protected var _relativePosition: Point;
		
		/**
		 * 
		 * @default 
		 */
		protected var _component: Component;
		
		/**
		 * 
		 * @default 
		 */
		protected var _offset: Point;
		
		/**
		 * 
		 */
		public function Label(relPos: Point = null, absPos: Point = null)
		{
			this._offset = absPos != null ? absPos : new Point;
			this._relativePosition = relPos != null ? relPos : new Point;
		}
		
		/**
		 * 
		 * @return 
		 */
		public function get relativeposition(): Point
		{
			return this._relativePosition;
		}
		
		/**
		 * 
		 * @param x
		 * @param y
		 */
		public function set relativePosition(p: Point): void
		{
			this._relativePosition = p;
		}
		
		/**
		 * 
		 * @return 
		 */
		public function get offset(): Point
		{
			return this._offset;
		}
		
		/**
		 * 
		 * @param x
		 * @param y
		 */
		public function set offset(p: Point): void
		{
			this._offset = p;
		}
		
		/**
		 * 
		 * @return 
		 */
		public function get component(): Component
		{
			return this._component;
		}
		
		/**
		 * 
		 * @param c
		 */
		public function set component(c: Component): void
		{
			this._component = c;
		}
	}
	
	
}