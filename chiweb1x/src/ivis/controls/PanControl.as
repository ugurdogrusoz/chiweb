package ivis.controls
{
	import flare.util.Displays;
	
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import ivis.manager.GraphManager;

	public class PanControl extends EventControl
	{
		// flag indicating dragging status
		protected var _dragging:Boolean;
		
		// x-cooridnate of the click event
		protected var _evtX:Number;
		
		// y-coordinate of the click event
		protected var _evtY:Number;
		
		public function PanControl(graphManager:GraphManager,
			stateManager:StateManager,
			filter:* = null)
		{
			super(graphManager, stateManager);
			this.filter = filter;
		}
		
		/** @inheritDoc */
		public override function attach(obj:InteractiveObject):void
		{
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
			if (_object != null)
			{
				_object.removeEventListener(Event.ADDED_TO_STAGE, onAdd);
				_object.removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
				
				this.onRemove();
			}
			
			return super.detach();
		}
		
		protected function onAdd(evt:Event = null):void
		{
			// add event listener to enable pan by drag
			_object.stage.addEventListener(MouseEvent.MOUSE_DOWN,
				onMouseDown);
		}
		
		protected function onRemove(evt:Event = null):void
		{
			_object.stage.removeEventListener(MouseEvent.MOUSE_DOWN,
				onMouseDown);
		}
		
		private function onMouseDown(event:MouseEvent) : void
		{
			if (this.stateManager.checkState(StateManager.PAN) &&
				this._object != null)
			{
				this._object.stage.addEventListener(MouseEvent.MOUSE_UP,
					onMouseUp);
				
				this._object.stage.addEventListener(MouseEvent.MOUSE_MOVE,
					onMouseMove);
				
				this._dragging = true;
				this._evtX = event.stageX;
				this._evtY = event.stageY;
			}
		}
		
		private function onMouseUp(event:MouseEvent) : void
		{
			this._dragging = false;
			
			if (this.stateManager.checkState(StateManager.PAN) &&
				this._object != null)
			{
				this._object.stage.removeEventListener(MouseEvent.MOUSE_UP,
					onMouseUp);
				
				this._object.stage.removeEventListener(MouseEvent.MOUSE_MOVE,
					onMouseMove);
			}
		}
		
		private function onMouseMove(event:MouseEvent) : void
		{
			var x:Number;
			var y:Number;
			
			if (this.stateManager.checkState(StateManager.PAN) &&
				this._dragging)
			{
				x = event.stageX;
				y = event.stageY;
				
				Displays.panBy(_object,
					x - this._evtX,
					y - this._evtY);
				
				this._evtX = x;
				this._evtY = y;
			}
		}
	}
}