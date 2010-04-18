package ivis.ui
{
	import flash.display.Graphics;

	public class ShapeNodeRenderer implements INodeRenderer
	{
		private var _nodeComponent: NodeComponent;
		
		public function ShapeNodeRenderer(n: NodeComponent)
		{
			this._nodeComponent = n;
		}

		public function draw(g:Graphics)
		{
			
		}
		
	}
}