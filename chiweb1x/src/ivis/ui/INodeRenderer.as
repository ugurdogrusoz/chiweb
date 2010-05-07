package ivis.ui
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	public interface INodeRenderer
	{
		function draw(g: Graphics): void;
		function intersection(p: Point): Point;
	}
}