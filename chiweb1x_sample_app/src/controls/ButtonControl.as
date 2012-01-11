package controls
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	
	import ivis.controls.EventControl;
	import ivis.controls.StateManager;
	import ivis.event.ControlEvent;
	
	import mx.core.Container;
	
	import util.CursorUtils;

	/**
	 * This class is designed as an EventControl class to manage button states
	 * of the main application container.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class ButtonControl extends EventControl
	{
		protected var _app:SampleApp;
		
		/**
		 * Root application container required to access buttons.
		 */
		public function set app(value:Container):void
		{
			if (value is SampleApp)
			{
				_app = value as SampleApp;
			}
			else
			{
				_app = null;
			}
		}
		
		//-------------------------- CONSTRUCTOR -------------------------------
		
		/**
		 * Instantiates a new button control for the provided application
		 * container.
		 */
		public function ButtonControl(application:Container)
		{
			this.app = application;
		}
		
		//----------------------- PUBLIC FUNCTIONS -----------------------------
		
		/** @inheritDoc */
		public override function attach(obj:InteractiveObject):void
		{
			if (obj == null)
			{
				detach();
				return;
			}
			
			super.attach(obj);
			
			if (obj != null &&
				this.stateManager != null)
			{
				// add listeners to adjust buttons
				this.stateManager.addEventListener(ControlEvent.RESET_STATES,
					onResetStates);
				
				this.stateManager.addEventListener(ControlEvent.CHANGED_STATE,
					onResetStates);
			}
		}
		
		/** @inheritDoc */
		public override function detach():InteractiveObject
		{
			if (this.object != null &&
				this.stateManager != null)
			{
				// add listeners to adjust buttons
				this.stateManager.removeEventListener(
					ControlEvent.RESET_STATES,
					onResetStates);
				
				this.stateManager.removeEventListener(
					ControlEvent.CHANGED_STATE,
					onResetStates);
			}
			
			return super.detach();
		}
		
		/**
		 * Listener function for RESET_STATES event. This function is to reset
		 * states of GUI buttons with respect to states of certain flags.
		 */
		protected function onResetStates(evt:Event):void
		{
			// reset button states
			this._app.select.selected = 
				this.stateManager.checkState(StateManager.SELECT);			
			this._app.addNode.selected = 
				this.stateManager.checkState(StateManager.ADD_NODE);
			this._app.addEdge.selected = 
				this.stateManager.checkState(StateManager.ADD_EDGE);
			this._app.addBendPoint.selected = 
				this.stateManager.checkState(StateManager.ADD_BENDPOINT);
			this._app.enablePan.selected = 
				this.stateManager.checkState(StateManager.PAN);
			
			// also reset custom cursors
			if (!this._app.enablePan.selected)
			{
				CursorUtils.hideOpenHand();
			}
		}
		
		/**
		 * Listener function for CHANGED_STATE event. This function is to change
		 * state of the "select" button.
		 */
		protected function onStateChange(evt:ControlEvent):void
		{
			if (evt.info.state == StateManager.SELECT)
			{
				this._app.select.selected = evt.info.value;
			}
		}
	}
}