package ivis.view.ui
{
	
	/**
	 * Manager class for custom arrow UIs. In order to use an implementation of
	 * an IArrowUI interface to render custom arrows, its singleton instance
	 * should be registered by invoking the registerUI function of this manager
	 * class.
	 * 
	 * SimpleArrowUI instance is registered by default.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class ArrowUIManager
	{
		//------------------------CONSTANTS-------------------------------------
		
		// default arrow provided by chiWeb
		public static const SIMPLE_ARROW:String = "simpleArrow";
		
		//------------------------VARIABLES-------------------------------------
		
		// shape object with the default shape registered
		private static var _uiMap:Object = {
			simpleArrow: SimpleArrowUI.instance};
		
		//-----------------------CONSTRUCTOR------------------------------------
		
		public function ArrowUIManager()
		{
			throw new Error("ArrowUIManager is an abstract class.");
		}
		
		//-----------------------PUBLIC FUNCTIONS-------------------------------
		
		/**
		 * Registers the given arrow UI by adding its instance to the UI map
		 * with the provided name.
		 * 
		 * @param name		name of the UI (used as a map key)
		 * @param edgeUI	arrow UI instance corresponding to the given name
		 */
		public static function registerUI(name:String,
			arrowUI:IArrowUI):void
		{
			_uiMap[name] = arrowUI;
		}
		
		/**
		 * Unregisters the given arrow UI by removing corresponding instance
		 * from the UI map.
		 * 
		 * @param name		name of the UI (used as a map key)
		 */
		public static function unregisterUI(name:String):IArrowUI
		{
			var ui:IArrowUI = _uiMap[name];
			
			delete _uiMap[name];
			
			return ui;
		}
		
		/**
		 * Retrieves the arrow UI instance corresponding to the given name.
		 * 
		 * @param name	name of the UI
		 * @return		UI instance corresponding to the given name
		 */
		public static function getUI(name:String):IArrowUI
		{
			return _uiMap[name];
		}
	}
}