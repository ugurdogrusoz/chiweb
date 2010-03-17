/**
* Author: Ebrahim Rajabzadeh
*
* Copyright: i-Vis Research Group, Bilkent University, 2009 - present 
*/

package ivis.events
{
	import flash.events.Event;
	
	import ivis.Edge;

	public class EdgeRemoved extends Event
	{
		public static const TYPE: String = "edgeRemoved";
		private var _edge: Edge;
		
		public function EdgeRemoved(edge: Edge)
		{
			super(TYPE, false, false);
			this._edge = edge;
		}
		
		public override function clone(): Event
		{
			return new EdgeRemoved(_edge);
		}
		
		public function get edge(): Edge
		{
			return _edge;
		}
	}
}