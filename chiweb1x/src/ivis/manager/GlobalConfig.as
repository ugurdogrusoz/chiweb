package ivis.manager
{
	import flash.events.EventDispatcher;
	
	import ivis.event.StyleChangeEvent;

	/**
	 * Configuration class for the global settings of the application.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class GlobalConfig extends EventDispatcher
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
		public static const ZOOM_SCALE:String = "zoomScale";
		
		// TODO canvasSize, toolTipDelay
		
		/**
		 * Map for attaching configuration values.
		 */
		protected var _settings:Object;
		
		//----------------------------- ACCESSORS ------------------------------
		
		/**
		 * Names of all config parameters as an array.
		 */
		public function get configNames():Array
		{
			var names:Array = new Array();
			
			for (var name:String in this._settings)
			{
				names.push(name);
			}
			
			return names;
		}
		
		//------------------------- CONSTRUCTOR --------------------------------
		
		public function GlobalConfig(settings:Object = null)
		{
			if (settings == null)
			{
				// initialize default settings map
				
				this._settings = {enclosingLineColor: 0x8888FF,
					enclosingLineAlpha: 0.4,
					enclosingLineWidth: 1,
					enclosingFillColor: 0x8888FF,
					enclosingFillAlpha: 0.2,
					selectionKey: "ctrlKey",
					backgroundColor: 0xFFF9F9F9, // TODO different default bg color? 
					zoomScale: 0.8};
			}
			else
			{
				this._settings = settings;
			}
		}
		
		//------------------------ PUBLIC FUNCTIONS ----------------------------
		
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
			
			// dispatch a StyleChangeEvent
			this.dispatchEvent(
				new StyleChangeEvent(StyleChangeEvent.ADDED_GLOBAL_CONFIG,
					{config: name}));
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
			
			// dispatch a StyleChangeEvent
			this.dispatchEvent(
				new StyleChangeEvent(StyleChangeEvent.REMOVED_GLOBAL_CONFIG,
					{config: name}));
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