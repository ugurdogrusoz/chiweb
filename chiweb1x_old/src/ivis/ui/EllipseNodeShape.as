package ivis.ui
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	/**
	 * 
	 * @author Ebrahim
	 */
	public class EllipseNodeShape extends NodeShape
	{
		/**
		 * 
		 */
		public function EllipseNodeShape(renderer: ShapeNodeRenderer)
		{
			super(renderer);
		}

		override public function drawShape(g: Graphics): void
		{
			var n: NodeComponent = this.renderer.node;
			g.drawEllipse(0, 0, n.width, n.height);
		}

		/**
		 * 
		 * @param p
		 * @param nc
		 * @return 
		 */
		override public function intersection(p: Point): Point
		{
			var nc: NodeComponent = this.renderer.node
			var c: Point = nc.center;
			var a: Number = nc.width / 2;
			var b: Number = nc.height / 2;
			
			var rx: Number;
			var ry: Number;

			var m: Number = (p.y - c.y) / (p.x - c.x);
			
			rx = a * b / Math.sqrt(a * a * m * m + b * b);
			if(p.x < c.x)
				rx = -rx;  
			ry = m * rx;
			
			return new Point(rx + a, ry + b);
		}		
		
	}
}