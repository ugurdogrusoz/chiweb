package ivis.ui
{
	import ivis.model.Node;

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
		private var _margin: Number;

		/**
		 * 
		 * @default 
		 */
		private var _renderer: INodeRenderer;
		
		/**
		 * 
		 */
		public function NodeComponent()
		{
			super();

			this._margin = DEFAULT_MARGIN;
			this.model = new Node;
			this._renderer = new ShapeNodeRenderer(this);
		}
		
		//
		// getters and setters
		//
		
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
		}
		
		//
		// public methods
		//
		
		/**
		 * 
		 * @return 
		 */
		override public function clone(): NodeComponent
		{
			var result: NodeComponent = new NodeComponent;
			result.model = this.model;
			result.renderer = this.renderer;
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