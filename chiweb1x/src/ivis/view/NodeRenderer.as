package ivis.view
{
	import flare.util.Shapes;
	import flare.vis.data.DataSprite;
	import flare.vis.data.render.ShapeRenderer;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	import ivis.util.NodeShapes;

	/**
	 * Renderer for simple (regular) and bend nodes.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class NodeRenderer extends ShapeRenderer
	{
		private static var _instance:NodeRenderer = new NodeRenderer();
		
		public static function get instance():NodeRenderer
		{
			return _instance;
		}
		
		public function NodeRenderer(defaultSize:Number = 6)
		{
			this.defaultSize = defaultSize;
		}
		
		public override function render(d:DataSprite):void
		{
			trace("[NodeRenderer.render] node: " + d.data.id + 
				", size: " + d.size + ", shape: " + d.shape);
			
			var lineAlpha:Number = d.lineAlpha;
			var fillAlpha:Number = d.fillAlpha;
			var size:Number = d.size * defaultSize;
			var width:Number = d.w * defaultSize;
			var height:Number = d.h * defaultSize;
			
			var g:Graphics = d.graphics;
			g.clear();
			
			if (lineAlpha > 0 && d.lineWidth > 0)
			{
				var pixelHinting:Boolean =
					(d.shape === NodeShapes.ROUND_RECTANGLE);
				
				g.lineStyle(d.lineWidth,
					d.lineColor,
					lineAlpha,
					pixelHinting);
			}
			
			if (fillAlpha > 0)
			{
				// draw background
				// using a bit mask to avoid transparency
				// when fillcolor is 0xffffffff.
				g.beginFill(0xffffff & d.fillColor, fillAlpha);
				this.drawShape(d, d.shape, size, width, height);
				g.endFill();
				
				// TODO Draw image
				//drawImage(d, size);
			}
		}
		
		private function drawShape(s:Sprite,
			shape:String,
			size:Number,
			width:Number,
			height:Number):void
		{
			var g:Graphics = s.graphics;
			
			if (shape == null)
			{
				// do not draw anything
			}
			else if (shape == Shapes.SQUARE)
			{
				g.drawRect(-size/2, -size/2, size, size);
			}
			else if (shape == NodeShapes.RECTANGLE)
			{
				g.drawRect(-width/2, -height/2, width, height);
			}
			else if (shape == Shapes.POLYGON)
			{
				// TODO allow drawing arbitrary polygons
			}
			else if (shape == NodeShapes.ROUND_RECTANGLE)
			{
				g.drawRoundRect(-width / 2, -height / 2,
					width, height,
					width / 2, height / 2);
			}
			else // shape == Shapes.CIRCLE or an unknown shape
			{
				Shapes.drawCircle(g, size/2);
			}
			
			/*
			switch (shape) {
				case null:
					break;
				case NodeShapes.RECTANGLE:
					g.drawRect(-size/2, -size/2, size, size);
					break;
				case NodeShapes.TRIANGLE:
				case NodeShapes.DIAMOND:
				case NodeShapes.HEXAGON:
				case NodeShapes.OCTAGON:
				case NodeShapes.PARALLELOGRAM:
				case NodeShapes.V:
					var r:Rectangle = new Rectangle(-size/2, -size/2, size, size);
					var points:Array = NodeShapes.getDrawPoints(r, shape);
					Shapes.drawPolygon(g, points);
					break;
				case NodeShapes.ROUND_RECTANGLE:
					g.drawRoundRect(-size/2, -size/2, size, size, size/2, size/2);
					break;
				case NodeShapes.ELLIPSE:
				default:
					Shapes.drawCircle(g, size/2);
			}
			*/
		}
		
	}
}