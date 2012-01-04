package ivis.util
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	/**
	 * Utility class for image operations.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class ImageUtils
	{
		/**
		 * Map for caching images (with url as a key).
		 */
		private static var _imageMap:Object = new Object();
		
		/**
		 * Map for io error flags (with url as a key).
		 */
		private static var _ioError:Object = new Object();
		
		
		public function ImageUtils()
		{
			throw new Error("ImageUtils is an abstract class.");
		}
		
		
		/**
		 * Loads the bitmap image to the image map for the given url.
		 * 
		 * @param url	url of the image to be loaded
		 */
		public static function loadImage(url:String):void
		{	
			var bmp:BitmapData;
			
			// internal function to be invoked when image loaded
			function onLoadComplete(evt:Event):void
			{
				bmp = evt.target.content.bitmapData;
				_imageMap[url] = bmp;
				trace ("[ImageUtils.onLoadComplete] image loaded: " + url);
			};
			
			// internal function to be invoked when an IO error occurs
			function onIOError(evt:IOErrorEvent):void
			{
				trace ("[ImageUtils.onIOError] cannot load image:" + url);
				_ioError[url] = true;
			};
			
			// process url
			if (url.length > 0)
			{
				var urlRequest:URLRequest = new URLRequest(url);
				var loader:Loader = new Loader();
				
				// add listeners
				
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,
					onLoadComplete);
				
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,
					onIOError);
				
				trace ("[ImageUtils.loadImage] loading image: " + url);
				
				// init io error map for the url  
				_ioError[url] = false;
				
				//loader.load(urlRequest, new LoaderContext(true));
				loader.load(urlRequest);
			}
		}
		
		/**
		 * Returns the bitmap data associated with the given url.
		 * 
		 * @param url	url of the image
		 */
		public static function getBitmapData(url:String):BitmapData
		{
			return _imageMap[url];
		}
		
		/**
		 * Resets the cached bitmap data for the given url.
		 * 
		 * @param url	url of the image 
		 */
		public static function resetBitmapData(url:String):BitmapData
		{
			var bmp:BitmapData = getBitmapData(url);
			
			delete _imageMap[url];
			delete _ioError[url];
			
			return bmp;
		}
		
		/**
		 * Checks if the given url is broken.
		 * 
		 * @param url	url to be checked
		 */
		public static function isBroken(url:String):Boolean
		{
			return _ioError[url];
		}
	}
}