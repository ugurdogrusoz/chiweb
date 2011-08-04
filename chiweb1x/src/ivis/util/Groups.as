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
		//-------------------------CONSTANTS------------------------------------
		
		public static const NODES:String = Data.NODES;
		public static const EDGES:String = Data.EDGES;
		
		public static const COMPOUND_NODES:String = "compoundNodes";
		public static const BEND_NODES:String = "bendNodes";
		public static const SELECTED_NODES:String = "selectedNodes";
		public static const SELECTED_EDGES:String = "selectedEdges";
		public static const REGULAR_EDGES:String = "regularEdges";
		
		
		//-----------------------CONSTRUCTOR------------------------------------
		
		public function Groups()
		{
			throw new Error("NodeShapes is an abstract class.");
		}
	}
}