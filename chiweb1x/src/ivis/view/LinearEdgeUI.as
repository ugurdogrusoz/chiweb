package ivis.view
{
	import flare.vis.data.DataSprite;
	
	import flash.display.Graphics;
	import flash.geom.Point;

	/**
	 * Implementation of the IEdgeUI interface for linear edge shapes.
	 * This class is designed to draw edges as simple lines.
	 * 
	 * @author Selcuk Onur Sumer
	 */
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
		
		public function draw(ds:DataSprite):void
		{
			var g:Graphics = ds.graphics;
			
			// TODO consider line styles while drawing?
			
			var startPoint:Point = ds.props.$startPoint as Point;
			var endPoint:Point = ds.props.$endPoint as Point;
			
			g.moveTo(startPoint.x, startPoint.y);
			g.lineTo(endPoint.x, endPoint.y);
		}
	}
}