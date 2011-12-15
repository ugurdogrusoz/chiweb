package ivis.view.ui
{
	import flare.vis.data.DataSprite;
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	import ivis.model.Node;
	import ivis.model.util.Nodes;

	/**
	 * Implementation of the INodeUI interface for rectangular compound node
	 * shapes. This class is designed to draw compound nodes as rectangles and
	 * to calculate edge clipping points for rectangular compound nodes.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class RectangularCompoundUI extends RectangularNodeUI
	{
		private static var _instance:INodeUI;
		
		/**
		 * Singleton instance.
		 */
		public static function get instance():INodeUI
		{
			if (_instance == null)
			{
				_instance = new RectangularCompoundUI();
			}
			
			return _instance;
		}
		
		//------------------------- CONSTRUCTOR --------------------------------
		
		public function RectangularCompoundUI()
		{
			// default constructor
		}
		
		/**
		 * Draws a rectangular node assuming that ds is a compound node and
		 * its "bounds" field is not null.
		 * 
		 * @param ds	data sprite (the compound node)
		 */
		public override function draw(ds:DataSprite):void
		{
			var node:Node = ds as Node;
			var g:Graphics = ds.graphics;
			
			// get the pre-calculated "rectangular" bounds
			// (note that the bounds of a compound node are updated after each
			// interactive action such as adding a node into a compound or
			// dragging a node inside a compound)
			var bounds:Rectangle = Nodes.adjustBounds(node);
			
			// draw the shape
			g.drawRect(bounds.x, bounds.y,
				bounds.width, bounds.height);
		}
	}
}