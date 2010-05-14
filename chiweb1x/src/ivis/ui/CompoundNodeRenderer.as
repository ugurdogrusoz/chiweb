package ivis.ui
{
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;

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
			var r: Rectangle = this.node.bounds;
			
			trace("[" + new Date().time + "]" + r);
			
			g.clear();
			g.beginFill(0xaabbaa, .3);
			g.drawRect(r.x, r.y, r.width, r.height);
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