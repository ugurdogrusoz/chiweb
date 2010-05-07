package ivis.ui
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	/**
	 * 
	 * @author Ebrahim
	 */
	public class RectangleNodeShape extends NodeShape
	{
		/**
		 * 
		 * @param renderer
		 */
		public function RectangleNodeShape(renderer: ShapeNodeRenderer)
		{
			super(renderer);
		}

		/**
		 * 
		 * @param g
		 */
		override public function drawShape(g: Graphics): void
		{
			var n: NodeComponent = this.renderer.node;
			g.drawRect(0, 0, n.width, n.height);
		}
		
		/**
		 * 
		 * @param p
		 * @return 
		 */
		override public function intersection(p: Point): Point
		{
			var nc: NodeComponent = this.renderer.node;
			var nx: Number = nc.x + nc.width / 2;
			var ny: Number = nc.y + nc.height / 2;
			
			var dy: Number = p.y - ny;
			var dx: Number = p.x - nx;
			
			var mline: Number = dy / dx;
			var mnode: Number = nc.height / nc.width;
			
			var rx: Number;
			var ry: Number;

			if(Math.abs(mline) > Math.abs(mnode))
			{
				ry = dy > 0 ? nc.height : 0;
				rx = (ry - nc.height / 2) / mline + nc.width / 2;
			}
			else
			{
				rx = dx > 0 ? nc.width : 0;
				ry = (rx - nc.width / 2) * mline + nc.height / 2;
			}
			
			return new Point(rx, ry);
		}		
	}
}