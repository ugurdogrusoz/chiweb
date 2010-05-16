package ivis.ui
{
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.controls.Label;
	import mx.events.ResizeEvent;
	
	/**
	 * 
	 * @author Ebrahim
	 */
	public class TextLabel extends ivis.ui.Label
	{
		
		/**
		 * 
		 * @default 
		 */
		public var _label: mx.controls.Label;
		
		/**
		 * 
		 * @param text
		 * @param relPos
		 * @param absPos
		 */
		public function TextLabel(text: String = "", relPos: Point = null, absPos: Point = null)
		{
			super(relPos, absPos);
			
			this._label = new mx.controls.Label;
			this._label.mouseEnabled = false;
			this._label.text = text;
		}
		
		public function set font(ff: String): void
		{
			this._label.setStyle("fontFamily", ff);
		}
		
		public function set fontSize(fs: Number): void
		{
			this._label.setStyle("fontSize", fs);
		}
		
		/**
		 * 
		 * @param c
		 */
		override public function set component(c: Component): void
		{
			if(c == null && this._component != null) {
				this._component.removeChild(this._label);
				return;
			}
				
			if(this._component === c)
				return;
				
			super.component = c;
			
			c.addChild(this._label);
			c.addEventListener(ResizeEvent.RESIZE, onComponentChanged);
		}
		
		/**
		 * 
		 * @param e
		 */
		private function onComponentChanged(e: Event): void
		{
			this._label.x = this._offset.x + this._component.width * this._relativePosition.x;
			this._label.width = this._component.width - this._label.x;
			this._label.y = this._offset.y + this._component.height * this._relativePosition.y;
			this._label.height = this._label.measureText(this._label.text).height;
		}
	}
}