package ivis.ui
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	/**
	 * 
	 * @author Ebrahim
	 */
	public class NodeShape
	{
		
		/**
		 * 
		 * @default 
		 */
		private var _renderer: ShapeNodeRenderer;
		
		/**
		 * 
		 * @param renderer
		 */
		public function NodeShape(renderer: ShapeNodeRenderer)
		{
			super();
			
			this._renderer = renderer;
		}

		/**
		 * 
		 * @return 
		 */
		protected function get renderer(): ShapeNodeRenderer
		{
			return this._renderer;
		}
		
		//
		// public methods
		//
		
		/**
		 * This method is meant to be overiden by the subclasses 
		 *
		 * @param g
		 */ 
		public function drawShape(g: Graphics): void
		{
			
		}
		
		/**
		 * This method is meant to be overiden by the subclasses 
		 * 
		 * @param p1
		 * @param nc
		 * @return 
		 */
		public function intersection(p: Point): Point
		{
			return null; 
		}
	}
}