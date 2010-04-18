package ivis.model
{
	import __AS3__.vec.Vector;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * 
	 * @author Ebrahim Rajabzadeh 
	 */
	public class Edge extends GraphObject
	{
		private var _source: Node;
		private var _target: Node;
		private var _bends: Vector.<Point>;
		 
		/**
		 * 
		 * @param id
		 * @param source
		 * @param target
		 * @param data
		 */
		public function Edge(id:String, source: Node = null, target: Node = null, data:Object = null)
		{
			super(id, x, y, data);
			
			this._source = source;
			this._target = target;
			this._bends = new Vector.<Point>;
		}
		
		//
		// getters and setters
		//
		
		/**
		 * 
		 * @return 
		 */
		public function get source(): Node
		{
			return this._source;
		}
		
		/**
		 * 
		 * @param node
		 */
		public function set soruce(node: Node): void
		{
			this._source = node;
		}
		
		/**
		 * 
		 * @return 
		 */
		public function get target(): Node
		{
			return this._target;
		}
		
		/**
		 * 
		 * @param node
		 */
		public function set target(node: Node): void
		{
			this._target = node;
		}
		
		//
		// public methods
		//
		
		/**
		 * 
		 * @param p
		 */
		public function addBend(p: Point): void
		{
			this._bends.push(p);
		}
		
		/**
		 * 
		 * @param p
		 * @return 
		 */
		public function removeBend(p: Point): Boolean
		{
			var index: int;
			
			index = this.findBend(p);
			if(index >= 0) {
				this._bends.splice(index, 1)
				return true;
			}
			
			return false; 
		}
		
		//
		// private methods
		//
		
		/**
		 * 
		 * @param p
		 * @return 
		 */
		private function findBend(p: Point): int
		{
			var result: int = -1;
			
			this._bends.some(
				function (item: Point, index: int, vector: Vector.<Point>): Boolean {
					if(item.x != p.x || item.y != p.y)
						return false;
						
					result = index;
					return true;
				}
			);
			
			return result;
		}
		
		//
		// overriden public methods
		//

		/**
		 * 
		 * @return 
		 */
		override public function bounds(): Rectangle
		{
			var xMin: Number = Math.min(source.x, target.x);
			var xMax: Number = Math.max(source.x, target.x);
			var yMin: Number = Math.min(source.y, target.y);
			var yMax: Number = Math.max(source.y, target.y);
			
			// TODO: include bend points
			return new Rectangle(xMin, yMin, xMax - xMin, yMax - yMin);
		}
		
	}
}