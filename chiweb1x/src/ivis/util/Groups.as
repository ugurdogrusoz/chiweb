package ivis.util
{
	import flare.vis.data.Data;

	/**
	 * A utility class to define constants for data groups.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class Groups
	{
		//------------------------ CONSTANTS -----------------------------------
		
		public static const ALL:String = "all";
		public static const NODES:String = Data.NODES;
		public static const EDGES:String = Data.EDGES;
		
		public static const COMPOUND_NODES:String = "compoundNodes";
		public static const BEND_NODES:String = "bendNodes";
		public static const SELECTED_NODES:String = "selectedNodes";
		public static const SELECTED_EDGES:String = "selectedEdges";
		public static const REGULAR_EDGES:String = "regularEdges";
		
		
		//-------------------------- CONSTRUCTOR -------------------------------
		
		public function Groups()
		{
			throw new Error("Groups is an abstract class.");
		}
		
		//------------------------- PUBLIC FUNCTIONS ---------------------------
		
		/**
		 * Check if the given group name is one of the default groups defined
		 * in this class. Returns true if a group with the given name already
		 * exists, returns false if it is available. 
		 * 
		 * @param group	name of the group to be checked
		 * @return		true if a group is default, false otherwise
		 */
		public static function isDefault(group:String):Boolean
		{
			var reserved:Boolean = false;
			
			if (group == Groups.NODES ||
				group == Groups.EDGES ||
				group == Groups.COMPOUND_NODES ||
				group == Groups.BEND_NODES ||
				group == Groups.SELECTED_NODES ||
				group == Groups.SELECTED_EDGES ||
				group == Groups.REGULAR_EDGES)
			{
				reserved = true;
			}
			
			return reserved;
		}
	}
}