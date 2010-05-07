package ivis.ui
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	/**
	 * 
	 * @author Ebrahim
	 */
	public class TriangleNodeShape extends NodeShape
	{
		/**
		 * 
		 * @param renderer
		 */
		public function TriangleNodeShape(renderer:ShapeNodeRenderer)
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
			g.moveTo(n.width / 2, 0);
			g.lineTo(n.width, n.height);
			g.lineTo(0, n.height);
		}

		/**
		 * 
		 * @param p
		 * @param nc
		 * @return 
		 */
		override public function intersection(p: Point): Point
		{
			var n: NodeComponent = this.renderer.node;
			var c: Point = n.center;
			var a: Number = n.width / 2;
			var b: Number = n.height / 2;

			var rx: Number;
			var ry: Number;
			
			var dy: Number = p.y - c.y;
			var dx: Number = p.x - c.x;
			
			var m: Number = dy / dx;
			var l: Number = b / a;
			
			if(Math.abs(m) < l || dy < 0)
			{
				if(dx > 0)
					rx = b / (2*l - m);
				else
					rx = -b / (2*l + m)
				ry = m * rx;
			}
			else
			{
				ry = b;
				rx = ry / m;
			}
			
			return new Point(rx + a, ry + b);
		}
	}
}