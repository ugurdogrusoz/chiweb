package ivis.util
{
	import flare.util.Shapes;
	
	import ivis.view.CircularNodeUI;
	import ivis.view.INodeUI;
	import ivis.view.RectangularNodeUI;
	import ivis.view.RoundRectNodeUI;

	/**
	 * Utility class for custom node UIs. In order to use an implementation of
	 * an INodeUI interface to render custom nodes, its singleton instance
	 * should be registered by invoking the registerUI function of this utiliy
	 * class.
	 * 
	 * 3 node UI instances are registered by default: RectangularNodeUI,
	 * RoundRectNodeUI, and CircularNodeUI.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class NodeUIs
	{
		//------------------------CONSTANTS-------------------------------------
		
		// default shapes provided by chiWeb
		public static const RECTANGLE:String = "rectangle";
		public static const ROUND_RECTANGLE:String = "roundrect";
		public static const CIRCLE:String = Shapes.CIRCLE;
		
		//------------------------VARIABLES-------------------------------------
		
		// shape object with the default shapes registered
		private static var _uiMap:Object = {
			rectangle: RectangularNodeUI.instance,
			roundrect: RoundRectNodeUI.instance,
			circle: CircularNodeUI.instance};
		
		//-----------------------CONSTRUCTOR------------------------------------
		
		public function NodeUIs()
		{
			throw new Error("NodeUIs is an abstract class.");
		}
		
		//-----------------------PUBLIC FUNCTIONS-------------------------------
		
		/**
		 * Registers the given node UI by adding its instance to the UI map
		 * with the provided name.
		 * 
		 * @param name		name of the UI (used as a map key)
		 * @param nodeUI	node UI instance corresponding to the given name
		 */
		public static function registerUI(name:String,
			nodeUI:INodeUI):void
		{
			_uiMap[name] = nodeUI;
		}
		
		/**
		 * Retrieves the node UI instance corresponding to the given name.
		 * 
		 * @param name	name of the UI
		 * @return		UI instance corresponding to the given name
		 */
		public static function getUI(name:String):INodeUI
		{
			return _uiMap[name];
		}
	}
}