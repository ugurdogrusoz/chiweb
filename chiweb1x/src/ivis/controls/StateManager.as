package ivis.controls
{
	import flash.system.System;

	/**
	 * This class is designed to manage action states and to be used by 
	 * the control classes to check certain states of the application.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class StateManager
	{
		// name of the default states
		public static const ADD_NODE:String = "addNode";
		public static const ADD_BENDPOINT:String = "addBendpoint";
		public static const ADD_EDGE:String = "addEdge";
		public static const SELECT:String = "select";
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
		 * @param name	name of the state
		 * @param value	value of the state
		 */
		public function setState(name:String, value:Boolean):void
		{
			this._stateMap[name] = value;
		}
		
		/**
		 * Toggles the value of the given state. If value of the state is false,
		 * it becomes true after toggling. If value is true, it becomes false.
		 * 
		 * @param name	name of the state
		 * @return		value of the state after toggling 
		 */
		public function toggleState(name:String):Boolean
		{
			var state:Boolean = false;
			
			if (this._stateMap[name] != null)
			{
				state = this._stateMap[name];
				this.resetStates();
				
				// turning any state ON should turn select state OFF,
				// turning a state OFF should turn select state ON...
				this._stateMap[StateManager.SELECT] = state;
				
				this._stateMap[name] = !state;
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
			for (var name:String in this._stateMap)
			{
				this._stateMap[name] = false;
			}
			
			// select state is true by default
			this._stateMap[StateManager.SELECT] = true;
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
		
			// select state is true by default
			this._stateMap[StateManager.SELECT] = true;
		}
	}
}