package ivis.ui
{
	import ivis.model.CompoundNode;
	
	public class CompoundNodeComponent extends NodeComponent
	{
		public function CompoundNodeComponent()
		{
			super();
	
			this.model = new CompoundNode;
			this._renderer = new CompoundNodeRenderer(this);
		}
		
		
		//
		// protected methods
		//
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number): void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			this._renderer.draw(this.graphics);
		}

	}
}