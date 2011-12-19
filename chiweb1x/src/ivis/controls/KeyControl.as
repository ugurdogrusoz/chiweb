package ivis.controls
{	
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	import ivis.view.GraphManager;

	/**
	 * Control class for the key press actions.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class KeyControl extends EventControl
	{
		public function KeyControl(manager:GraphManager = null,
			filter:*=null)
		{
			super(manager);
			this.filter = filter;
		}
		
		/** @inheritDoc */
		public override function attach(obj:InteractiveObject):void
		{
			if (obj == null)
			{
				detach();
				return;
			}
			
			super.attach(obj);
			
			if (obj != null)
			{
				if (obj.stage != null)
				{
					this.onAdd();
				}
				else
				{
					obj.addEventListener(Event.ADDED_TO_STAGE, onAdd);
				}
			}
		}
		
		/** @inheritDoc */
		public override function detach():InteractiveObject
		{
			if (_object != null)
			{
				if (_object.stage != null)
				{
					this.onRemove();
				}
			}
			
			return super.detach();
		}
		
		protected function onDown(evt:KeyboardEvent):void
		{
			// TODO take the select key as a constructor parameter, CTRL should
			// be the default key
			this.state.selectKeyDown = evt.ctrlKey; 
		}
		
		protected function onUp(evt:KeyboardEvent):void
		{
			// TODO take the select key as a parameter
			this.state.selectKeyDown = evt.ctrlKey;
		}
		
		protected function onAdd(evt:Event=null):void
		{
			//view.stage.addEventListener(KeyboardEvent.KEY_DOWN, onDown, false, 0, true);
			//view.stage.addEventListener(KeyboardEvent.KEY_UP, onUp, false, 0, true);
			_object.stage.addEventListener(KeyboardEvent.KEY_DOWN, onDown);
			_object.stage.addEventListener(KeyboardEvent.KEY_UP, onUp);
		}
		
		protected function onRemove(evt:Event=null):void
		{
			_object.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onDown);
			_object.stage.removeEventListener(KeyboardEvent.KEY_UP, onUp);
		}
	}
}