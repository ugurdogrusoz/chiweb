package controls
{
	import flash.display.InteractiveObject;
	
	import ivis.controls.EventControl;
	import ivis.event.ControlEvent;
	
	import mx.managers.CursorManager;
	import mx.managers.CursorManagerPriority;
	
	import util.CursorUtils;

	/**
	 * Control class to enable/disable custom cursors, upon specific events.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class CursorControl extends EventControl
	{
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
				obj.addEventListener(ControlEvent.DRAG_START, onDragStart);
				obj.addEventListener(ControlEvent.DRAG_END, onDragEnd);
				obj.addEventListener(ControlEvent.PAN_START, onPanStart);
				obj.addEventListener(ControlEvent.PAN_END, onPanEnd);
			}
		}
		
		/** @inheritDoc */
		public override function detach():InteractiveObject
		{
			if (this.object != null)
			{
				this.object.removeEventListener(ControlEvent.DRAG_START,
					onDragStart);
				
				this.object.removeEventListener(ControlEvent.DRAG_END,
					onDragEnd);
				
				this.object.removeEventListener(ControlEvent.PAN_START,
					onPanStart);
				
				this.object.removeEventListener(ControlEvent.PAN_END,
					onPanEnd);
			}
			
			return super.detach();
		}
		
		/**
		 * Listener for PAN_START control event. Shows closed hand cursor when
		 * panning starts.
		 */
		protected function onPanStart(event:ControlEvent):void
		{
			CursorUtils.showClosedHand();
		}
		
		/**
		 * Listener for PAN_START control event. Hides closed hand cursor when
		 * panning ends.
		 */
		protected function onPanEnd(event:ControlEvent):void
		{
			CursorUtils.hideClosedHand();
		}
		
		/**
		 * Listener for DRAG_START control event. Shows closed hand cursor when
		 * dragging starts.
		 */
		protected function onDragStart(event:ControlEvent):void
		{
			CursorUtils.showClosedHand();
		}
		
		/**
		 * Listener for DRAG_END control event. Hides closed hand cursor when
		 * dragging ends.
		 */
		protected function onDragEnd(event:ControlEvent):void
		{
			CursorUtils.hideClosedHand();
		}
	}
}