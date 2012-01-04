package ui
{	
	import flare.vis.data.DataSprite;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.utils.setTimeout;
	
	import ivis.util.ImageUtils;
	import ivis.view.ui.INodeUI;
	import ivis.view.ui.RectangularNodeUI;

	
	/**
	 * Custom UI class for image nodes. Extends RectangularNodeUI to draw
	 * rectangular nodes with images.
	 */
	public class ImageNodeUI extends RectangularNodeUI
	{
		private static var _instance:INodeUI;
		
		/**
		 * Singleton instance.
		 */
		public static function get instance():INodeUI
		{
			if (_instance == null)
			{
				_instance = new ImageNodeUI();
			}
			
			return _instance;
		}
		
		//------------------------- CONSTRUCTOR --------------------------------
		
		public function ImageNodeUI()
		{
			// default constructor
		}
		
		//---------------------- PUBLIC FUNCTIONS ------------------------------
		
		/**
		 * Draws a rectangular image node.
		 * 
		 * @param ds	data sprite (the node)
		 */
		public override function draw(ds:DataSprite):void
		{
			var bmp:BitmapData = ImageUtils.getBitmapData(ds.props.imageUrl);
			
			// no image loaded for this sprite yet, so try to load image
			if (bmp == null)
			{
				// try to load image from the given url
				ImageUtils.loadImage(ds.props.imageUrl);
				
				// draw image when loaded
				super.draw(ds);
				this.drawOnLoad(ds);
			}
			else
			{
				// bitmap found, so draw it immediately
				this.drawImage(ds);
			}
		}
		
		//---------------------- PROTECTED FUNCTIONS ---------------------------
		
		/**
		 * Waits for the image of the given data sprite to load and draws
		 * the image when ready.
		 * 
		 * @param ds	data sprite (the node) 
		 */
		protected function drawOnLoad(ds:DataSprite):void
		{
			trace ("[ImageNodeUI.drawOnLoad] waiting for bmp to load..");
			
			var bmp:BitmapData;
			var url:String = ds.props.imageUrl;
			
			function waitForLoad():void
			{
				if (!ImageUtils.isBroken(url))
				{
					bmp = ImageUtils.getBitmapData(url);
					
					if (bmp == null)
					{
						// wait for image to be loaded
						drawOnLoad(ds);
					}
					else
					{
						// image loaded!
						ds.graphics.clear();
						setLineStyle(ds);
						drawImage(ds);
					}
				}
			};
			
			setTimeout(waitForLoad, 50);
		}
		
		/**
		 * Draws the image for the given data sprite.
		 * 
		 * @param ds	data sprite (the node)
		 */
		protected function drawImage(ds:DataSprite):void
		{
			var bmp:BitmapData = ImageUtils.getBitmapData(ds.props.imageUrl);
			
			if (bmp == null)
			{
				trace ("[ImageNodeUI.drawImage] failed to retrieve image..");
			}
			else
			{
				var scaleX:Number = ds.w / bmp.width;
				var scaleY:Number = ds.h / bmp.height;
				
				var m:Matrix = new Matrix();
				m.scale(scaleX, scaleY);
				m.translate(-(bmp.width*scaleX)/2, -(bmp.height*scaleY)/2);
				
				ds.graphics.beginBitmapFill(bmp, m, false, true);
				super.draw(ds);
				ds.graphics.endFill();
			}
		}
	}
}