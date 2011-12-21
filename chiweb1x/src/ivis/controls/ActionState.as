package ivis.controls
{
	/**
	 * This class is designed to indicate the state of the actions and used by 
	 * the control classes to check certain states of the application.
	 * 
	 * TODO enable additional custom state flags
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class ActionState
	{
		public static const ADD_NODE:String = "addNode";
		public static const ADD_BENDPOINT:String = "addBendpoint";
		public static const ADD_EDGE:String = "addEdge";
		public static const SELECT:String = "select";
		
		// flags to indicate the states of certain actions
		protected var _addNode:Boolean;
		protected var _addBendPoint:Boolean;
		protected var _addEdge:Boolean;
		protected var _select:Boolean;
		
		protected var _selectKeyDown:Boolean;
		//protected var _enclosing:Boolean;
		//protected var _mouseDown:Boolean;
		
		public function ActionState()
		{
			this.resetStates();
			this._selectKeyDown = false;
			//this._enclosing = false;
			//this._mouseDown = false;
		}
		
		public function get isAddNode():Boolean
		{
			return _addNode;
		}
		
		public function get isAddBendPoint():Boolean
		{
			return _addBendPoint;
		}
		
		public function get isAddEdge():Boolean
		{
			return _addEdge;
		}
		
		public function get isSelect():Boolean
		{
			return _select;
		}
		
		
		public function get selectKeyDown():Boolean
		{
			return _selectKeyDown;
		}
		
		public function set selectKeyDown(value:Boolean):void
		{
			this._selectKeyDown = value;
		}
		
		/*
		public function get mouseDown():Boolean
		{
			return _mouseDown;
		}
		
		public function set mouseDown(value:Boolean):void
		{
			this._mouseDown = value;
		}
		
		
		public function get enclosing():Boolean
		{
			return _enclosing;
		}
		
		public function set enclosing(value:Boolean):void
		{
			this._enclosing = value;
		}
		*/
		
		public function toggleAddNode():Boolean
		{
			var state:Boolean = this._addNode;
			
			this.resetStates();
			this._select = state;
			this._addNode = !state;
			
			return this._addNode;
		}
		
		public function toggleAddBendPoint():Boolean
		{
			var state:Boolean = this._addBendPoint;
			
			this.resetStates();
			this._select = state;
			this._addBendPoint = !state;
			
			return this._addBendPoint;
		}
		
		public function toggleAddEdge():Boolean
		{
			var state:Boolean = this._addEdge;
			
			this.resetStates();
			this._select = state;
			this._addEdge = !state;
			
			return this._addEdge;
		}
		
		public function toggleSelect():Boolean
		{
			var state:Boolean = this._select;
			
			this.resetStates();
			this._select = !state;
			
			return this._select;
		}
		
		protected function resetStates():void
		{
			this._addNode = false;
			this._addBendPoint = false;
			this._addEdge = false;
			this._select = true;
		}
	}
}