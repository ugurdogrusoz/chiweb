package ivis.util
{
	public class NodeShapes
	{
		//------------------------CONSTANTS-------------------------------------
		
		public static const RECTANGLE:String = "RECTANGLE";
		public static const ROUND_RECTANGLE:String = "ROUNDRECT";
		
		
		//-----------------------CONSTRUCTOR------------------------------------
		
		public function NodeShapes()
		{
			throw new Error("NodeShapes is an abstract class.");
		}
	}
}