package ivis.model
{
	import flash.geom.Rectangle;
	
	import ivis.model.events.HeightChangeEvent;
	import ivis.model.events.WidthChangeEvent;
	
	/**
	 * 
	 * @author Ebrahim Rajabzadeh
	 */
	public class Node extends GraphObject
	{
		private var _clusterId: uint;
		private var _parent: CompoundNode;

		/**
		 * 
		 * @param id
		 * @param data
		 */
		public function Node(id:String = null, data:Object=null)
		{
			super(id, data);
			
			this._parent = null;
		}

		//
		// getters and setters
		//
		
		/**
		 * 
		 * @return 
		 */
		public function get clusterId(): uint
		{
			return this._clusterId;
		}
		
		//
		// public methods
		//
		
		/**
		 * 
		 * @return 
		 */
		public function isCompound(): Boolean
		{
			return false;
		}
	}
}