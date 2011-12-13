package ivis.model
{
	import ivis.view.VisualStyle;

	/**
	 * Interface designed for data sprites (nodes and edges) to manage
	 * visual styles.
	 */
	public interface IStyleAttachable
	{
		/**
		 * Returns names of the visual styles attached to this element.
		 * 
		 * @return name of the visual styles as an array
		 */
		function get styleNames() : Array;
		
		/**
		 * Attach the given visual style for the specified name.
		 * 
		 * @param name	name of the style
		 * @param style	visual style to be attached
		 */
		function attachStyle(name:String, style:VisualStyle) : void;
		
		/**
		 * Detaches the visual style for the given style name.
		 * 
		 * @param name	name of the style to detach
		 */
		function detachStyle(name:String) : void;
		
		/**
		 * Retrieves the style for the given name.
		 * 
		 * @param name	name of style to be retrieved
		 * @return		visual style for the given name
		 */
		function getStyle(name:String) : VisualStyle;
	}
}