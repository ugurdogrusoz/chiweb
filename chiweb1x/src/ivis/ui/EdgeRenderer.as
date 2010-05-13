package ivis.ui
{
	import flash.display.Graphics;
	import flash.geom.Point;
	/**
	 * 
	 * @author Ebrahim
	 */
	public class EdgeRenderer implements IEdgeRenderer
	{
		
		/**
		 * 
		 * @param e
		 */
		public function EdgeRenderer(e: EdgeComponent)
		{
			this._edgeComponent = e;
		}

		/**
		 * 
		 * @default 
		 */
		private var _edgeComponent: EdgeComponent;

		/**
		 * 
		 * @param g
		 */
		public function draw(g:Graphics):void
		{
			var n1: NodeComponent = this._edgeComponent.sourceComponent;
			var n2: NodeComponent = this._edgeComponent.targetComponent;
			
			g.clear();
			g.lineStyle(2.0, 0x222222, .6, true);
			
			var p1: Point = n1.renderer.intersection(n2.center);
			var p2: Point = n2.renderer.intersection(n1.center);
						
			g.moveTo(n1.bounds.x + p1.x, n1.bounds.y + p1.y);
			g.lineTo(n2.bounds.x + p2.x, n2.bounds.y + p2.y);
		}
	}
}