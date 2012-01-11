package ivis.controls
{
	import flash.events.EventDispatcher;
	
	import ivis.event.ControlEvent;

	/**
	 * This class is designed to manage action states and to be used by 
	 * the control classes to check certain states of the application.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class StateManager extends EventDispatcher
	{
		/** String constants for the default states. */
		public static const SELECT:String = "select";
		public static const ADD_NODE:String = "addNode";
		public static const ADD_BENDPOINT:String = "addBendpoint";
		public static const ADD_EDGE:String = "addEdge";
		public static const PAN:String = "pan";
		public static const SELECTING:String = "selecting";
		public static const PANNING:String = "panning";
		public static const DRAGGING:String = "dragging";
		public static const ADDING_EDGE:String = "addingEdge";
		public static const AUTO_COMPOUND:String = "autoCompound";
		public static const SELECT_KEY_DOWN:String = "selectKeyDown";
		
		/**
		 * Map of flags to indicate the states of certain actions.
		 */
		protected var _stateMap:Object;
		
		//-------------------------- CONSTRUCTOR -------------------------------
		
		/**
		 * Instantiate a new StateManager by initializing default states.
		 */
		public function StateManager()
		{
			this._stateMap = new Object();
			this.initDefaultStates();
		}
		
		//----------------------- PUBLIC FUNCTIONS -----------------------------
		
		/**
		 * Checks the state for the given name. If no state value is found for
		 * the given name, returns false. If value is found, return the value.
		 * 
		 * @param name	name of the state
		 * @return		value of the state (true or false) 
		 */
		public function checkState(name:String):Boolean
		{
			var state:Boolean = false;
			
			if (this._stateMap[name] != null)
			{
				state = this._stateMap[name];
			}
			
			return state;
		}
		
		/**
		 * Sets the state for the given name and value pair.
		 * 
		 * Note that, setting SELECT state on while another state is also on
		 * may cause problems for some controls.
		 * 
		 * @param name	name of the state
		 * @param value	value of the state
		 */
		public function setState(name:String, value:Boolean):void
		{
			this._stateMap[name] = value;
			
			if (this.hasEventListener(ControlEvent.CHANGED_STATE))
			{
				this.dispatchEvent(new ControlEvent(
					ControlEvent.CHANGED_STATE,
					{state: name, value: value}));
			}
		}
		
		/**
		 * Toggles the value of the given state. If the value of the state is 
		 * false, it becomes true after toggling. If the value is true, it
		 * becomes false.
		 * 
		 * Invoking this function with default parameters results in resetting 
		 * all other states. For an advanced state toggling, this fucntion 
		 * can be invoked with different combinations of reset and toggleSelect
		 * flags. However turning on SELECT state while another state is on
		 * may prevent a control to perform properly. 
		 * 
		 * In order to change a value of a single state only, use setState
		 * method instead.
		 * 
		 * @param name			name of the state
		 * @param reset			indicates whether all other states to be reset
		 * 						to their initial values
		 * @param toggleSelect  indicates whether SELECT state to be toggled
		 * @return		value of the state after toggling 
		 */
		public function toggleState(name:String,
			reset:Boolean = true,
			toggleSelect:Boolean = true):Boolean
		{
			var state:Boolean = false;
			
			if (this._stateMap[name] != null)
			{
				state = this._stateMap[name];
				
				if (reset)
				{
					// reset states to initial condition
					this.resetStates();
				}
				
				if (toggleSelect)
				{
					// turning any state ON should turn select state OFF,
					// turning a state OFF should turn select state ON...
					this.setState(StateManager.SELECT, state);
				}
				
				this.setState(name, !state);
				state = !state;
			}
			
			return state;
		}
		
		//----------------------- PROTECTED FUNCTIONS --------------------------
		
		/**
		 * Resets all states other than SELECT in the state map to false.
		 * SELECT state is reset to true. 
		 */
		protected function resetStates():void
		{
			// keep AUTO_COMPOUND & SELECT_KEY_DOWN as they are
			var autoCompound:Boolean =
				this._stateMap[StateManager.AUTO_COMPOUND];
			
			var selectKey:Boolean =
				this._stateMap[StateManager.SELECT_KEY_DOWN];
			
			// reset all states (including custom states)
			for (var name:String in this._stateMap)
			{
				this._stateMap[name] = false;
			}
			
			// SELECT state is true by default
			this._stateMap[StateManager.SELECT] = true;
			
			// restore AUTO_COMPOUND & SELECT_KEY_DOWN states
			this._stateMap[StateManager.AUTO_COMPOUND] = autoCompound;
			this._stateMap[StateManager.SELECT_KEY_DOWN] = selectKey;
			
			if (this.hasEventListener(ControlEvent.RESET_STATES))
			{
				this.dispatchEvent(new ControlEvent(
					ControlEvent.RESET_STATES));
			}
		}
		
		/**
		 * Initializes default states for the state map.
		 */
		protected function initDefaultStates():void
		{
			this._stateMap[StateManager.ADD_NODE] = false;
			this._stateMap[StateManager.ADD_BENDPOINT] = false;
			this._stateMap[StateManager.ADD_EDGE] = false;
			this._stateMap[StateManager.SELECT_KEY_DOWN] = false;
			this._stateMap[StateManager.PAN] = false;
			this._stateMap[StateManager.SELECTING] = false;
			this._stateMap[StateManager.PANNING] = false;
			this._stateMap[StateManager.DRAGGING] = false;
			this._stateMap[StateManager.ADDING_EDGE] = false;
		
			// SELECT state is true by default
			this._stateMap[StateManager.SELECT] = true;
			
			// AUTO_COMPOUND state is true by default
			this._stateMap[StateManager.AUTO_COMPOUND] = true;
		}
	}
}