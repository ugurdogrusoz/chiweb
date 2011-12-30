package ivis.controls
{
	import flare.util.Displays;
	
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import ivis.event.ControlEvent;
	import ivis.manager.GraphManager;

	/**
	 * Control class for panning the view. This class is designed to pan the
	 * view by clicking on and dragging the canvas. To provide another interface
	 * for panning, define your own controls (buttons for example), and use
	 * panView method of the GraphManager class.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class PanControl extends EventControl
	{
		// flag indicating dragging status
		protected var _dragging:Boolean;
		
		// x-cooridnate of the MOUSE_DOWN event
		protected var _evtX:Number;
		
		// y-cooridnate of the MOUSE_DOWN event
		protected var _evtY:Number;
		
		//-------------------------- CONSTRUCTOR -------------------------------
		
		public function PanControl(graphManager:GraphManager,
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
		
		//----------------------- PROTECTED FUNCTIONS --------------------------
		
		/**
		 * Listener for ADDED_TO_STAGE event. Invoked when the interactive
		 * object, to which this control is attached, is added to the stage.
		 *
		 * @param evt	Event that triggered the action 
		 */
		protected function onAdd(evt:Event = null):void
		{
			// add event listener to enable pan by drag
			_object.stage.addEventListener(MouseEvent.MOUSE_DOWN,
				onMouseDown);
		}
		
		/**
		 * Listener for REMOVED_FROM_STAGE event. Invoked when the interactive
		 * object, to which this control is attached, is removed from the stage.
		 * 
		 * @param evt	Event that triggered the action
		 */
		protected function onRemove(evt:Event = null):void
		{
			_object.stage.removeEventListener(MouseEvent.MOUSE_DOWN,
				onMouseDown);
		}
		
		/**
		 * Listener function for MOUSE_DOWN event. Stores the event cooridantes
		 * when the event is dispatched on the interactive object.
		 * 
		 * @param evt	MouseEvent that triggered the action
		 */
		protected function onMouseDown(event:MouseEvent) : void
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
				
				this.stateManager.setState(StateManager.PANNING, false);
				
				// dispatch event on the interactive object
				this.object.dispatchEvent(
					new ControlEvent(ControlEvent.PAN_START));
			}
		}
		
		/**
		 * Listener function for MOUSE_UP event. Updates the hit area of the
		 * view if necessary.
		 * 
		 * @param evt	MouseEvent that triggered the action
		 */
		protected function onMouseUp(event:MouseEvent) : void
		{
			this._dragging = false;
			
			if (this.stateManager.checkState(StateManager.PAN) &&
				this._object != null)
			{
				this._object.stage.removeEventListener(MouseEvent.MOUSE_UP,
					onMouseUp);
				
				this._object.stage.removeEventListener(MouseEvent.MOUSE_MOVE,
					onMouseMove);
				
				this.graphManager.view.updateHitArea();
				
				this.stateManager.setState(StateManager.PANNING, false);
				
				// dispatch event on the interactive object
				this.object.dispatchEvent(
					new ControlEvent(ControlEvent.PAN_END));
			}
		}
		
		/**
		 * Listener function for MOUSE_MOVE event. Pans the interactive object
		 * to which this control is attached.
		 * 
		 * @param evt	MouseEvent that triggered the action
		 */
		protected function onMouseMove(event:MouseEvent) : void
		{
			var x:Number;
			var y:Number;
			
			if (this.stateManager.checkState(StateManager.PAN) &&
				this._dragging)
			{
				x = event.stageX;
				y = event.stageY;
				
				Displays.panBy(this._object,
					x - this._evtX,
					y - this._evtY);
				
				this._evtX = x;
				this._evtY = y;
			}
		}
	}
}