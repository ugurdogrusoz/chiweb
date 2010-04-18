package ivis.ui
{
	import flash.display.Loader;
	import flash.events.MouseEvent;

	// TODO: user Image instead of loader??
	// url-based or static images?
	/**
	 * 
	 * @author Ebrahim
	 */
	public class VisualCue extends Loader
	{
		var relativeX: Number;
		var relativeY: Number;
		var offsetX: Number;
		var offsetY: Number;
		
		/**
		 * 
		 */
		public function VisualCue()
		{
			super();
			
			this.registerHandlers();
		}
		
		//
		// protected methods
		//
		
		/**
		 * 
		 * @param e
		 */
		protected function onClick(e: MouseEvent): void
		{
		}

		/**
		 * 
		 * @param e
		 */
		protected function onDoubleClick(e: MouseEvent): void
		{
		}
		
		/**
		 * 
		 * @param e
		 */
		protected function onHover(e: MouseEvent): void
		{
		}
		
		//
		// private methods
		//
		
		/**
		 * 
		 */
		private function registerHandlers(): void
		{
			this.addEventListener(MouseEvent.CLICK, this.onClick);
			this.addEventListener(MouseEvent.DOUBLE_CLICK, this.onDoubleClick);
			this.addEventListener(MouseEvent.MOUSE_OVER, this.onHover);
		}
	}
}