package ivis.ui
{
	import ivis.model.CompoundNode;
	
	/**
	 * 
	 * @author Ebrahim
	 */
	public class CompoundNodeComponent extends NodeComponent
	{
		/**
		 * 
		 */
		public function CompoundNodeComponent()
		{
			super();
	
			this.model = new CompoundNode;
			this.renderer = new CompoundNodeRenderer(this);
			this.mouseAdapter = new CompoundNodeMouseAdapter(this);
		}
		
		//
		// overriden public methods
		//
		
		override public function clone(): CompoundNodeComponent
		{
			var result: NodeComponent = new CompoundNodeComponent;
			result.model = this.model;
			result.renderer = this.renderer;
			
			return result;
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