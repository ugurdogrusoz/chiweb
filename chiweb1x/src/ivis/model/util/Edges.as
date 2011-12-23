package ivis.model.util
{
	import ivis.model.Edge;
	import ivis.model.Node;
	import ivis.util.GeneralUtils;

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
		 * Brings all segments and bendpoints of the given edge to front.
		 * 
		 * @param edge	edge sprite whose components are brougt to front
		 */
		public static function bringEdgeToFront(edge:Edge) : void
		{
			// bring edge to front
			GeneralUtils.bringToFront(edge);
			
			// bring every child component to the front
			
			for each (var bend:Node in edge.getBendNodes())
			{
				// bring bend point to front
				GeneralUtils.bringToFront(bend);
			}
			
			for each (var segment:Edge in edge.getSegments())
			{
				// bring segment edge to front
				GeneralUtils.bringToFront(segment);
			}
		}
		
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
		
		/**
		 * If the given edge is filtered out, returns true. If an edge is not
		 * filtered out, but either its source or target is filtered out,
		 * then the edge is also considered as filtered out. If an edge is a
		 * segment and its parent is filtered out, then the edge is also
		 * considered as filtered out.
		 * 
		 * @param edge	edge sprite to be checked
		 * @return		true if filtered out, false otherwise
		 */
		public static function isFiltered(edge:Edge):Boolean
		{
			var filtered:Boolean = edge.props.$filtered;
				
			if (edge.isSegment)
			{
				filtered = Edges.isFiltered(edge.parentE);
			}
			else
			{
				// if an edge is not filtered out, but either its target or its
				// source is filtered out, then the edge is also filtered out
				filtered = filtered ||
					Nodes.isFiltered(edge.source as Node) ||
					Nodes.isFiltered(edge.target as Node);
			}
			
			return filtered;
		}
	}
}