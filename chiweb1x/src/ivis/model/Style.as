package ivis.model
{
	import flash.events.EventDispatcher;
	
	import ivis.event.StyleChangeEvent;

	/**
	 * Represents style properties of a graph element.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class Style extends EventDispatcher
	{
		/**
		 * Map for attaching style properties.
		 */
		protected var _style:Object;
		
		//------------------------- CONSTRUCTOR --------------------------------
		
		/**
		 * Initializes a VisualStyle with given style object holding style
		 * properties.
		 * 
		 * @param name	name of the style
		 * @param style	style object holding style properties
		 */
		public function Style(style:Object = null)
		{
			if (style == null)
			{
				// initialize an empty style map if none is provided
				_style = new Object();
			}
			else
			{
				// set style map
				_style = style;
			}
		}
		
		//---------------------- PUBLIC FUNCTIONS ------------------------------

		/**
		 * Adds a new property to the style map for the given name and value
		 * pair. If a property with the given name already exists, it is
		 * overwritten. 
		 *  
		 * @param name	name of the property
		 * @param value	value of the property
		 */
		public function addProperty(name:String, value:*) : void
		{
			// add property to the map
			_style[name] = value;
			
			// dispatch a StyleChangeEvent
			this.dispatchEvent(
				new StyleChangeEvent(StyleChangeEvent.ADDED_STYLE_PROP,
					{style: this, property: name}));
		}
		
		/**
		 * Removes the property having the given name from the style map. 
		 *  
		 * @param name	name of the property to be removed
		 */
		public function removeProperty(name:String) : void
		{
			// remove property from the map
			delete _style[name];
			
			// dispatch a StyleChangeEvent
			this.dispatchEvent(
				new StyleChangeEvent(StyleChangeEvent.REMOVED_STYLE_PROP,
					{style: this, property: name}));
		}
		
		/**
		 * Gets the value of the property for the specified property name.
		 */
		public function getProperty(name:String) : *
		{
			return _style[name];
		}
		
		/**
		 * Applies the current style (by setting corresponding fields)
		 * to the given graph element.
		 * 
		 * @param element	a graph element to apply settings
		 */
		public function apply(element:Object) : void
		{
			for (var field:String in _style)
			{
				// if the element has a field with the given name set the value
				// of that field
				if (element.hasOwnProperty(field))
				{
					element[field] = _style[field];
				}
				// if no field with the current name set props.name
				else
				{
					element.props[field] = _style[field];
				}
			}
		}
	}
}