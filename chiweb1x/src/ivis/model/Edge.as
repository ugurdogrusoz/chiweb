package ivis.model
{
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	
	import ivis.view.VisualStyle;

	/**
	 * A DataSprite that represents an Edge with its model and view. This class
	 * represents both regular edges and segment edges.
	 * 
	 * A regular edge is an edge between two nodes (either regular node or a
	 * compound node). A regular edge can have bend nodes (bend points)
	 * and edge segments.
	 * 
	 * A segment edge, which is a child of a regular edge, is an edge between 
	 * two bend nodes or between one bend node and one actual node (this actual 
	 * node can be either the source or the target node of the parent edge).
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class Edge extends EdgeSprite implements IStyleAttachable
	{
		protected var _styleMap:Object;
		
		private var _parentE:Edge;
		private var _bendNodes:Object;
		private var _segments:Object;
		private var _bendCount:int;
		
		// -------------------------- ACCESSORS --------------------------------
				
		/**
		 * Parent edge of this edge. If this edge is a segment edge its parent
		 * should be an actual edge between two nodes. A segment edge should
		 * not be a parent of any other edge. If this edge is an actual edge
		 * its parent should always be null.
		 */
		public function get parentE():Edge
		{
			return _parentE;
		}
		
		public function set parentE(value:Edge):void
		{
			_parentE = value;
		}
		
		/**
		 * Indicates whether this edge is a segment edge or not.
		 */
		public function get isSegment():Boolean
		{
			return (this.parentE != null);
		}
		
		// -------------------------- CONSTRUCTOR ------------------------------
		
		/**
		 * Creates an edge between the given source and target nodes
		 * 
		 * @param source	source node of the edge
		 * @param target	target node of the edge
		 * @param directed	indicated whether this edge is directed or not
		 */
		public function Edge(source:Node = null,
			target:Node = null,
			directed:Boolean = false)
		{
			super(source, target, directed);
			_parentE = null;
			_bendNodes = new Object();
			_segments = new Object();
			_bendCount = 0;
			_styleMap = new Object();
		}
		
		// -------------------------- PUBLIC FUNCTIONS -------------------------
		
		/**
		 * Adds a bend node (bend point) to the bend nodes list of this edge.
		 * This function should only be invoked if this edge is an actual edge.
		 * Behavior of this function is unpredictable if it is invoked on
		 * a segment edge.
		 * 
		 * @param node	bend node to be added
		 */
		public function addBendNode(node:Node):void
		{
			// TODO is it possible to check if the given node is a bendnode?
			
			this._bendNodes[node.data.id] = node;
			this._bendCount++;
			node.parentE = this;
		}
		
		/**
		 * Removes the specified bend node from the bend nodes list of this
		 * edge. If the node is not in the list, then no action will be
		 * performed.
		 * 
		 * @param node	ben node to be removed
		 */
		public function removeBendNode(node:Node):void
		{			
			if (this._bendNodes[node.data.id] != null)
			{
				delete this._bendNodes[node.data.id];
				this._bendCount--;
			}
		}
		
		/**
		 * Adds a segment edge to the segments list of this edge. This function 
		 * should only be invoked if this edge is an actual edge. Behavior of
		 * this function is unpredictable if it is invoked on a segment edge.
		 * 
		 * @param edge	segment edge to be added
		 */
		public function addSegment(edge:Edge):void
		{
			// TODO is it possible to check if the given edge is a segment?
			
			this._segments[edge.data.id] = edge;
			edge.parentE = this;
		}
		
		/**
		 * Removes the specified segment edge from the segments list of this
		 * edge. If the edge is not in the list, then no action will be
		 * performed.
		 * 
		 * @param edge	segment edge to be removed
		 */
		public function removeSegment(edge:Edge):void
		{
			delete this._segments[edge.data.id];
		}
		
		/**
		 * Returns the segments of this edge as an array.
		 * 
		 * @return	all segments as an array
		 */
		public function getSegments():Array
		{
			var edgeList:Array = new Array();
			
			if (this._segments != null)
			{
				for each (var edge:Edge in this._segments)
				{
					edgeList.push(edge);
				}
			}
			
			return edgeList;
		}
		
		/**
		 * Returns the bend nodes (bend points) of this edge as an array.
		 * 
		 * @return	all bend nodes as an array
		 */
		public function getBendNodes():Array
		{
			var nodeList:Array = new Array();
			
			if (this._bendNodes != null)
			{
				for each (var node:Node in this._bendNodes)
				{
					nodeList.push(node);
				}
			}
			
			return nodeList;
		}
		
		/**
		 * Check if this edge has bend points. This function should always
		 * return false for a segment edge.
		 * 
		 * @return	true if has bend points, false otherwise 
		 */
		public function hasBendPoints():Boolean
		{
			if (this._bendCount > 0)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		public override function toString():String
		{
			var parentEdge:String = "N/A";
			var segments:String = "[";
			var bendNodes:String = "["
			
			if (this.parentE != null)
			{
				parentEdge = this.parentE.data.id;
			}
			
			for each (var bend:Node in this.getBendNodes())
			{
				bendNodes += " " + bend.data.id; 
			}
			
			bendNodes += "]";
			
			for each (var segment:Edge in this.getSegments())
			{
				segments += " " + segment.data.id; 
			}
			
			segments += "]"
			
			var str:String = "id:" + this.data.id +				
				" source:" + this.source.data.id +
				" target:" + this.target.data.id +
				" parentE:" + parentEdge +
				" bends:" + bendNodes +
				" segments:" + segments;
			
			
			return str;
		}

		// TODO may need to modify methods below, because of segments... 
		
		public function attachStyle(name:String,
			style:VisualStyle) : void
		{
			this._styleMap[name] = style;
		}
		
		public function detachStyle(name:String) : void
		{
			this._styleMap[name] = null;
		}
		
		public function getStyle(name:String) : VisualStyle
		{
			return _styleMap[name]; 
		}
		
		public function get styleNames() : Array
		{
			var names:Array = new Array();
			
			for (var key:String in this._styleMap)
			{
				names.push(key);
			}
			
			return names;
		}
	}
}