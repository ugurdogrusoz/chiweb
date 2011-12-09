package ivis.view
{
	import flare.vis.data.DataSprite;

	/**
	 * Interface for defining custom UIs for edges. This interface is designed
	 * to be used within Edge renderer to provide a mechanism for drawing 
	 * custom edge UIs.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public interface IEdgeUI
	{
		/**
		 * Sets the line style of the edge.
		 * 
		 * @param ds	data sprite (the edge)
		 */
		function setLineStyle(ds:DataSprite):void;
		
		/**
		 * Draws the UI of the given data sprite. The data sprite is assumed
		 * to be an Edge instance and it contains props.$startPoint and 
		 * props.$endPoint as its two clipping points. 
		 * 
		 * @param ds		data sprite (the edge)
		 */
		function draw(ds:DataSprite):void;
	}
}