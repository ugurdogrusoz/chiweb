package ivis.view
{
	import flare.vis.data.DataSprite;
	
	import flash.display.Graphics;
	import flash.geom.Point;

	public class LinearEdgeUI implements IEdgeUI
	{
		protected static var _instance:IEdgeUI;
		
		/**
		 * Singleton instance.
		 */
		public static function get instance():IEdgeUI
		{
			if (_instance == null)
			{
				_instance = new LinearEdgeUI();
			}
			
			return _instance;
		}
		
		//------------------------- CONSTRUCTOR --------------------------------
		
		public function LinearEdgeUI()
		{
			// default constructor
		}
		
		//---------------------- PUBLIC FUNCTIONS ------------------------------
		
		public function setLineStyle(ds:DataSprite):void
		{
			// do nothing, just use the default settings of the EdgeRenderer
		}
		
		public function draw(ds:DataSprite,
			points:Array):void
		{
			var g:Graphics = ds.graphics;
			
			// TODO consider line styles while drawing?
			
			g.moveTo((points[0] as Point).x, (points[0] as Point).y);
			g.lineTo((points[1] as Point).x, (points[1] as Point).y);
		}
	}
}