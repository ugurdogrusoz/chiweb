package ivis.ui
{
	import flash.events.MouseEvent;
	
	public interface IMouseAdapter
	{
		function onMouseDown(e: MouseEvent): void;
		function onMouseMove(e: MouseEvent): void;
		function onMouseUp(e: MouseEvent): void;
		function get component(): Component;
		function set component(c: Component): void;
	}
}