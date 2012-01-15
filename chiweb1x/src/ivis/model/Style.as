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
				this._style = new Object();
			}
			else
			{
				// set style map
				this._style = style;
			}
		}
		
		//---------------------- PUBLIC FUNCTIONS ------------------------------

		/**
		 * Adds a new property to the style map for the given name and value
		 * pair. If a property with the given name already exists, it is
		 * overwritten.
		 * 
		 * IMPORTANT NOTE: Never add style properties 'width' & 'height' for
		 * Node and Edge instances! Use 'w' or 'h' instead. 'width' and 'height'
		 * are internally used by Flare. Adding a style property for 'width' or 
		 * 'height' may cause unexpected rendering of Nodes and Edges.
		 * 
		 * TODO we may prevent adding properties for fields that are not related
		 * to visual properties such as fields defined in DataSprite (or in any 
		 * direct and indirect inheritors) that are used for other purposes
		 * than rendering: for example, parentE variable of the Edge class.
		 * Another solution is to attach all properties to the 'props' object
		 * only, but this may cause backward incompatibilities for Flare's
		 * original renderers.
		 *  
		 * @param name	name of the property
		 * @param value	value of the property
		 */
		public function addProperty(name:String, value:*):void
		{
			// add property to the map
			this._style[name] = value;
			
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
		public function removeProperty(name:String):void
		{
			// remove property from the map
			delete this._style[name];
			
			// dispatch a StyleChangeEvent
			this.dispatchEvent(
				new StyleChangeEvent(StyleChangeEvent.REMOVED_STYLE_PROP,
					{style: this, property: name}));
		}
		
		/**
		 * Gets the value of the property for the specified property name.
		 */
		public function getProperty(name:String):*
		{
			return this._style[name];
		}
		
		/**
		 * Retrieves names of style properties as an array.
		 * 
		 * @return	array of property names
		 */
		public function getPropNames():Array
		{
			var props:Array = new Array();
			
			for (var name:String in this._style)
			{
				props.push(name);
			}
			
			return props;
		}
		
		/**
		 * Applies the current style (by setting corresponding fields)
		 * to the given graph element.
		 * 
		 * @param element	a graph element to apply settings
		 */
		public function apply(element:Object):void
		{
			for (var field:String in this._style)
			{
				// if the element has a field with the given name set the value
				// of that field
				if (element.hasOwnProperty(field))
				{
					element[field] = this._style[field];
				}
				// if no field with the current name set props.name
				else
				{
					element.props[field] = this._style[field];
				}
			}
		}
	}
}