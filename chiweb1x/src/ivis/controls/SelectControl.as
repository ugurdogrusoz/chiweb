package ivis.controls
{	
	import flare.vis.controls.Control;
	import flare.vis.controls.SelectionControl;
	import flare.vis.data.DataSprite;
	import flare.vis.events.SelectionEvent;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	
	import ivis.model.Node;
	import ivis.manager.GraphManager;

	/**
	 * Multiple selection (rubber-band) control for DataSprite instances.
	 * 
	 * @author Selcuk Onur Sumer 
	 */
	public class SelectControl extends SelectionControl
	{
		protected var _graphManager:GraphManager;
		protected var _stateManager:StateManager;
		
		/**
		 * Indicates whether the selection rectangle is active 
		 */
		protected var _enclosing:Boolean;
		
		public function get graphManager():GraphManager
		{
			return _graphManager;
		}
		
		public function set graphManager(value:GraphManager):void
		{
			_graphManager = value;
		}
		
		public function get stateManager():StateManager
		{
			return _stateManager;
		}
		
		public function set stateManager(value:StateManager):void
		{
			_stateManager = value;
		}
		
		public function SelectControl(graphManager:GraphManager,
			stateManager:StateManager,
			filter:* = null)
		{
			super(filter, select, deselect);
			this._graphManager = graphManager;
			this._stateManager = stateManager;
			this._enclosing = false;
			//this.fireImmediately = false;
		}
		
		/** @inheritDoc */
		public override function attach(obj:InteractiveObject):void
		{
			if (obj == null)
			{
				detach();
				return;
			}
			
			super.attach(obj);
			
			if (obj != null)
			{
				obj.addEventListener(MouseEvent.MOUSE_UP, onUp);
				obj.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			}
		}
		
		/** @inheritDoc */
		public override function detach():InteractiveObject
		{
			if (_object != null)
			{
				_object.removeEventListener(MouseEvent.MOUSE_UP, onUp);
				_object.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
			}
			
			return super.detach();
		}
		
		protected function onDown(evt:MouseEvent):void
		{
			//var target:DisplayObject = evt.target as DisplayObject;
			
			trace(evt.target);
			
			if (evt.target is DataSprite ||
				!this.stateManager.checkState(StateManager.SELECT))
			{
				// this is required to prevent selection and also to prevent
				// deselect event to be dispatched when selection starts on a 
				// node or edge.
				evt.stopPropagation();
			}
			else if (!this.fireImmediately &&
				!this.stateManager.checkState(StateManager.SELECT_KEY_DOWN))
			{
				//TODO fireImmediately? this.view.resetSelected();
			}
		}
		
		protected function onUp(evt:MouseEvent):void
		{
			// when mouse up, the enclosing rectangle becomes inactive
			this._enclosing = false;
		}
		
		protected function select(evt:SelectionEvent):void
		{
			trace("[SelectControl.select] item count: " + evt.items.length);
			
			if (this.fireImmediately)
			{
				if (!this.stateManager.checkState(StateManager.SELECT_KEY_DOWN) &&
					!this._enclosing)
				{
					this.graphManager.resetSelected();
				}				
			
				this._enclosing = true;
			}
			else
			{
				// TODO when fireImmediately flag is false, because of the
				// flare's SelectionControl mechanism, it causes problems
				// in some cases. In order to support fireImmediately flag,
				// it is required to define a new SelectionControl instead
				// of extending flare's SelectionControl
			}
			
			
			
			for each (var item:Object in evt.items)
			{
				this.graphManager.selectElement(item);
			}
		}
		
		protected function deselect(evt:SelectionEvent):void
		{
			trace("[SelectControl.deselect] item count: " + evt.items.length);
			var deselect:Boolean = true;
			
			if (this.fireImmediately)
			{
				if (!this._enclosing)
				{
					if (!this.stateManager.checkState(StateManager.SELECT_KEY_DOWN))
					{
						this.graphManager.resetSelected();
					}
					
					this._enclosing = true;
					deselect = false;
				}
			}
			else
			{
				// TODO may need to re-implement the SelectControl in order to
				// use fireImmediately flag.
			}
			
			if (deselect)
			{
				for each (var item:Object in evt.items)
				{
					this.graphManager.deselectElement(item);
				}
			}
			
			/*
			if (!this._enclosing)
			{
				if (!this.state.selectKeyDown)
				{
					this.view.resetSelected();
				}
				
				this._enclosing = true;
			}
			else
			{
				for each (var item:Object in evt.items)
				{
					this.view.deselectElement(item);
				}
			}
			*/
		}
	}
}