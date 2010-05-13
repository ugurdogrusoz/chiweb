package ivis.ui
{
	import flash.events.MouseEvent;

	/**
	 * 
	 * @author Ebrahim
	 */
	public class EdgeMouseAdapter implements IMouseAdapter
	{
		/**
		 * 
		 * @default 
		 */
		private var _edge: EdgeComponent;
		
		/**
		 * 
		 */
		public function EdgeMouseAdapter()
		{
		}

		//
		// getters & setters
		//
		
		/**
		 * 
		 * @return 
		 */
		public function get component(): Component
		{
			return this._edge;
		}
		
		/**
		 * 
		 * @param e
		 */
		public function set component(e: Component): void
		{
			this._edge = e as EdgeComponent;
		}

		//
		// public methods
		//
		
		/**
		 * 
		 * @param e
		 */
		public function onMouseDown(e:MouseEvent):void
		{
		}
		
		/**
		 * 
		 * @param e
		 */
		public function onMouseMove(e:MouseEvent):void
		{
		}
		
		/**
		 * 
		 * @param e
		 */
		public function onMouseUp(e:MouseEvent):void
		{
		}
		
	}
}