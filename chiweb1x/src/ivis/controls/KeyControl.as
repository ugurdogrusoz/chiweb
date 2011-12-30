package ivis.controls
{	
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	import ivis.manager.GlobalConfig;
	import ivis.manager.GraphManager;

	/**
	 * Control class for the key press actions.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class KeyControl extends EventControl
	{
		
		//-------------------------- CONSTRUCTOR -------------------------------
		
		public function KeyControl(graphManager:GraphManager,
			stateManager:StateManager,
			filter:* = null)
		{
			super(graphManager, stateManager);
			this.filter = filter;
		}
		
		//----------------------- PUBLIC FUNCTIONS -----------------------------
		
		/** @inheritDoc */
		public override function attach(obj:InteractiveObject):void
		{
			if (obj == null)
			{
				this.detach();
				return;
			}
			
			super.attach(obj);
			
			if (obj != null)
			{
				obj.addEventListener(Event.ADDED_TO_STAGE, onAdd);
				obj.addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
				
				if (obj.stage != null)
				{
					this.onAdd();
				}
			}
		}
		
		/** @inheritDoc */
		public override function detach():InteractiveObject
		{
			if (this.object != null)
			{
				this.object.removeEventListener(Event.ADDED_TO_STAGE, onAdd);
				this.object.removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
				
				this.onRemove();
			}
			
			return super.detach();
		}
		
		//----------------------- PROTECTED FUNCTIONS --------------------------
		
		/**
		 * Listener for KEY_DOWN event.
		 * 
		 * @param evt	KeyboardEvent that triggered the action
		 */
		protected function onDown(evt:KeyboardEvent):void
		{
			var selectKey:String = this.graphManager.globalConfig.getConfig(
				GlobalConfig.SELECTION_KEY);
			
			var keyStatus:Boolean = false; 
			
			if (evt.hasOwnProperty(selectKey))
			{
				keyStatus = evt[selectKey];
			}
			
			this.stateManager.setState(StateManager.SELECT_KEY_DOWN, keyStatus); 
		}
		
		/**
		 * Listener for KEY_UP event.
		 * 
		 * @param evt	KeyboardEvent that triggered the action
		 */
		protected function onUp(evt:KeyboardEvent):void
		{
			var selectKey:String = this.graphManager.globalConfig.getConfig(
				GlobalConfig.SELECTION_KEY);
			
			var keyStatus:Boolean = false; 
			
			if (evt.hasOwnProperty(selectKey))
			{
				keyStatus = evt[selectKey];
			}
			
			this.stateManager.setState(StateManager.SELECT_KEY_DOWN, keyStatus);
			
		}
		
		/**
		 * Listener for ADDED_TO_STAGE event. Invoked when the interactive
		 * object, to which this control is attached, is added to the stage.
		 *
		 * @param evt	Event that triggered the action 
		 */
		protected function onAdd(evt:Event = null):void
		{
			//view.stage.addEventListener(KeyboardEvent.KEY_DOWN, onDown, false, 0, true);
			//view.stage.addEventListener(KeyboardEvent.KEY_UP, onUp, false, 0, true);
			this.object.stage.addEventListener(KeyboardEvent.KEY_DOWN, onDown);
			this.object.stage.addEventListener(KeyboardEvent.KEY_UP, onUp);
		}
		
		
		/**
		 * Listener for REMOVED_FROM_STAGE event. Invoked when the interactive
		 * object, to which this control is attached, is removed from the stage.
		 * 
		 * @param evt	Event that triggered the action
		 */
		protected function onRemove(evt:Event = null):void
		{
			this.object.stage.removeEventListener(KeyboardEvent.KEY_DOWN,
				onDown);
			
			this.object.stage.removeEventListener(KeyboardEvent.KEY_UP,
				onUp);
		}
	}
}