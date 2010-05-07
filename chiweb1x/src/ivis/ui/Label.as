package ivis.ui
{
	import flash.display.Loader;
	import flash.net.URLRequest;
	
	/**
	 * 
	 * @author Ebrahim
	 */
	public class Label
	{
		
		/**
		 * 
		 * @default 
		 */
		private var _label: mx.controls.Label;
		
		/**
		 * 
		 * @default 
		 */
		private var _url: String;
		
		/**
		 * 
		 * @default 
		 */
		private var _image: Loader;
		
		/**
		 * 
		 */
		public function Label()
		{
			this._label = null;
			this._image = null;
			this._url = "";
		}
		
		//
		// setters and getters
		//
		
		/**
		 * 
		 * @return 
		 */
		public function get text(): String
		{
			if(this._label != null)
				return this._label.text;
			
			return null;
		}
		
		/**
		 * 
		 * @param s
		 */
		public function set text(s: String): void
		{
			
			if(this._label == null)
				this._label = new mx.controls.Label;
				
			this._label.text = s;
		}
		
		/**
		 * 
		 * @return 
		 */
		public function get imageUrl(): String
		{
			return this._url;
		}
		
		/**
		 * 
		 * @param s
		 */
		public function set imageUrl(s: String): void
		{
			this._url = s;
			
			if(this._image == null)
				this._image = new Loader;
				
			var req: URLRequest = new URLRequest(s);
			this._image.load(req);
		}
	}
}