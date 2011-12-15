package ivis.view.ui
{	
	import ivis.model.Edge;

	/**
	 * Interface for defining custom arrow UIs for edges. This interface is
	 * designed to be used within Edge renderer to provide a mechanism for 
	 * drawing custom source and target arrows for an edge.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public interface IArrowUI
	{
		/**
		 * Draws an arrow to the source side (clipping point on the source node)
		 * of the edge. Assuming that points[0] is the source side clipping
		 * point and points[1] is the target side clipping point. This function
		 * returns the new clipping points array after drawing the arrow.
		 * 
		 * @param edge		edge on which the source arrow will be drawn
		 * @param points	clipping points of the given edge
		 * @return			new clipping points array
		 */
		function drawSourceArrow(edge:Edge,
			points:Array):Array;
		
		
		/**
		 * Draws an arrow to the target side (clipping point on the target node)
		 * of the edge. Assuming that points[0] is the source side clipping
		 * point and points[1] is the target side clipping point. This function
		 * returns the new clipping points array after drawing the arrow.
		 * 
		 * @param edge		edge on which the target arrow will be drawn
		 * @param points	clipping points of the given edge
		 * @return			new clipping points array
		 */
		function drawTargetArrow(edge:Edge,
			points:Array):Array;
	}
}