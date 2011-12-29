package ivis.controls
{
	import flare.util.Displays;
	import flare.vis.Visualization;
	
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import ivis.manager.GraphManager;

	/**
	 * Control class for zooming the view.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class ZoomControl extends EventControl
	{
		//-------------------------- CONSTRUCTOR -------------------------------
		
		public function ZoomControl(graphManager:GraphManager,
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
			if (this.object != null)
			{
				this.object.removeEventListener(Event.ADDED_TO_STAGE,
					onAdd);
				this.object.removeEventListener(Event.REMOVED_FROM_STAGE,
					onRemove);
				
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
			// TODO add a pan/zoom control panel and add listener on button clicks?
			// TODO customizable event or a zoom slider for zoom action?
			_object.stage.addEventListener(MouseEvent.MOUSE_WHEEL,
				onMouseWheel);
			
			if (this.object is Visualization)
			{
				// disable automatic hit area calculation
				this.object.stage.removeEventListener(Event.RENDER,
					this.graphManager.view.vis.setHitArea);
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
			this.object.stage.removeEventListener(MouseEvent.MOUSE_WHEEL,
				onMouseWheel);
			
			if (this.object is Visualization)
			{
				// restore autmoatic hit area calculator
				this.object.stage.addEventListener(Event.RENDER,
					this.graphManager.view.vis.setHitArea);
			}
		}
		
		// TODO currently, zooming is performed when mouse wheel is moved but this should be customizable!
		protected function onMouseWheel(evt:MouseEvent):void
		{
			var delta:Number = evt.delta;
			var scale:Number;
			
			// mouse wheel backward
			if (delta < 0)
			{
				// zoom-out
				scale = 0.8;
				//scale = 0.5;
			}
			// mouse wheel forward
			else
			{
				// zoom-in
				scale = 1 / 0.8;
				//scale = 1 / 0.5;
			}
			
			// zoom view
			Displays.zoomBy(this._object, scale);
			
			// TODO update hit area of the visualization also after other operations if necessary
			this.graphManager.view.updateHitArea();
		}
	}
}