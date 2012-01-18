package ivis.view.ui
{
	import flare.vis.data.DataSprite;
	
	import flash.geom.Point;
	
	import ivis.model.Edge;
	import ivis.model.Node;

	/**
	 * Interface for defining custom UIs for nodes. This interface is designed
	 * to be used within Node and Edge renderers to provide a mechanism for
	 * drawing custom node UIs.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public interface INodeUI
	{
		/**
		 * Sets the line style of the node.
		 * 
		 * @param ds	data sprite (the node)
		 */
		function setLineStyle(ds:DataSprite):void;
		
		/**
		 * Draws the UI of the given data sprite.
		 * 
		 * @param ds			data sprite (the node)
		 */
		function draw(ds:DataSprite):void;
		
		
		/**
		 * Calculates the intersection point of the given node and the given
		 * edge. If no intersection point is found, then the center of 
		 * the given node is returned as an intersection point.
		 * 
		 * @param node	node with an arbitrary shape
		 * @param edge	edge whose source or target is the given node
		 * @return		intersection point
		 */
		function intersection(node:Node,
			edge:Edge):Point;
		
	}
}