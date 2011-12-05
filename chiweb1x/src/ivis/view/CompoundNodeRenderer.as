package ivis.view
{
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import ivis.model.Edge;
	import ivis.model.Node;
	import ivis.util.CompoundUIs;
	import ivis.util.GeneralUtils;
	import ivis.util.NodeUIs;
	import ivis.util.Nodes;

	/**
	 * This class is specifically designed to render compound nodes.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class CompoundNodeRenderer extends NodeRenderer
	{
		/**
		 * Singleton instance. 
		 */
		private static var _instance:CompoundNodeRenderer =
			new CompoundNodeRenderer();
		
		//private var _imgCache:ImageCache = ImageCache.instance;
		
		public static function get instance() : CompoundNodeRenderer
		{
			return _instance;
		}
		
		public function CompoundNodeRenderer(defaultSize:Number = 6)
		{
			super(defaultSize);
		}
		
		/**
		 * Overridden rendering function which is specialized for the
		 * compound nodes. If the data sprite is not a compound node,
		 * then the rendering is just forwarded to the render method  
		 * of the super class.
		 * 
		 * @param d	data sprite to be rendered
		 */
		public override function render(d:DataSprite) : void
		{	
			var node:Node;
			var g:Graphics = d.graphics;
			var lineAlpha:Number = d.lineAlpha;
			var fillAlpha:Number = d.fillAlpha;
			
			if (d is Node)
			{
				node = (d as Node);
				
				if (!node.isInitialized() ||
					node.bounds == null)
				{
					// no child or bounds set yet,
					// render with default size & shape					
					super.render(d);
				}
				else
				{
				//	trace("[CompoundNodeRenderer.render] node id: " + d.data.id +
				//		", x: " + node.bounds.x + ", y: " + node.bounds.y +
				//		", w: " + node.bounds.width + ", h: " + node.bounds.height);
					
					g.clear();
					
					var nodeUI:INodeUI = CompoundUIs.getUI(d.shape);
					
					if (lineAlpha > 0 && d.lineWidth > 0)
					{
						nodeUI.setLineStyle(node);
					}
					
					if (fillAlpha > 0)
					{
						// draw the background color:
						// Using a bit mask to avoid transparent mdes when fillcolor=0xffffffff.
						// See https://sourceforge.net/forum/message.php?msg_id=7393265
						g.beginFill(0xffffff & d.fillColor, fillAlpha);
						nodeUI.draw(node);
						g.endFill();
						
						// TODO draw an image on top?
						//drawImage(node, this.adjustSize(node));
					}
				}
				
				// bring (recursively) child nodes & edges inside the compound
				// to the front, otherwise they remain on the back side of
				// the compound node.
				Nodes.bringNodeToFront(node);
			}
			else
			{
				// if the data sprite is not a compound node, then just call
				// the superclass renderer function.
				super.render(d);
			}
		}
		
		/**
		 * Draws the shape of the given sprite. This function uses the width 
		 * and height values of the given bounds. This method only support
		 * two shapes: NodeShapes.RECTANGLE and NodeShapes.ROUND_RECTANGLE. No
		 * other shapes are supported for compound nodes (for consistency). 
		 * 
		 * @param s			target sprite
		 * @param shape		shape name as a string
		 * @param bounds	rectangular bounds for the sprite s
		 */
		// TODO not used anymore..
		private function drawShape(s:Sprite,
								   shape:String,
								   bounds:Rectangle) : void
		{
			var g:Graphics = s.graphics;
			
			if (shape == null)
			{
				// do not draw shape
			}
			else if (shape == NodeUIs.ROUND_RECTANGLE)
			{
				g.drawRoundRect(bounds.x, bounds.y,
					bounds.width, bounds.height,
					bounds.width / 4, bounds.height / 4);
			}
			else // shape is RECTANGLE (or any other shape is ignored)
			{
				g.drawRect(bounds.x, bounds.y,
					bounds.width, bounds.height);
			}
		}
		
		/*
		private function drawImage(d:DataSprite, size:Number):void
		{
			var url:String = d.props.compoundImageUrl;
			
			if (size > 0 && url != null && StringUtil.trim(url).length > 0) {
				// Load the image into the cache first?
				if (!_imgCache.contains(url)) {trace("Will load IMAGE...");
					_imgCache.loadImage(url);
				}
				if (_imgCache.isLoaded(url)) {trace(" .LOADED :-)");
					draw();
				} else {trace(" .NOT loaded :-(");
					drawWhenLoaded();
				}
				
				function drawWhenLoaded():void {
					setTimeout(function():void {trace(" .TIMEOUT: Checking again...");
						if (_imgCache.isLoaded(url)) draw();
						else if (!_imgCache.isBroken(url)) drawWhenLoaded();
					}, 50);
				}
				
				function draw():void {trace("Will draw: " + d.data.id);
					// Get the image from cache:
					var bd:BitmapData = _imgCache.getImage(url);
					
					if (bd != null) {
						var bmpSize:Number = Math.min(bd.height, bd.width);
						var scale:Number = size/bmpSize;
						
						var m:Matrix = new Matrix();
						m.scale(scale, scale);
						m.translate(-(bd.width*scale)/2, -(bd.height*scale)/2);
						
						d.graphics.beginBitmapFill(bd, m, false, true);
						//drawShape(d, d.shape, size);
						drawShape(d,
							d.shape,
							adjustBounds(d as CompoundNodeSprite));
						d.graphics.endFill();
					}
				}
			}
		}
		*/
		
		/*
		private function adjustSize(node:Node) : Number
		{
			var size:Number = 0;
			
			if (node.isInitialized())
			{
				size = Math.min(node.bounds.width,
					node.bounds.height);
			}
			
			return size;
		}
		*/
	}
}