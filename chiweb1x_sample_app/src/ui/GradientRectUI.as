package ui
{
	import flare.vis.data.DataSprite;
	
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.InterpolationMethod;
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;
	
	import ivis.view.ui.INodeUI;
	import ivis.view.ui.RectangularNodeUI;

	/**
	 * Implementation of the INodeUI interface for gradient color rectangle.
	 * 
	 * @author Selcuk Onur Sumer
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
		
		public override function draw(ds:DataSprite):void
		{
			var g:Graphics = ds.graphics;
			
			var m:Matrix = new Matrix();
			
			var width:Number = ds.w;
			var height:Number = ds.h;
			
			//m.createGradientBox(width, height, Math.atan(height/width));
			m.createGradientBox(width, height, Math.atan(width/height));
			
			g.beginGradientFill(GradientType.LINEAR,
				[0xffffff & ds.fillColor, 0xeeeeee],
				[ds.fillAlpha, ds.fillAlpha],
				[32, 255], m,
				SpreadMethod.REFLECT,
				InterpolationMethod.RGB, 1);
			
			super.draw(ds);
		}
	}
}