package ivis.util
{
	import ivis.model.Edge;
	import ivis.model.Node;

	/**
	 * Utility class for nodes.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class Edges
	{
		//-------------------------CONSTRUCTOR----------------------------------
		
		public function Edges()
		{
			throw new Error("Edges is an abstract class.");
		}
		
		//-----------------------PUBLIC FUNCTIONS-------------------------------
		
		/**
		 * Finds and returns a central edge segment of the given actual edge.
		 * A central edge segment is a segment which is as far as possible
		 * to both the source and the target node of the given actual edge.
		 *
		 * If the given edge does not contain any segments, or the edge itself 
		 * is a segment edge, then the given edge is returned immediately.
		 * 
		 * @param edge	an edge 
		 * @return		an edge segment nearest to the center of the edge
		 */
		public static function centralSegment(edge:Edge):Edge
		{
			// central segment
			var central:Edge;
			
			if (!edge.isSegment &&
				edge.hasBendPoints())
			{
				var segmentCount:uint = edge.getSegments().length;
				var count:uint = 1;
				
				// first, find the segment adjacent to the source
				var segment:Edge = Edges.segmentAdjacentToSource(edge);
				
				var bendNode:Node;
				
				// traverse segments until a central one
				
				while (count < segmentCount / 2)
				{
					// get the next bend node
					bendNode = segment.target as Node;
					
					// get the next segment
					for each (var incident:Edge in
						Nodes.incidentEdges(bendNode))
					{
						if (incident != segment)
						{
							segment = incident;
							break;
						}
					}
					
					count++;
				}
				
				// set the last segment as the central segment 
				central = segment;
			}
			else
			{
				// simply set the central segment as the given edge
				central = edge;
			}
			
			// return found segment
			return central;
		}
		
		/**
		 * Finds and returns a central bend point of the given actual edge. 
		 * A central bend point is a bend point which is as far as possible
		 * to both the source and the target node of the given actual edge.
		 *
		 * If the given edge does not contain any segments, or the edge itself 
		 * is a segment edge, then the return value will be null.
		 * 
		 * @param edge	an edge
		 * @return		a bend point nearest to the center of the edge
		 */
		public static function centralBendPoint(edge:Edge):Node
		{
			// central bend node
			var central:Node = null;
			
			if (!edge.isSegment &&
				edge.hasBendPoints())
			{
				var bendCount:uint = edge.getBendNodes().length;
				var count:int = 0;
				
				// first, find the segment adjacent to the source
				var segment:Edge = Edges.segmentAdjacentToSource(edge);
				
				var bendNode:Node;
				
				// traverse segments until a central one
				
				while (count < bendCount / 2)
				{
					// get the next bend node
					bendNode = segment.target as Node;
					
					// get the next segment
					for each (var incident:Edge in
						Nodes.incidentEdges(bendNode))
					{
						// since a bend node has exactly two incident edges,
						// one is the current segment, other is the next
						if (incident != segment)
						{
							segment = incident;
							break;
						}
					}
					
					count++;
				}
				
				// set the last segment as the central segment 
				central = bendNode;
			}
			
			// return found segment
			return central;
		}
		
		/**
		 * Finds the segment edge (among the segments of the given edge) that is
		 * adjacent to the source node of the edge. If the edge does not contain
		 * any segments, then the edge itself is returned.
		 * 
		 * @param edge	an edge
		 * @return		segment edge adjacent to the source node
		 */
		public static function segmentAdjacentToSource(edge:Edge):Edge
		{
			var segment:Edge = edge;
			
			// find the segment adjacent to the source node
			for each (segment in edge.getSegments())
			{
				if (segment.source == edge.source)
				{
					break;
				}
			}
			
			return segment;
		}
		
		/**
		 * Finds the segment edge (among the segments of the given edge) that is
		 * adjacent to the target node of the edge. If the edge does not contain
		 * any segments, then the edge itself is returned.
		 * 
		 * @param edge	an edge
		 * @return		segment edge adjacent to the target node
		 */
		public static function segmentAdjacentToTarget(edge:Edge):Edge
		{
			var segment:Edge = edge;
			
			// find the segment adjacent to the target node
			for each (segment in edge.getSegments())
			{
				if (segment.target == edge.target)
				{
					break;
				}
			}
			
			return segment;
		}
	}
}