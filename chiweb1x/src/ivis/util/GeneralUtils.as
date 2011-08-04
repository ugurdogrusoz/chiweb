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
		public function GeneralUtils()
		{
			throw new Error("DisplayUtils is an abstract class.");
		}
		
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