package ivis.layout
{
	import ivis.ui.GraphComponent;
	
	public interface ILayoutService
	{
		function layout(callback: Function): void;
		function get options(): Object;
		function set options(o: Object): void;
		function get URL(): String;
		function set URL(url: String): void;
		function get graph(): GraphComponent;
		function set graph(g: GraphComponent): void;
	}
}