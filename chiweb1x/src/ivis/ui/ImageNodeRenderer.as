package ivis.ui
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.URLRequest;

	/**
	 * 
	 * @author Ebrahim
	 */
	public class ImageNodeRenderer implements INodeRenderer
	{
		/**
		 * 
		 * @default 
		 */
		private var _nodeComponent: NodeComponent;
		
		/**
		 * 
		 * @default 
		 */
		private var _bitmapData: BitmapData;

		/**
		 * 
		 * @default 
		 */
		private var _imageShape: NodeShape;
		 
		 
		/**
		 * 
		 * @default 
		 */
		private var _fitNodeToImage: Boolean = true;
		
		/**
		 * 
		 * @param url
		 */
		public function ImageNodeRenderer(url: String)
		{
			var ld: Loader = new Loader;
			ld.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onBitmapLoaded);
			ld.load(new URLRequest(url));
			this._imageShape = new RectangleNodeShape(this);
		}
		
		/**
		 * 
		 * @return 
		 */
		public function get node(): NodeComponent
		{
			return this._nodeComponent;
		}

		/**
		 * 
		 * @param n
		 */
		public function set node(n: NodeComponent): void
		{
			this._nodeComponent = n;
		}
		
		/**
		 * 
		 */
		public function fitToImageSize(): void
		{
			if(this._bitmapData != null && this._nodeComponent != null) {
				this._nodeComponent.width = this._bitmapData.width;
				this._nodeComponent.height = this._bitmapData.height;
			}
		}
		
		/**
		 * 
		 * @param g
		 */
		public function draw(g:Graphics): void
		{
			var m: Matrix = this._fitNodeToImage ? null : this.bitmapScaleMatrix();
			g.beginBitmapFill(this._bitmapData, m, false, true);
			g.drawRect(0, 0, this._nodeComponent.width, this._nodeComponent.height);
			g.endFill();
		}
		
		/**
		 * 
		 * @param p
		 * @return 
		 */
		public function intersection(p: Point): Point
		{
			return this._imageShape.intersection(p);
		}
		
		/**
		 * 
		 * @param e
		 */
		private function onBitmapLoaded(e: Event): void
		{
			this._bitmapData = Bitmap(e.currentTarget.content).bitmapData;
			
			if(this._fitNodeToImage)
				this.fitToImageSize();
		}
		
		/**
		 * 
		 * @return 
		 */
		private function bitmapScaleMatrix(): Matrix
		{
			var m: Matrix = new Matrix;
			var sx: Number = this._nodeComponent.width / this._bitmapData.width;
			var sy: Number = this._nodeComponent.height / this._bitmapData.height;
			m.scale(sx, sy);
			return m;			
		}
	}
}