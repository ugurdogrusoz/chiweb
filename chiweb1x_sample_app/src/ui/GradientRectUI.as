package ivis.view.ui
{
	import flare.vis.data.DataSprite;
	
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.InterpolationMethod;
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;

	/**
	 * Class for custom UI test for debugging purposes.
	 */
	public class GradientRectUI extends RectangularNodeUI
	{
		private static var _instance:INodeUI;
		
		/**
		 * Singleton instance.
		 */
		public static function get instance():INodeUI
		{
			if (_instance == null)
			{
				_instance = new GradientRectUI();
			}
			
			return _instance;
		}
		
		
		public function GradientRectUI()
		{
			
		}
		
		public override function draw(ds:DataSprite,
			defaultSize:Number):void
		{
			var g:Graphics = ds.graphics;
			
			var m:Matrix = new Matrix();
			
			var width:Number = ds.w * defaultSize;
			var height:Number = ds.h * defaultSize;
			
			//m.createGradientBox(width, height, Math.atan(height/width));
			m.createGradientBox(width, height, Math.atan(width/height));
			
			g.beginGradientFill(GradientType.LINEAR,
				[0xffffff & ds.fillColor, 0xeeeeee],
				[ds.fillAlpha, ds.fillAlpha],
				[32, 255], m,
				SpreadMethod.REFLECT,
				InterpolationMethod.RGB, 1);
			
			//g.beginFill(0xffffff & ds.fillColor, ds.fillAlpha);
			
			super.draw(ds, defaultSize);
			//g.endFill();
		}
	}
}