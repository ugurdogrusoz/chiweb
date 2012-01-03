package util
{
	/**
	 * Utility class for constants used in sample application.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class Constants
	{
		//------------------------ CONSTANTS -----------------------------------
		
		/** Name for the gradient rectangle node UI & data group */
		public static const GRADIENT_RECT:String = "gradientRect";
		
		/** Name for the dashed triangle node UI & data group */
		public static const DASHED_TRIANGLE:String = "dashedTriangle";
		
		/** Name for the image node UI & data group */
		public static const IMAGE_NODE:String = "imageNode";
		
		/** Name for the dashed edge UI & data group */
		public static const DASHED_EDGE:String = "dashedEdge";
		
		/** Constants for action states. */
		public static const ADD_GRADIENT:String = "addGradient";
		public static const ADD_DASHED_TRI:String = "addDashedTriangle";
		public static const ADD_IMAGE_NODE:String = "addImageNode";
		public static const ADD_DASHED_EDGE:String = "addDashedEdge";
		
		public function Constants()
		{
			throw new Error("Constants is an abstract class.");
		}
	}
}