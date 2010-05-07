package ivis.model
{
	import __AS3__.vec.Vector;
	
	import flash.geom.Rectangle;
	
	/**
	 * 
	 * @author Ebrahim Rajabzadeh
	 */
	public class CompoundNode extends Node
	{
		
		/**
		 * 
		 * @default 
		 */
		private var _nodes: Vector.<Node>;
		
		/**
		 * 
		 * @param id
		 * @param data
		 */
		public function CompoundNode(id:String = null, data:Object=null)
		{
			super(id, data);
			
			this._nodes = new Vector.<Node>;
		}
		
		//
		// getters and setters
		//
		
		
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
		
		//
		// overriden public methods
		//

		/**
		 * 
		 * @return 
		 */
		override public function isCompound(): Boolean
		{
			return true;
		}
		
	}
}
