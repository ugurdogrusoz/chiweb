package ivis.view
{
	import flare.vis.data.DataSprite;

	public interface IEdgeUI
	{
		/**
		 * Sets the line style of the edge.
		 * 
		 * @param ds	data sprite (the edge)
		 */
		function setLineStyle(ds:DataSprite):void;
		
		/**
		 * Draws the UI of the given data sprite with the help of the given 
		 * clipping points. The size of the clipping points array is assumed
		 * to be 2.
		 * 
		 * @param ds		data sprite (the edge)
		 * @param points	array of clipping points
		 */
		function draw(ds:DataSprite,
			points:Array):void;
	}
}