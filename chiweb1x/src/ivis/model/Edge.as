package ivis.model
{
	import flare.vis.data.EdgeSprite;
	
	import ivis.event.StyleChangeEvent;
	import ivis.model.util.Styles;

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
		/**
		 * Manager for visual styles of this edge. 
		 */
		protected var _styleManager:StyleManager;
		
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
			_styleManager = new StyleManager();
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
			
			// also attach parent group styles to the segment
			for each (var style:Style in this.groupStyles)
			{
				edge.attachStyle(this._styleManager.getStyleName(style), style);
			}
			
			// TODO also attach specific style?
			edge.attachStyle(Styles.SPECIFIC_STYLE,
				this.getStyle(Styles.SPECIFIC_STYLE));
				
			Styles.reApplyStyles(edge);
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
		
		/** @inheritDoc */
		public function getStyle(name:String) : Style
		{
			return this._styleManager.getStyle(name);
		}
		
		/** @inheritDoc */
		public function get allStyles() : Array
		{
			return this._styleManager.allStyles;
		}
		
		/** @inheritDoc */
		public function get groupStyles() : Array
		{
			return this._styleManager.groupStyles;
		}
		
		/** @inheritDoc */
		public function attachStyle(name:String,
									style:Style) : void
		{
			if (style != null &&
				name != null)
			{
				// add style to the style set
				this._styleManager.add(name, style);
				
				// register listener for StyleChangeEvents with a high priority
				
				style.addEventListener(StyleChangeEvent.ADDED_STYLE_PROP,
					onStyleChange,
					false,
					StyleChangeEvent.HIGH_PRIORITY);
				
				style.addEventListener(StyleChangeEvent.REMOVED_STYLE_PROP,
					onStyleChange,
					false,
					StyleChangeEvent.HIGH_PRIORITY);
				
				// also attach styles to the child segments
				if (this.hasBendPoints())
				{
					for each (var segment:Edge in this.getSegments())
					{
						segment.attachStyle(name, style);
					}
				}
			}
			
		}
		
		/** @inheritDoc */
		public function detachStyle(name:String) : void
		{
			var style:Style = this._styleManager.getStyle(name); 
			
			if (style != null)
			{
				// remove registered listeners
				
				style.removeEventListener(StyleChangeEvent.ADDED_STYLE_PROP,
					onStyleChange);
				
				style.removeEventListener(StyleChangeEvent.REMOVED_STYLE_PROP,
					onStyleChange);
				
				// remove style from the style set
				this._styleManager.remove(name);
				
				// also detach styles from the child segments
				if (this.hasBendPoints())
				{
					for each (var segment:Edge in this.getSegments())
					{
						segment.detachStyle(name);
					}
				}
			}
		}
		
		//----------------------- PROTECTED FUNCTIONS --------------------------
		
		/**
		 * This function is designed as a (high priority) listener for
		 * the actions StyleChangeEvent.ADDED_STYLE_PROP and 
		 * StyleChangeEvent.REMOVED_STYLE_PROP.
		 * 
		 * This function is called whenever a property of a style (attached to 
		 * this edge) is changed, and refreshes visual styles of this edge.
		 *  
		 * @param event	StyleChangeEvent triggered the action
		 */
		protected function onStyleChange(event:StyleChangeEvent) : void
		{
			var style:Style = event.info.style;
			
			Styles.reApplyStyles(this, false);
			
			/*
			if (event.type == StyleChangeEvent.ADDED_STYLE_PROP)
			{
				// re-apply style on property change
				Styles.applyNewStyle(this, style);
			}
			else // if (event.type == StyleChangeEvent.REMOVED_STYLE_PROP)
			{
				// re-apply visual styles
				Styles.reApplyStyles(this);
			}
			*/
		}
	}
}