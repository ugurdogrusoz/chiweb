package ivis.ui
{
	import ivis.model.Edge;

	/**
	 * 
	 * @author Ebrahim
	 */
	public class EdgeComponent extends Component
	{
		
		/**
		 * 
		 * @default 
		 */
		private var _renderer: IEdgeRenderer;
		
		/**
		 * 
		 */
		public function EdgeComponent()
		{
			super();
			
			this.model = new Edge;
			this._renderer = new EdgeRenderer(this);
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
		
		override public function clone(): EdgeComponent
		{
			var result: EdgeComponent = new EdgeComponent
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