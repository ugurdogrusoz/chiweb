package ivis.util
{
	import flare.vis.data.DataSprite;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;

	/**
	 * Utility class that contains general purpose functions.
	 * 
	 * @author Selcuk Onur Sumer
	 */ 
	public class GeneralUtils
	{
		//-----------------------CONSTRUCTOR------------------------------------
		
		public function GeneralUtils()
		{
			throw new Error("GeneralUtils is an abstract class.");
		}
		
		//---------------------- PUBLIC FUNCTIONS ------------------------------
		
		/**
		 * Brings the specified display object to the front of the stage.  
		 */
		public static function bringToFront(displayObj:DisplayObject):void
		{
			if (displayObj != null)
			{
				var parent:DisplayObjectContainer = displayObj.parent;
				
				if (parent != null)
				{
					parent.setChildIndex(displayObj,
						parent.numChildren-1);
				}
			}
		}
		
		/**
		 * Adds the specified filter to the filters array of the given data
		 * sprite.
		 * 
		 * @param ds		data sprite having a filter array
		 * @param filter	filter to be added
		 */
		public static function addFilter(ds:DataSprite,
			filter:*) : void
		{
			// init sprite's filter array if not initialized yet
			if (ds.props.$filters == null)
			{
				ds.props.$filters = new Array();
			}
			
			var filters:Array = ds.props.$filters;
			
			// add new filter to the array
			filters.push(filter);
			ds.props.$filters = filters;
			
			// just calling ds.filters.push() does not work due to filtering
			// mechanism of flash, so ds.filter should be reset explicitly
			ds.filters = filters;
		}
		
		/**
		 * Finds and removes the specified filter from the filters array
		 * of the given data sprite.
		 * 
		 * @param ds		data sprite having a filter array
		 * @param filter	filter to be removed
		 */
		public static function removeFilter(ds:DataSprite,
			filter:*) : void
		{
			if (ds.props.$filters == null)
			{
				return;
			}
			
			var filters:Array = ds.props.$filters;
			
			// find the index of the given filter
			var index:int = filters.indexOf(filter);
			
			// remove filter from the array if it is found
			if (index != -1)
			{
				// remove filter
				filters = filters.slice(0, index).concat(
					filters.slice(index + 1));
				
				// update filters arrays
				ds.props.$filters = filters;
				ds.filters = filters;
			}
		}
		
		/**
		 * Finds the minimum number within the given array.
		 * 
		 * @param values	array of Numbers
		 * @return			minimum number within the array 
		 */
		public static function min(values:Array):Number
		{
			var min:Number = int.MAX_VALUE;
			
			for each (var value:Number in values)
			{
				if (value < min)
				{
					min = value;
				}
			}
			
			return min;
		}
		
		/**
		 * Finds the maximum number within the given array.
		 * 
		 * @param values	array of Numbers
		 * @return			maximum number within the array 
		 */
		public static function max(values:Array):Number
		{
			var max:Number = int.MIN_VALUE;
			
			for each (var value:Number in values)
			{
				if (value > max)
				{
					max = value;
				}
			}
			
			return max;
		}
	}
}