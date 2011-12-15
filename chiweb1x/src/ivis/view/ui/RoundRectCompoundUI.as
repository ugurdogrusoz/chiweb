package ivis.view.ui
{
	import flare.vis.data.DataSprite;
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	import ivis.model.Node;
	import ivis.model.util.Nodes;

	/**
	 * Implementation of the INodeUI interface for the round rectangle compound
	 * node shape. This class is designed to draw compound nodes as round
	 * rectangles and to calculate edge clipping points for rectangular compound
	 * nodes.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class RoundRectCompoundUI extends RoundRectNodeUI
	{
		private static var _instance:INodeUI;
		
		/**
		 * Singleton instance.
		 */
		public static function get instance():INodeUI
		{
			if (_instance == null)
			{
				_instance = new RoundRectCompoundUI();
			}
			
			return _instance;
		}
		
		//------------------------- CONSTRUCTOR --------------------------------
		
		public function RoundRectCompoundUI()
		{
			// default constructor
		}
		
		//---------------------- PUBLIC FUNCTIONS ------------------------------
		
		/**
		 * Sets the line style of the node.
		 * 
		 * @param ds	data sprite (the compound node)
		 */
		public override function setLineStyle(ds:DataSprite):void
		{
			var pixelHinting:Boolean = true;
			var g:Graphics = ds.graphics;
			
			g.lineStyle(ds.lineWidth,
				ds.lineColor,
				ds.lineAlpha,
				pixelHinting);
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
			g.drawRoundRect(bounds.x, bounds.y,
				bounds.width, bounds.height,
				bounds.width / 4, bounds.height / 4);
		}
		
		// TODO also override function intersection
	}
}