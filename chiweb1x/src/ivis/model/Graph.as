package ivis.model
{
	import __AS3__.vec.Vector;
	
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;

	/**
	 * 
	 * @author Ebrahim Rajabzadeh
	 */
	public class Graph extends EventDispatcher
	{
		/**
		 * 
		 * @default 
		 */
		private var _nodes: Vector.<Node>;
		
		/**
		 * 
		 * @default 
		 */
		private var _edges: Vector.<Edge>;
		
		/**
		 * 
		 * @default 
		 */
		private var _options: GraphOptions;
		
		/**
		 * 
		 */
		public function Graph()
		{
			super(null);
			
			this._nodes = new Vector.<Node>;
			this._edges = new Vector.<Edge>;
			this._options = new GraphOptions;
		}
		
		// getters and setters
		
		/**
		 * 
		 * @return 
		 */
		public function get options(): GraphOptions
		{
			return this._options;
		}
		
		/**
		 * 
		 * @param o
		 */
		public function set options(o: GraphOptions): void
		{
			this._options = o;
		}
		
		//
		// public methods
		//
		
		/**
		 * 
		 * @param node
		 */
		public function addNode(node: Node): void
		{
			this._nodes.push(node);
		}
		
		/**
		 * 
		 * @param node
		 * @return 
		 */
		public function removeNode(node: Node): Boolean
		{
			var index: int;
			
			index = this._nodes.indexOf(node);
			
			if(index >= 0) {
				this._nodes.splice(index, 1);
				return true;
			}
			
			return false;
		}
		
		/**
		 * 
		 * @param edge
		 */
		public function addEdge(edge: Edge): void
		{
			this._edges.push(edge);
		}
		
		/**
		 * 
		 * @param edge
		 * @return 
		 */
		public function removeEdge(edge: Edge): Boolean
		{
			var index: int;
			
			index = this._edges.indexOf(edge);
			
			if(index >= 0) {
				this._edges.splice(index, 1);
				return true;
			}
			
			return false;
		}
		
		/**
		 * 
		 * @return 
		 */
		public function bounds(): Rectangle
		{
			var result: Rectangle = new Rectangle;
			
			this._nodes.forEach(
				function (item: Node, index: int, v: Vector.<Node>): Boolean {
					result = result.union(item.bounds());
					return true;
				}
			);
			
			this._edges.forEach(
				function (item: Edge, index: int, v: Vector.<Edge>): Boolean {
					result = result.union(item.bounds());
					return true;
				}
			);
			
			return result;
		}
	}
}