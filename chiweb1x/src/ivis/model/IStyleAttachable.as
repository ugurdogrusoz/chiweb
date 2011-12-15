package ivis.model
{

	/**
	 * Interface designed for data sprites (nodes and edges) to manage
	 * visual styles.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public interface IStyleAttachable
	{
		/**
		 * Array of all visual styles attached to this element.
		 */
		function get allStyles() : Array;
		
		/**
		 * Array of all group styles attached to this element.
		 */
		function get groupStyles() : Array;
		
		/**
		 * Attaches the given visual style to this element for
		 * the specified style name.
		 * 
		 * @param name	name of the style
		 * @param style	visual style to be attached
		 */
		function attachStyle(name:String, style:Style) : void;
		
		/**
		 * Detaches the visual style attached to this element for
		 * the given style name.
		 * 
		 * @param name	name of the style to detach
		 */
		function detachStyle(name:String) : void;
		
		/**
		 * Retrieves the visual style attached to this element for
		 * the given style name.
		 * 
		 * @param name	name of style to be retrieved
		 * @return		visual style for the given name
		 */
		function getStyle(name:String) : Style;
	}
}