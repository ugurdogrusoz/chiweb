package ui
{
	import flare.vis.data.DataSprite;
	
	import flash.geom.Point;
	
	import ivis.view.ui.IEdgeUI;
	
	import util.DashedLine;

	/**
	 * Implementation of the IEdgeUI interface for dashed linear edge shapes.
	 * This class is designed to draw edges as dashed lines.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class DashedEdgeUI implements IEdgeUI
	{
		protected static var _instance:IEdgeUI;
		
		protected var _dashedLine:DashedLine;
		
		/**
		 * Singleton instance.
		 */
		public static function get instance():IEdgeUI
		{
			if (_instance == null)
			{
				_instance = new DashedEdgeUI();
			}
			
			return _instance;
		}
		
		//------------------------- CONSTRUCTOR --------------------------------
		
		public function DashedEdgeUI()
		{
			// default constructor
		}
		
		//---------------------- PUBLIC FUNCTIONS ------------------------------
		
		public function setLineStyle(ds:DataSprite):void
		{
			//var g:Graphics = ds.graphics;
			
			var onLength:Number = ds.props.onLengthCoeff * ds.lineWidth;
			var offLength:Number = ds.props.offLengthCoeff * ds.lineWidth;
			
			this._dashedLine = new DashedLine(ds, onLength, offLength);
			//this._dashedLine.lineStyle(ds.lineWidth, ds.lineColor, 1);
			this._dashedLine.lineStyle(ds.lineWidth, ds.lineColor, ds.lineAlpha);
			
			//var newCaps:String = LineStyles.getCaps(lineStyle);
			//g.lineStyle(w, color, 1, pixelHinting, scaleMode, newCaps, joints, miterLimit);
		}
		
		public function draw(ds:DataSprite):void
		{
			var startPoint:Point = ds.props.$startPoint as Point;
			var endPoint:Point = ds.props.$endPoint as Point;
			
			this._dashedLine.moveTo(startPoint.x, startPoint.y);
			this._dashedLine.lineTo(endPoint.x, endPoint.y);
		}
		
		
	}
}