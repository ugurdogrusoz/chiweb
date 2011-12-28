package ivis.controls
{
	import flare.util.Displays;
	import flare.vis.Visualization;
	
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import ivis.manager.GraphManager;

	public class ZoomControl extends EventControl
	{	
		public function ZoomControl(graphManager:GraphManager,
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
			// TODO add a pan/zoom control panel and add listener on button clicks?
			// TODO customizable event or a zoom slider for zoom action?
			_object.stage.addEventListener(MouseEvent.MOUSE_WHEEL,
				onMouseWheel);
			
			if (_object is Visualization)
			{
				// disable automatic hit area calculation
				_object.stage.removeEventListener(Event.RENDER,
					this.graphManager.view.vis.setHitArea);
			}
			
			this.graphManager.view.updateHitArea();
		}
		
		protected function onRemove(evt:Event = null):void
		{
			_object.stage.removeEventListener(MouseEvent.MOUSE_WHEEL,
				onMouseWheel);
			
			if (_object is Visualization)
			{
				// restore autmoatic hit area calculator
				_object.stage.addEventListener(Event.RENDER,
					this.graphManager.view.vis.setHitArea);
			}
		}
		
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