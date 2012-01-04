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
	 * Custom UI class for gradient coloring. Extends RectangularNodeUI to draw
	 * rectangular nodes with gradient coloring.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class GradientRectUI extends RectangularNodeUI
	{
		public static const AUTO_ANGLE:String = "autoAngle";
		
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
		
		//------------------------- CONSTRUCTOR --------------------------------
		
		public function GradientRectUI()
		{
			// default constructor
		}
		
		//---------------------- PUBLIC FUNCTIONS ------------------------------
		
		public override function draw(ds:DataSprite):void
		{
			var g:Graphics = ds.graphics;
			
			var m:Matrix = new Matrix();
			
			var width:Number = ds.w;
			var height:Number = ds.h;
			
			//m.createGradientBox(width, height, Math.atan(height/width));
			if (ds.props.gradientAngle == GradientRectUI.AUTO_ANGLE)
			{
				m.createGradientBox(width, height, Math.atan(width/height));
			}
			else
			{
				m.createGradientBox(width, height, ds.props.gradientAngle);
			}
			
			// it is also possible to parameterize each value within ds.props
			// to enable more customization
			g.beginGradientFill(ds.props.gradientType,
				[0xffffff & ds.fillColor, 0xeeeeee],
				[ds.fillAlpha, ds.fillAlpha],
				[32, 255], m,
				ds.props.spreadMethod,
				ds.props.interpolationMethod, 0);
			
			super.draw(ds);
		}
	}
}