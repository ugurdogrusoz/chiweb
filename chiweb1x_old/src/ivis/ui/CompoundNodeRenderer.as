package ivis.ui
{
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.InterpolationMethod;
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.utils.ColorUtil;

	/**
	 * 
	 * @author Ebrahim
	 */
	public class CompoundNodeRenderer implements INodeRenderer
	{
		
		/**
		 * 
		 * @default 
		 */
		private var _node: CompoundNodeComponent;
		
		private var _color: uint = 0x273445;
		
		/**
		 * 
		 */
		public function CompoundNodeRenderer()
		{
		}

		/**
		 * 
		 * @param g
		 */
		public function draw(g:Graphics):void
		{
			var m: Matrix = new Matrix;
			m.createGradientBox(this.node.width, this.node.height, 45);
			
			var c1: uint = this._color;
			var c2: uint = ColorUtil.adjustBrightness(c1, 80);
			
			g.clear();
            g.beginGradientFill(GradientType.LINEAR, [c1, c2],
            	[.27, .27], [32, 255], m, SpreadMethod.REFLECT, InterpolationMethod.RGB, 1)

			g.drawRoundRect(0, 0, this.node.width, this.node.height, 10, 10);
			 
			g.endFill();
		}
		
		/**
		 * 
		 * @param p
		 * @return 
		 */
		public function intersection(p:Point):Point
		{
			var b: Rectangle = this.node.bounds;
			var nx: Number = b.x + b.width / 2;
			var ny: Number = b.y + b.height / 2;
			
			var dy: Number = p.y - ny;
			var dx: Number = p.x - nx;
			
			var mline: Number = dy / dx;
			var mnode: Number = b.height / b.width;
			
			var rx: Number;
			var ry: Number;

			if(Math.abs(mline) > Math.abs(mnode))
			{
				ry = dy > 0 ? b.height : 0;
				rx = (ry - b.height / 2) / mline + b.width / 2;
			}
			else
			{
				rx = dx > 0 ? b.width : 0;
				ry = (rx - b.width / 2) * mline + b.height / 2;
			}
			
			return new Point(rx, ry);
		}
		
		/**
		 * 
		 * @param n
		 */
		public function set node(n:NodeComponent):void
		{
			this._node = n as CompoundNodeComponent;
		}
		
		/**
		 * 
		 * @return 
		 */
		public function get node():NodeComponent
		{
			return this._node;
		}
		
	}
}