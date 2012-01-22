package ivis.util
{
	import flare.display.TextSprite;

	/**
	 * Utility class for node and edge labels. To calculate a border value for a
	 * label, it is also required to consider the text field of the label,
	 * since width & height of the label depend on its text field.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class Labels
	{
		public static const DEFAULT_LABEL_ACCESS:String = "props.$label";
		public static const DEFAULT_TEXT_SOURCE:String = "props.labelText";
		
		//-----------------------CONSTRUCTOR------------------------------------
		
		public function Labels()
		{
			throw new Error("Labels is an abstract class.");
		}
		
		//---------------------- PUBLIC FUNCTIONS ------------------------------
		
		/**
		 * Calculates the leftmost x-coordiante of the given label.
		 * 
		 * @param label	label as a TextSprite
		 * @return		leftmost x-coordiante of the label  
		 */
		public static function leftBorder(label:TextSprite):Number
		{
			var left:Number = label.x + label.textField.x;
			
			return left;
		}
		
		/**
		 * Calculates the rightmost x-coordiante of the given label.
		 * 
		 * @param label	label as a TextSprite
		 * @return		rightmost x-coordiante of the label  
		 */
		public static function rightBorder(label:TextSprite):Number
		{
			var right:Number = label.x + label.textField.x + label.width;
			
			return right;
		}
		
		/**
		 * Calculates the topmost y-coordiante of the given label.
		 * 
		 * @param label	label as a TextSprite
		 * @return		topmost y-coordiante of the label  
		 */
		public static function topBorder(label:TextSprite):Number
		{
			var top:Number = label.y + label.textField.y;
			
			return top;
		}
		
		/**
		 * Calculates the bottommost y-coordiante of the given label.
		 * 
		 * @param label	label as a TextSprite
		 * @return		bottommost y-coordiante of the label  
		 */
		public static function bottomBorder(label:TextSprite):Number
		{
			var bottom:Number = label.y + label.textField.y + label.height;
			
			return bottom;
		}
	}
}