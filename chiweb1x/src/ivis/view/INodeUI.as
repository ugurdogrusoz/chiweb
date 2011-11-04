package ivis.view
{
	import flare.vis.data.DataSprite;
	
	import flash.geom.Point;
	
	import ivis.model.Node;

	/**
	 * Interface for defining custom UIs for nodes. This interface is designed
	 * to be used within Node and Edge renderers to provide a mechanism for
	 * drawing of custom node UIs.
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
		 * @param defaultSize	default size value of the NodeRenderer
		 */
		function draw(ds:DataSprite,
			defaultSize:Number):void;
		
		
		/**
		 * Calculates the intersection point of the given node and the line
		 * specified by the points p1 and p2. If no intersection point is found, 
		 * then the center of the given node is returned as an intersection 
		 * point.
		 * 
		 * @param node	node with an arbitrary shape
		 * @param p1	start point of the line
		 * @param p2	end point of the line
		 * @return		intersection point 
		 */
		function intersection(node:Node,
			p1:Point,
			p2:Point):Point;
		
	}
}