package ivis.controls
{
	import flare.util.Displays;
	import flare.vis.Visualization;
	
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import ivis.manager.GlobalConfig;
	import ivis.manager.GraphManager;

	/**
	 * Control class for zooming the view. By default this control listens to
	 * MOUSE_WHEEL events, and zooms the view upon the mouse wheel is turned.
	 * It is possible to customize the event, and the event listener function
	 * by setting corresponding attributes of this control.
	 * 
	 * To provide another interface for zooming, define your own controls 
	 * (a slider for example), and use zoomView method of the GraphManager
	 * class.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class ZoomControl extends EventControl
	{
		/**
		 * Name of the zoom event to listen.
		 */
		protected var _zoomEvent:String;
		
		/**
		 * Listener function for the zoom event.
		 */
		protected var _zoomListener:Function;
		
		/**
		 * Flag to indicate whether the zoom listener to be added directly
		 * to the interactive object or to be added to its stage.
		 */
		protected var _addToStage:Boolean;
		
		//-------------------------- CONSTRUCTOR -------------------------------
		
		/**
		 * Instantiates a new ZoomControl.
		 * 
		 * @param graphManager	graph manager
		 * @param stateManager	state manager
		 * @param filter		filter function
		 * @param zoomEvent		name of the event to trigger the zoom action
		 * @param zoomListener	listener function for the zoom event
		 * @param addToStage	indicates if the provided listener to be added
		 * 						directly to the interactive object or to be
		 * 						added to its stage
		 */
		public function ZoomControl(graphManager:GraphManager,
			stateManager:StateManager,
			filter:* = null,
			zoomEvent:String = MouseEvent.MOUSE_WHEEL,
			zoomListener:Function = null,
			addToStage:Boolean = true)
		{
			super(graphManager, stateManager);
			this.filter = filter;
			
			this._zoomEvent = zoomEvent;
			this._addToStage = addToStage;
			
			if (zoomListener == null)
			{
				this._zoomListener = onZoom;
			}
			else
			{
				this._zoomListener = zoomListener;
			}
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
		
		public function setZoomEvent(eventName:String,
			listener:Function = null,
			addToStage:Boolean = true):void
		{
			// remove previous listeners
			
			if (this.object != null)
			{
				this.object.removeEventListener(this._zoomEvent,
					this._zoomListener);
				
				if (this.object.stage != null)
				{
					this.object.stage.removeEventListener(this._zoomEvent,
						this._zoomListener);
				}
			}
			
			// add new listener
			
			this._zoomEvent = eventName;
			
			if (listener != null)
			{
				this._zoomListener = listener;
			}
			
			this._addToStage = addToStage;
			
			if (this.object != null)
			{
				if (addToStage)
				{
					if (this.object.stage != null)
					{
						this.onAdd();
					}
				}
				else
				{
					_object.addEventListener(this._zoomEvent,
						this._zoomListener);
				}
			}
			
			
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
			if (this._addToStage)
			{
				_object.stage.addEventListener(this._zoomEvent,
					this._zoomListener);
			}
			else
			{
				_object.addEventListener(this._zoomEvent,
					this._zoomListener);
			}
			
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
			// remove zoom listener from both the object and its stage,
			// just in case
			
			this.object.stage.removeEventListener(this._zoomEvent,
				this._zoomListener);
			
			this.object.removeEventListener(this._zoomEvent,
				this._zoomListener);
			
			
			if (this.object is Visualization)
			{
				// restore autmoatic hit area calculator
				this.object.stage.addEventListener(Event.RENDER,
					this.graphManager.view.vis.setHitArea);
			}
		}
		
		/**
		 * Default listener function for zoom event.
		 * 
		 * @param evt	Event that triggered the action
		 */
		protected function onZoom(evt:Event):void
		{
			var delta:Number;
			var scale:Number;
			
			if (evt is MouseEvent)
			{
				delta = (evt as MouseEvent).delta;
			}
			else
			{
				return;
			}
			
			// mouse wheel backward
			if (delta < 0)
			{
				// zoom-out
				scale = this.graphManager.globalConfig.getConfig(
					GlobalConfig.ZOOM_SCALE);
			}
			// mouse wheel forward
			else
			{
				// zoom-in
				scale = 1 / this.graphManager.globalConfig.getConfig(
					GlobalConfig.ZOOM_SCALE);
			}
			
			// zoom view
			Displays.zoomBy(this._object, scale);
			
			// update hit area of the visualization
			this.graphManager.view.updateHitArea();
			
			// update view without updating compound bounds
			this.graphManager.view.update(false);
		}
	}
}