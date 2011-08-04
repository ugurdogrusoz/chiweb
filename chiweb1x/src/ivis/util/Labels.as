package ivis.util
{
	import flare.display.TextSprite;

	/**
	 * Utility class for node and edge labels.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class Labels
	{
		public function Labels()
		{
			throw new Error("Labels is an abstract class.");
		}
		
		public static function leftBorder(label:TextSprite):Number
		{
			//var left:Number = label.x - (label.width / 2);
			//var left:Number = label.x + label.textField.x;
			var left:Number = label.x + label.textField.x - label.width;
			
			return left;
		}
		
		public static function rightBorder(label:TextSprite):Number
		{
			//var right:Number = label.x + (label.width / 2);
			var right:Number = label.x + label.textField.x + label.width;
			
			return right;
		}
		
		public static function topBorder(label:TextSprite):Number
		{
			//var top:Number = label.y - (label.height / 2);
			//var top:Number = label.y + label.textField.y;
			//var top:Number = label.y + label.textField.y - (label.textField.height / 2);
			var top:Number = label.y + label.textField.y - label.height;
			
			return top;
		}
		
		public static function bottomBorder(label:TextSprite):Number
		{
			//var bottom:Number = label.y + (label.height / 2);
			//var bottom:Number = label.y + label.textField.y + label.height;			
			//var bottom:Number = label.y + label.textField.y + (label.textField.height / 2);
			var bottom:Number = label.y + label.textField.y + label.height;
			
			return bottom;
		}
	}
}