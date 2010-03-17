/**
* Author: Ebrahim Rajabzadeh
*
* Copyright: i-Vis Research Group, Bilkent University, 2009 - present 
*/

package ivis.events
{
	import flash.events.Event;
	
	import ivis.Node;

	public class NodeRemoved extends Event
	{
		public static const TYPE: String = "nodeRemoved";
		private var _node: Node;
		
		public function NodeRemoved(node: Node)
		{
			super(TYPE, false, false);
			this._node = node;
		}
		
		public override function clone(): Event
		{
			return new NodeRemoved(_node);
		}
		
		public function get node(): Node
		{
			return _node;
		}
	}
}