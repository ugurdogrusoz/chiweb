package controls
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import ivis.controls.KeyControl;
	import ivis.controls.StateManager;
	import ivis.manager.GraphManager;
	
	import util.Constants;

	/**
	 * Key control to enable panning with arrow keys.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class KeyPanControl extends KeyControl
	{
		//-------------------------- CONSTRUCTOR -------------------------------
		
		public function KeyPanControl(graphManager:GraphManager = null,
			stateManager:StateManager = null,
			filter:* = null)
		{
			super(graphManager, stateManager, filter);
		}
		
		//----------------------- PROTECTED FUNCTIONS --------------------------
		
		/**
		 * Listener for KEY_DOWN event.
		 * 
		 * @param evt	KeyboardEvent that triggered the action
		 */
		protected override function onKeyDown(evt:KeyboardEvent):void
		{
			var amount:Number = this.graphManager.globalConfig.getConfig(
				Constants.PAN_AMOUNT);
			
			if (evt.keyCode == Keyboard.RIGHT)
			{
				// pan to right by the amount set in global config 
				this.graphManager.panView(amount, 0);
			}
			else if (evt.keyCode == Keyboard.LEFT)
			{
				// pan to left by the amount set in global config
				this.graphManager.panView(-amount, 0);
			}
			else if (evt.keyCode == Keyboard.UP)
			{
				// pan to up by the amount set in global config
				this.graphManager.panView(0, -amount);
			}
			else if (evt.keyCode == Keyboard.DOWN)
			{
				// pan to down by the amount set in global config
				this.graphManager.panView(0, amount);
			}
		}
		
		/**
		 * Listener for KEY_UP event.
		 * 
		 * @param evt	KeyboardEvent that triggered the action
		 */
		protected override function onKeyUp(evt:KeyboardEvent):void
		{
			// do nothing: this function is overridden to disable super.onKeyUp
		}
	}
}