package ivis.util
{
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
			throw new Error("DisplayUtils is an abstract class.");
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
		 * Finds and removes the specified filter from the filter array
		 * of the given display object.
		 * 
		 * @param displayObj	display object having a filter array
		 * @param filter		filter to be removed
		 */
		public static function removeFilter(displayObj:DisplayObject, filter:*) : void
		{
			var filters:Array = displayObj.filters;
			var index:int;
			
			// find the index of the filter
			// TODO filter never found because it seems that flex creates another
			// instance from the previously added filter, we need to find another
			// way to remove the filter.
			// TODO possible solution: keep a separate list of filters,
			// reapply all filters after removing the specified one.
			for (index = 0; index < filters.length; index++)
			{
				if (filters[index] == filter)
				{
					// index found, stop iteration
					break;
				}
			}
			
			// check if filter found
			if (index < filters.length)
			{
				// remove the given filter at the found index
				filters = filters.slice(0, index).concat(
					filters.slice(index + 1));
			}
			
			//displayObj.filters = filters;
			
			// TODO workaround until a way found to remove the given filter
			displayObj.filters = null;
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