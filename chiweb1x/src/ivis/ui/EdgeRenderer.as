package ivis.ui
{
	import flash.display.Graphics;

	public class EdgeRenderer implements IEdgeRenderer
	{
		private var _edgeComponent: EdgeComponent;
		
		public function EdgeRenderer(e: EdgeComponent)
		{
			this._edgeComponent = e;
		}

		public function draw(g:Graphics):void
		{
			
		}
		
	}
}