package ivis.ui
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.net.URLRequest;
	
	import mx.events.ResizeEvent;

	public class ImageLabel extends Label
	{
		
		private var _loader: Loader;
		
		public function ImageLabel(url: String, relPos:Point=null, absPos:Point=null)
		{
			super(relPos, absPos);

			this._loader = new Loader;
			_loader.load(new URLRequest(url));			
		}
		
		override public function set component(c: Component): void
		{
			if(c == null && this._component != null) {
				this._component.removeChild(this._loader);
				return;
			}

			if(this._component === c)
				return;
				
			super.component = c;
			
			c.addChild(this._loader);
			c.addEventListener(ResizeEvent.RESIZE, onComponentChanged);
		}
		
		/**
		 * 
		 * @param e
		 */
		private function onComponentChanged(e: Event): void
		{
			this._loader.x = this._offset.x + this._component.width * this._relativePosition.x;
			this._loader.y = this._offset.y + this._component.height * this._relativePosition.y;
		}
	}
}