package ivis.ui
{
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	
	import ivis.model.Node;
	
	import mx.core.UIComponentCachePolicy;

	/**
	 * 
	 * @author Ebrahim
	 */
	public class NodeComponent extends Component
	{
		/**
		 * 
		 * @default 
		 */
		public const DEFAULT_MARGIN: Number = 10;
		
		/**
		 * 
		 * @default 
		 */
		public static const DEFAULT_WIDTH: Number = 80;
		/**
		 * 
		 * @default 
		 */
		public static const DEFAULT_HEIGHT: Number = 60;

		/**
		 * 
		 * @default 
		 */
		private var _margin: Number;

		/**
		 * 
		 * @default 
		 */
		protected var _renderer: INodeRenderer;
		
		/**
		 * 
		 * @default 
		 */
		private var _shaodw: Boolean;
		
		/**
		 * 
		 */
		public function NodeComponent(model: Node = null)
		{
			super();

			this.width = DEFAULT_WIDTH;
			this.height = DEFAULT_HEIGHT;
			this.margin = DEFAULT_MARGIN;
			this.model = model != null ? model : new Node;
			this.renderer = new ShapeNodeRenderer(this);
			this.mouseAdapter = new NodeMouseAdapter(this);
		
			this.cacheHeuristic = true;
			this.cachePolicy = UIComponentCachePolicy.AUTO;
			
			this.shadow = true;
		}
		
		//
		// getters and setters
		//
		
		/**
		 * 
		 * @return 
		 */
		public function get margin(): Number
		{
			return this._margin;
		}
		
		/**
		 * 
		 * @param m
		 * @return 
		 */
		public function set margin(m: Number): void
		{
			this._margin = m;
			
			//this.invalidateDisplayList();
		}
		
		/**
		 * 
		 * @return 
		 */
		public function get renderer(): INodeRenderer
		{
			return this._renderer;
		}
		
		/**
		 * 
		 * @param r
		 */
		public function set renderer(r: INodeRenderer): void
		{
			this._renderer = r;
			this.invalidateDisplayList();
		}
		
		/**
		 * 
		 * @return 
		 */
		public function get center(): Point
		{
			return new Point(this.x + this.width / 2,
				this.y + this.height / 2);
		}
		
		/**
		 * 
		 * @return 
		 */
		public function get shadow(): Boolean
		{
			return this._shaodw;
		}
		
		/**
		 * 
		 * @param b
		 */
		public function set shadow(b: Boolean): void
		{
			if(this._shaodw == b)
				return;
				
			this._shaodw = b;
			
			if(this._shaodw)
				this.filters = [ new DropShadowFilter(2, 45, 0, .65, 6, 6) ];
			else
				this.filters = [];	

		}
		
		//
		// public methods
		//
		
		/**
		 * 
		 * @return 
		 */
		override public function clone(): Component
		{
			var result: NodeComponent = new NodeComponent;
			result.model = this.model;
			
			// TOOD: clone the renderer?
			result.renderer = this.renderer;
			
			return result;
		}

		/**
		 * 
		 * @return 
		 */
		override public function asXML(): XML
		{
			return XML('<node id="' + id + '" ' + 
//					'clusterID="' + clusterID + '">' + 
					'<bounds height="' + this.height + 
					'" width="' + this.width + 
					'" x="' + this.x + 
					'" y="' + this.y + 
					'" />' + 
					'</node>')
		}
		
		//
		// protected methods
		//
		
		/**
		 * 
		 * @param unscaledWidth
		 * @param unscaledHeight
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number): void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			this._renderer.draw(this.graphics);
		}
	}
}