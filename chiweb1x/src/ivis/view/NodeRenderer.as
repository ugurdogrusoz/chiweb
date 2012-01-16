package ivis.view
{
	import flare.util.Shapes;
	import flare.vis.data.DataSprite;
	import flare.vis.data.render.ShapeRenderer;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	import ivis.model.Node;
	import ivis.view.ui.INodeUI;
	import ivis.view.ui.NodeUIManager;

	/**
	 * Renderer for simple (regular) and bend nodes.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class NodeRenderer extends ShapeRenderer
	{
		private static var _instance:NodeRenderer = new NodeRenderer();
		
		/**
		 * Singleton instance. 
		 */
		public static function get instance():NodeRenderer
		{
			return _instance;
		}
		
		public function NodeRenderer(defaultSize:Number = 1)
		{
			this.defaultSize = defaultSize;
		}
		
		public override function render(d:DataSprite):void
		{
			trace("[NodeRenderer.render] node: " + d.data.id + 
				", size: " + d.size + ", shape: " + d.shape);
			
			var lineAlpha:Number = d.lineAlpha;
			var fillAlpha:Number = d.fillAlpha;
			var fillColor:Number = d.fillColor;
			
			var g:Graphics = d.graphics;
			g.clear();
			
			var nodeUI:INodeUI = NodeUIManager.getUI(d.shape);
			
			// undefined ui, use default UI to render
			if (nodeUI == null)
			{
				trace ("[NodeRenderer.render]" + d.data.id +
					" has an unrecognized UI");
				
				// try to render with a default UI
				
				super.render(d);
				return;
				
				// TODO try to render with a default UI if shape cannot be rendered with the parent renderer
				// nodeUI = NodeUIManager.getUI(NodeUIManager.RECTANGLE);
			}
			
			if (d is Node &&
				(d as Node).isBendNode &&
				d.props.inheritColor)
			{
				fillAlpha = (d as Node).parentE.lineAlpha;
				fillColor = (d as Node).parentE.lineColor;
			}
			
			if (lineAlpha > 0 && d.lineWidth > 0)
			{
				nodeUI.setLineStyle(d);
			}
			
			// draw node if it is not %100 transparent
			if (fillAlpha > 0)
			{
				// using a bit mask to avoid transparency
				// when fillcolor is 0xffffffff.
				g.beginFill(0xffffff & fillColor, fillAlpha);
				nodeUI.draw(d);
				g.endFill();
			}
		}
		
		// TODO not used anymore..
		private function drawShape(s:Sprite,
			shape:String,
			size:Number,
			width:Number,
			height:Number):void
		{
			var g:Graphics = s.graphics;
			
			/*
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
			*/
			
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