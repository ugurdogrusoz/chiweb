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
		public function Edge(id:String = null, source: Node = null, target: Node = null, data:Object = null)
		{
			super(id, data);
			
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
		
		//
		// private methods
		//
		
		
	}
}