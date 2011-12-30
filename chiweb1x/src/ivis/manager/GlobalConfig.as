package ivis.manager
{
	/**
	 * Configuration class for the global settings of the application.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class GlobalConfig
	{
		/** Line color of the enclosing selection rectangle. */
		public static const ENCLOSING_LINE_COLOR:String = "enclosingLineColor";
		
		/** Line alpha of the enclosing selection rectangle. */
		public static const ENCLOSING_LINE_ALPHA:String = "enclosingLineAlpha";
		
		/** Line width of the enclosing selection rectangle. */
		public static const ENCLOSING_LINE_WIDTH:String = "enclosingLineWidth";
		
		/** Fill color of the enclosing selection rectangle. */
		public static const ENCLOSING_FILL_COLOR:String = "enclosingFillColor";
		
		/** Fill alpha of the enclosing selection rectangle. */
		public static const ENCLOSING_FILL_ALPHA:String = "enclosingFillAlpha";
		
		/** Key for multiple selection. */
		public static const SELECTION_KEY:String = "selectionKey";
		
		/** Background color of the canvas. */
		public static const BACKGROUND_COLOR:String = "backgroundColor";
		
		/** Increase or decrease in the zoom scale */
		public static const ZOOM_SCALE:String = "zoomScalePercent";
		
		// TODO canvasSize, toolTipDelay, cursorType for specific events
		
		/**
		 * Map for attaching configuration values.
		 */
		protected var _settings:Object;
		
		//
		
		public function GlobalConfig()
		{
			// initialize settings object
			this._settings = new Object();
			
			// initialize default settings
			this.addConfig(GlobalConfig.ENCLOSING_LINE_COLOR, 0x8888FF);
			this.addConfig(GlobalConfig.ENCLOSING_LINE_ALPHA, 0.4);
			this.addConfig(GlobalConfig.ENCLOSING_LINE_WIDTH, 1);
			this.addConfig(GlobalConfig.ENCLOSING_FILL_COLOR, 0x8888FF);
			this.addConfig(GlobalConfig.ENCLOSING_FILL_ALPHA, 0.2);
			this.addConfig(GlobalConfig.SELECTION_KEY, "ctrlKey");
			this.addConfig(GlobalConfig.BACKGROUND_COLOR, 0xfff9f9f9);
			this.addConfig(GlobalConfig.ZOOM_SCALE, 0.8);
		}
		
		/**
		 * Adds a new configuration to the settings map for the given name and 
		 * value pair. If a setting with the given name already exists, it is
		 * overwritten.
		 *  
		 * @param name	configuration name
		 * @param value	configuration value
		 */
		public function addConfig(name:String, value:*) : void
		{
			// add configuration to the map
			this._settings[name] = value;
			
			// TODO dispatch an Event?
		}
		
		/**
		 * Removes the configuration having the given name from the map. 
		 *  
		 * @param name	name of the config to be removed
		 */
		public function removeConfig(name:String) : void
		{
			// remove configuration from the map
			delete this._settings[name];
			
			// TODO dispatch an Event?
		}
		
		/**
		 * Gets the value of the config for the specified name.
		 */
		public function getConfig(name:String) : *
		{
			return this._settings[name];
		}
	}
}