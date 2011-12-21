package ivis.controls
{
	import flare.vis.controls.IControl;
	import flare.vis.data.DataSprite;
	import flare.vis.data.NodeSprite;
	
	import flash.events.Event;
	
	import ivis.view.GraphManager;

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
		
		protected var _manager:GraphManager;
		protected var _state:ActionState;
		
		// default controls
		protected var _keyControl:KeyControl;
		protected var _clickControl:ClickControl;
		protected var _dragControl:MultiDragControl;
		protected var _selectControl:SelectControl;
		
		/**
		 * Map of controls for custom listeners.
		 */
		protected var _customControls:Object;
		
		//--------------------------- ACCESSORS --------------------------------
		
		/**
		 * Contains the information about the current state of actions.
		 */
		public function get state():ActionState
		{
			return _state;
		}
		
		/**
		 * Initializes the control center for the given GraphManager
		 * 
		 * @param manager	a GraphManager instance
		 */
		public function ControlCenter(manager:GraphManager)
		{
			// set manager
			this._manager = manager;
			
			// init action state control
			this._state = new ActionState();
			
			// init custom listener map
			this._customControls = new Object();
			
			// init default controls
			
			this._keyControl = new KeyControl(_manager);
			this._clickControl = new ClickControl(_manager);
			this._dragControl = new MultiDragControl(_manager, NodeSprite); 
			this._selectControl = new SelectControl(_manager, DataSprite);
			
			this._clickControl.state = _state;
			this._keyControl.state = _state;
			this._selectControl.state = _state;
			//this._dragControl.state = _state;
			
			// add controls to the visualization
			
			this.addControl(_selectControl);
			this.addControl(_clickControl);
			this.addControl(_dragControl);
			this.addControl(_keyControl);
		}
		
		/**
		 * Adds a custom control to the visualization.
		 * 
		 * @param control	custom control to be added
		 */
		public function addControl(control:IControl):void
		{
			this._manager.addControl(control);
		}
		
		/**
		 * Removes an existing custom control from the visualization.
		 * 
		 * @param control	custom control to be removed
		 */
		public function removeControl(control:IControl):IControl
		{
			return this._manager.removeControl(control);
		}
		
		/**
		 * Enables the default control with the given name.
		 * 
		 * @param name	name of the default control
		 */
		public function enableDefaultControl(name:String):void
		{
			if (name === ControlCenter.CLICK_CONTROL)
			{
				this.enableControl(_clickControl);
			}
			else if (name === ControlCenter.SELECT_CONTROL)
			{
				this.enableControl(_selectControl);
			}
			else if (name === ControlCenter.DRAG_CONTROL)
			{
				this.enableControl(_dragControl);
			}
			else if (name === ControlCenter.KEY_CONTROL)
			{
				this.enableControl(_keyControl);
			}
		}
		
		/**
		 * Disables the default control with the given name.
		 * 
		 * @param name	name of the default control
		 */
		public function disableDefaultControl(name:String):void
		{
			if (name === ControlCenter.CLICK_CONTROL)
			{
				this.disableControl(_clickControl);
			}
			else if (name === ControlCenter.SELECT_CONTROL)
			{
				this.disableControl(_selectControl);
			}
			else if (name === ControlCenter.DRAG_CONTROL)
			{
				this.disableControl(_dragControl);
			}
			else if (name === ControlCenter.KEY_CONTROL)
			{
				this.disableControl(_keyControl);
			}
		}
		
		/**
		 * Enables the given default control.
		 * 
		 * @param control	one of the default controls
		 */
		protected function enableControl(control:IControl):void
		{
			// first, remove the control to avoid duplicate controls
			this.removeControl(control);
			
			// add the control again
			this.addControl(control);
		}
		
		/**
		 * Disables the given default control.
		 * 
		 * @param control	one of the default controls 
		 */
		protected function disableControl(control:IControl):void
		{
			// remove control from the visualization
			this.removeControl(control);
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
	}
}