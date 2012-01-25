package controls
{
	import flare.vis.data.DataSprite;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	
	import ivis.controls.SelectControl;
	import ivis.controls.StateManager;
	import ivis.manager.GlobalConfig;
	import ivis.manager.GraphManager;
	
	import util.Constants;

	/**
	 * Marquee zoom control to enable zoom by rubber-band selection.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class MarqueeZoomControl extends SelectControl
	{
		//-------------------------- CONSTRUCTOR -------------------------------
		
		public function MarqueeZoomControl(graphManager:GraphManager = null,
			stateManager:StateManager = null,
			filter:* = null)
		{
			super(graphManager, stateManager, filter);
		}
		
		//----------------------- PROTECTED FUNCTIONS --------------------------
		
		/**
		 * Renders the enclosing rectangle. This function gets
		 * the visual properties of the shape from the global config.
		 */
		protected override function renderEncloser():void
		{
			var lineColor:uint = this.graphManager.globalConfig.getConfig(
				Constants.MARQUEE_LINE_COLOR);
			
			var lineAlpha:Number = this.graphManager.globalConfig.getConfig(
				GlobalConfig.ENCLOSING_LINE_ALPHA);
			
			var lineWidth:Number = this.graphManager.globalConfig.getConfig(
				Constants.MARQUEE_LINE_WIDTH);
			
			var fillColor:uint = this.graphManager.globalConfig.getConfig(
				Constants.MARQUEE_FILL_COLOR);
			
			var fillAlpha:Number = this.graphManager.globalConfig.getConfig(
				GlobalConfig.ENCLOSING_FILL_ALPHA);			
			
			this.renderShape(this._enclosingShape,
				this._enclosingRect,
				lineColor,
				lineAlpha,
				lineWidth,
				fillColor,
				fillAlpha);
		}
		
		/**
		 * Performs the marquee zoom operation.
		 */
		protected function marqueeZoom():void
		{
			var centerX:Number = _enclosingRect.x + _enclosingRect.width / 2;
			var centerY:Number = _enclosingRect.y + _enclosingRect.height / 2;
			
			var amountX:Number = -this.object.x - centerX * this.object.scaleX; 
			var amountY:Number = -this.object.y - centerY * this.object.scaleY;
			
			// center the view to the center of the enclosing rectangle
			this.graphManager.panView(amountX, amountY);
			
			// zoom to fit to the scale of enclosing rectangle
			var scaleX:Number = this.graphManager.view.parent.width /
				this._enclosingRect.width;
			
			var scaleY:Number = this.graphManager.view.parent.height /
				this._enclosingRect.height;
			
			this.graphManager.zoomView(Math.min(scaleX, scaleY) /
				this.object.scaleX);
		}
		
		/**
		 * Listener function for MOUSE_DOWN event. Adds listeners for MOUSE_UP
		 * and MOUSE_MOVE events, and updates the enclosing rectangle.
		 * 
		 * @param evt	MouseEvent that triggered the action
		 */
		protected override function onMouseDown(evt:MouseEvent):void
		{
			trace("[MarqueeZoomControl.onDown] target: " + evt.target);
			
			if (this.object != null &&
				this.stateManager.checkState(Constants.MARQUEE_ZOOM) &&
				!(evt.target is DataSprite))
			{
				this.object.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				this.object.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
				
				this.initEncloser();
			}
		}
		
		/**
		 * Listener function for MOUSE_UP event.
		 * 
		 * @param evt	MouseEvent that triggered the action
		 */
		protected override function onMouseUp(evt:MouseEvent):void
		{
			// when mouse up, the enclosing rectangle becomes inactive
			this._enclosing = false;
			
			if (this.object != null)
			{
				trace ("[MarqueeZoomControl.onDown] " + this._enclosingRect);
				
				// remove the shape
				(this.object as DisplayObjectContainer).removeChild(
					this._enclosingShape);
				
				// remove listeners
				this.object.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				this.object.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
				
				
				this.marqueeZoom();
			}
		}
		
		/**
		 * Listener function for MOUSE_MOVE event. Updates the bounds of
		 * enclosing rectangle.
		 * 
		 * @param evt	MouseEvent that triggered the action
		 */
		protected override function onMove(evt:MouseEvent):void
		{
			if (this._enclosing &&
				this.stateManager.checkState(Constants.MARQUEE_ZOOM))
			{
				this._enclosingRect.width = this.object.mouseX -
					this._enclosingRect.x;
				
				this._enclosingRect.height = this.object.mouseY - 
					this._enclosingRect.y;
				
				this.renderEncloser();
			}
		}
	}
}