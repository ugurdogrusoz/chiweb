package ivis.ui
{
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Point;
	/**
	 * 
	 * @author Ebrahim
	 */
	public class ShapeNodeRenderer implements INodeRenderer
	{
		
		private var _shape: NodeShape;
		
		/**
		 * 
		 * @default 
		 */
		private var _color1: int = 0xffffff;
		/**
		 * 
		 * @default 
		 */
		private var _color2: int = 0xa4c290;
		
		/**
		 * 
		 * @default 
		 */
		private var _nodeComponent: NodeComponent;

		/**
		 * 
		 * @param n
		 */
		public function ShapeNodeRenderer()
		{
			this._shape = new RectangleNodeShape(this);
		}

		//
		// getters & setters
		//
		
		public function get node(): NodeComponent
		{
			return this._nodeComponent;
		}

		public function get shape(): NodeShape
		{
			return this._shape;
		}
		
		public function set shape(s: NodeShape): void
		{
			this._shape = s;
		}
		
		public function intersection(p: Point): Point
		{
			return this._shape.intersection(p);
		}
		
		public function set node(n: NodeComponent): void
		{
			this._nodeComponent = n;
		}
		
		//
		// public methods
		//
		
		/**
		 * 
		 * @param g
		 */
		public function draw(g: Graphics): void
		{
			var w: Number = this._nodeComponent.width;
			var h: Number = this._nodeComponent.height;

			var mx: Matrix = new Matrix;
			
			
			mx.createGradientBox(w, h, 45);
			
			g.beginGradientFill(
				GradientType.LINEAR,
				[_color1, _color2],
				[.70, .70],
				[0,  255],
				mx
			);
			
			this._shape.drawShape(g);
			
			g.endFill();
		}
	}
}