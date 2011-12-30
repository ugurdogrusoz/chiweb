package ivis.manager
{
	import flare.vis.controls.IControl;
	import flare.vis.data.DataSprite;
	import flare.vis.data.NodeSprite;
	
	import ivis.controls.ClickControl;
	import ivis.controls.CustomControl;
	import ivis.controls.EventControl;
	import ivis.controls.KeyControl;
	import ivis.controls.MultiDragControl;
	import ivis.controls.PanControl;
	import ivis.controls.ResizeControl;
	import ivis.controls.SelectControl;
	import ivis.controls.StateManager;
	import ivis.controls.ZoomControl;

	/**
	 * This class is designed to manage Controls that can be attached to and
	 * detached from the visualization. By default, 4 predefined controls are
	 * attached to the visualization. It is possible to define and add new
	 * controls using this class. It is also possible to define and add custom
	 * listener functions for specific events.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class ControlCenter
	{
		public static const CLICK_CONTROL:String = "clickControl";
		public static const DRAG_CONTROL:String = "dragControl";
		public static const SELECT_CONTROL:String = "selectControl";
		public static const KEY_CONTROL:String = "keyControl";
		public static const ZOOM_CONTROL:String = "zoomControl";
		public static const PAN_CONTROL:String = "panControl";
		public static const RESIZE_CONTROL:String = "resizeControl";
		
		protected var _graphManager:GraphManager;
		
		protected var _stateManager:StateManager;
		
		/**
		 * Map of default controls
		 */
		protected var _defaultControls:Object;
		
		/**
		 * Map of controls for custom listeners.
		 */
		protected var _customControls:Object;
		
		//--------------------------- ACCESSORS --------------------------------
		
		/**
		 * Contains the information about the current state of actions.
		 */
		public function get stateManager():StateManager
		{
			return _stateManager;
		}
		
		//------------------------- CONSTRUCTOR --------------------------------
		
		/**
		 * Initializes the control center for the given GraphManager.
		 * 
		 * @param graphManager	a GraphManager instance
		 */
		public function ControlCenter(graphManager:GraphManager)
		{
			// set manager
			this._graphManager = graphManager;
			
			// init action state manager
			this._stateManager = new StateManager();
			
			// init custom listener map
			this._customControls = new Object();
			
			// init default controls
			this._defaultControls = new Object();
			
			this._defaultControls[ControlCenter.KEY_CONTROL] =
				new KeyControl(this._graphManager, this._stateManager);
			
			this._defaultControls[ControlCenter.ZOOM_CONTROL] =
				new ZoomControl(this._graphManager, this._stateManager);
			
			this._defaultControls[ControlCenter.PAN_CONTROL] =
				new PanControl(this._graphManager, this._stateManager);
			
			this._defaultControls[ControlCenter.RESIZE_CONTROL] =
				new ResizeControl(this._graphManager, this._stateManager);
			
			this._defaultControls[ControlCenter.CLICK_CONTROL] =
				new ClickControl(this._graphManager, this._stateManager);
			
			this._defaultControls[ControlCenter.DRAG_CONTROL] = 
				new MultiDragControl(this._graphManager,
					this._stateManager,
					NodeSprite); 
			
			this._defaultControls[ControlCenter.SELECT_CONTROL] =
				new SelectControl(this._graphManager,
					this._stateManager,
					DataSprite);
			
			// add default controls to the visualization
			
			this.addControl(_defaultControls[ControlCenter.SELECT_CONTROL]);
			this.addControl(_defaultControls[ControlCenter.CLICK_CONTROL]);
			this.addControl(_defaultControls[ControlCenter.DRAG_CONTROL]);
			this.addControl(_defaultControls[ControlCenter.KEY_CONTROL]);
			this.addControl(_defaultControls[ControlCenter.ZOOM_CONTROL]);
			this.addControl(_defaultControls[ControlCenter.PAN_CONTROL]);
			this.addControl(_defaultControls[ControlCenter.RESIZE_CONTROL]);
		}
		
		//------------------------ PUBLIC FUNCTIONS ----------------------------
		
		/**
		 * Adds a custom control to the visualization.
		 * 
		 * @param control	custom control to be added
		 */
		public function addControl(control:IControl):void
		{
			if (control is EventControl)
			{
				var ec:EventControl = control as EventControl;
				
				// set graph manager of the event, if it is not set yet
				if (ec.graphManager == null)
				{
					ec.graphManager = this._graphManager;
				}
				
				// set state manager of the event, if it is not set yet
				if (ec.stateManager == null)
				{
					ec.stateManager = this._stateManager;
				}
			}
			
			// first, remove the control to avoid duplications
			this._graphManager.removeControl(control);
			
			// add control to the visualization
			this._graphManager.addControl(control);
		}
		
		/**
		 * Removes an existing custom control from the visualization. It is not
		 * possible to remove a default control by this method. Use the method
		 * disableDefaultControl instead to disable a certain default control.
		 * 
		 * @param control	custom control to be removed
		 */
		public function removeControl(control:IControl):IControl
		{	
			// do not allow a default control to be removed manually
			for each (var defaultControl:IControl in this._defaultControls)
			{
				if (control == defaultControl)
				{
					return null;
				}
			}
			
			// remove any other control
			return this._graphManager.removeControl(control);
		}
		
		/**
		 * Returns the default control for the given name. If no default control
		 * is found matching the given name, returns null.
		 * 
		 * @param name	name of the default control
		 * @return		EventControl for the given name if found, null otherwise
		 */
		public function getDefaultControl(name:String):EventControl
		{
			return this._defaultControls[name];
		}
		
		/**
		 * Enables the default control with the given name.
		 * 
		 * @param name	name of the default control
		 */
		public function enableDefaultControl(name:String):void
		{
			if (this._defaultControls[name] != null)
			{
				this.enableControl(this._defaultControls[name]);
			}
		}
		
		/**
		 * Disables the default control with the given name.
		 * 
		 * @param name	name of the default control
		 */
		public function disableDefaultControl(name:String):void
		{
			if (this._defaultControls[name] != null)
			{
				this.disableControl(this._defaultControls[name]);
			}
		}
		
		/**
		 * Adds a custom listener function for the specified event.
		 * 
		 * @param controlName	desired name for the custom control
		 * @param eventName		name of the event
		 * @param listenerFn	custom listener function
		 * @param filter		filter for the event
		 */
		public function addCustomListener(controlName:String,
			eventName:String,
			listenerFn:Function,
			filter:*=null):void
		{
			// check for the same controlName and remove previous control
			
			var custom:IControl = _customControls[controlName];
			
			if (custom != null)
			{
				this.removeControl(custom);
			}
			
			// create and add the new Control for the given controlName
			
			custom = new CustomControl(eventName,
				listenerFn,
				filter);
			
			this.addControl(custom);
			this._customControls[controlName] = custom;
		}
		
		/**
		 * Removes the custom listener associated with the given name.
		 * 
		 * @param controlName	name of the custom listener
		 */
		public function removeCustomListener(controlName:String):void
		{
			var custom:IControl = this._customControls[controlName];
			
			if (custom != null)
			{
				this.removeControl(custom);
				delete this._customControls[controlName];
			}
		}
		
		/**
		 * Toggles the given state.
		 * 
		 * @param name			name of the state
		 * @param reset			indicates whether all other states to be reset
		 * 						to their initial values
		 * @param toggleSelect  indicates whether SELECT state to be toggled
		 * @return		state condition after toggling
		 */
		public function toggleState(name:String,
			reset:Boolean = true,
			toggleSelect:Boolean = true):Boolean
		{
			return this.stateManager.toggleState(name,
				reset,
				toggleSelect);
		}
		
		//------------------------ PROTECTED FUNCTIONS -------------------------
		
		/**
		 * Enables the given default control.
		 * 
		 * @param control	one of the default controls
		 */
		protected function enableControl(control:IControl):void
		{
			// first, remove the control to avoid duplicate controls
			this._graphManager.removeControl(control);
			
			// add the control again
			this._graphManager.addControl(control);
		}
		
		/**
		 * Disables the given default control.
		 * 
		 * @param control	one of the default controls 
		 */
		protected function disableControl(control:IControl):void
		{
			// remove the control from the visualization
			this._graphManager.removeControl(control);
		}
	}
}