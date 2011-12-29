package ivis.controls
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	
	import ivis.manager.GraphManager;
	
	import mx.core.Container;
	import mx.core.UIComponent;

	/**
	 * Control class to monitor resize of the view container.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class ResizeControl extends EventControl
	{
		//-------------------------- CONSTRUCTOR -------------------------------
		
		public function ResizeControl(graphManager:GraphManager,
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
		 * Listener for RESIZE event. Updates the hit area of the view upon
		 * resize.
		 *
		 * @param evt	Event that triggered the action 
		 */
		protected function onResize(evt:Event):void
		{
			if (this.object.stage != null)
			{
				this.graphManager.view.updateHitArea();
			}
		}
		
		/**
		 * Listener for ADDED_TO_STAGE event. Invoked when the interactive
		 * object, to which this control is attached, is added to the stage.
		 *
		 * @param evt	Event that triggered the action 
		 */
		protected function onAdd(evt:Event = null):void
		{
			if (this.graphManager.view.parent != null)
			{
				this.graphManager.view.parent.addEventListener(
					Event.RESIZE, onResize);
				
				this.graphManager.view.updateHitArea();
			}
		}
		
		/**
		 * Listener for REMOVED_FROM_STAGE event. Invoked when the interactive
		 * object, to which this control is attached, is removed from the stage.
		 * 
		 * @param evt	Event that triggered the action
		 */
		protected function onRemove(evt:Event = null):void
		{
			if (this.object.parent != null)
			{
				this.graphManager.view.parent.removeEventListener(
					Event.RESIZE, onResize);
			}
		}
	}
}