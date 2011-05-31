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
		private var _renderer: INodeRenderer;
		
		/**
		 * 
		 * @param renderer
		 */
		public function NodeShape(renderer: INodeRenderer)
		{
			super();
			
			this._renderer = renderer;
		}

		/**
		 * 
		 * @return 
		 */
		protected function get renderer(): INodeRenderer
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