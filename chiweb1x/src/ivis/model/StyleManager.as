package ivis.model
{
	import ivis.model.util.Styles;

	/**
	 * This class is designed to manage visual styles attached to
	 * IStyleAttachable instances. This manager may contain at most one default 
	 * style, at most one specific style, and arbitrary number of group 
	 * styles.
	 * 
	 * In order to add a default style to this manager, the function add()
	 * should be called with the string Styles.DEFAULT_STYLE as a name. 
	 * Similarly, in order to add a specifc style, it should be called with
	 * the string Styles.SPECIFIC_STYLE as a name.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class StyleManager
	{
		/**
		 * Default visual style.
		 */
		protected var _defaultStyle:Style;
		
		/**
		 * Specific visual style.
		 */
		protected var _specificStyle:Style;
		
		/**
		 * Map containing all group visual styles. This map is used for fast
		 * access to group styles.
		 */
		protected var _groupStyleMap:Object;
		
		/**
		 * Array containing all group visual styles. Contents of this array is
		 * the same as the contents of the group style map. This array is
		 * used to manage style priorities: Last added group style has a
		 * priority over the previously added group styles.
		 */
		protected var _groupStyleList:Array;
		
		/**
		 * Array of all visual styles (including default style, group styles,
		 * and specific style).
		 */
		public function get allStyles():Array
		{
			var all:Array = new Array();
			
			if (this._defaultStyle != null)
			{
				all.push(this._defaultStyle);
			}
			
			all = all.concat(this._groupStyleList);
			
			if (this._specificStyle != null)
			{
				all.push(this._specificStyle);
			}
			
			return all;
		}
		
		/**
		 * Array of group styles. This array does not include default and 
		 * specific styles.
		 */
		public function get groupStyles():Array
		{
			return this._groupStyleList.slice();
		}
		
		
		/**
		 * Initializes a new StyleManager with default properties.
		 */
		public function StyleManager()
		{
			this._defaultStyle = null;
			this._specificStyle = null;
			this._groupStyleMap = new Object();
			this._groupStyleList = new Array();
		}
		
		
		/**
		 * Adds the given visual style for the specified name to the set.
		 * 
		 * @param name	name of the style
		 * @param style	visual style to be added 
		 */
		public function add(name:String,
			style:Style):void
		{
			var prev:Style;
			
			if (name == Styles.DEFAULT_STYLE)
			{
				this._defaultStyle = style;
			}
			else if (name == Styles.SPECIFIC_STYLE)
			{
				this._specificStyle = style;
			}
			else
			{
				prev = this._groupStyleMap[name];
				
				// add to map
				this._groupStyleMap[name] = style;
				
				// remove previous style (for the same name) from list, if any
				if (prev != null)
				{
					this.removeFromList(prev);
				}
				
				// add new style to the end of list
				this._groupStyleList.push(style);
			}
		}
		
		/**
		 * Removes the visual style corresponding to the given style name
		 * from the set.
		 * 
		 * @param name	name of the visual style
		 * @return		removed visual style if success, null otherwise 
		 */
		public function remove(name:String):Style
		{
			var style:Style;
			
			if (name == Styles.DEFAULT_STYLE)
			{
				style = this._defaultStyle;
				this._defaultStyle = null;
			}
			else if (name == Styles.SPECIFIC_STYLE)
			{
				style = this._specificStyle;
				this._specificStyle = null;
			}
			else
			{
				style = this._groupStyleMap[name];
				
				if (style != null)
				{
					// remove from map
					delete this._groupStyleMap[name];
					
					// remove from list
					this.removeFromList(style);
				}
			}
			
			return style;
		}
		
		/**
		 * Retrieves the visual style corresponding to the given style name.
		 * 
		 * @param name	name of the visual style
		 * @return		visual style for the given name
		 */
		public function getStyle(name:String):Style
		{
			var style:Style;
			
			if (name == Styles.DEFAULT_STYLE)
			{
				style = this._defaultStyle;
			}
			else if (name == Styles.SPECIFIC_STYLE)
			{
				style = this._specificStyle;
			}
			else
			{
				style = this._groupStyleMap[name];
			}
			
			return style;
		}
		
		/**
		 * Returns the registered name for the given style instance.
		 * If the given style cannot be found in the list of attached styles,
		 * then null value is returned.
		 * 
		 * TODO add function to the UML diagram!
		 * 
		 * @param style	a style instance to search
		 * @return		name of the style, or null if style not found
		 */
		public function getStyleName(style:Style):String
		{
			var name:String;
			var found:Boolean = false;
			
			if (style == this._defaultStyle)
			{
				name = Styles.DEFAULT_STYLE;
			}
			else if (style == this._specificStyle)
			{
				name = Styles.SPECIFIC_STYLE;
			}
			else
			{
				// search for the style withing the group styles
				for (name in this._groupStyleMap)
				{
					if (style == this._groupStyleMap[name])
					{
						// set flag
						found = true;
						
						// terminate loop when style found
						break;
					}
				}
			}
			
			if (!found)
			{
				name = null;
			}
			
			return name;
		}
		
		/**
		 * Removes the given visual style from the group style.
		 * 
		 * @param style	style to be removed
		 */
		protected function removeFromList(style:Style):void
		{
			var index:int;
			
			// find the index of the style
			for (index = 0; index < this._groupStyleList.length; index++)
			{
				if (style == this._groupStyleList[index])
				{
					// index found, break loop
					break;
				}
			}
			
			// remove the style at the found index
			
			if (index < this._groupStyleList.length)
			{
				this._groupStyleList =
					this._groupStyleList.slice(0, index).concat(
						this._groupStyleList.slice(index + 1));
			}
		}
	}
}