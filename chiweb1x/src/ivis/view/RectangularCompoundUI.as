package ivis.view
{
	import flare.vis.data.DataSprite;
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	import ivis.model.Node;
	import ivis.util.Nodes;

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
		 * @param ds			data sprite (the compound node)
		 * @param defaultSize	default size value of the NodeRenderer
		 */
		public override function draw(ds:DataSprite,
							 defaultSize:Number):void
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