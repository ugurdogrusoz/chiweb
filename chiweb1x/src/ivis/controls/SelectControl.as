package ivis.controls
{	
	import flare.vis.controls.Control;
	import flare.vis.controls.SelectionControl;
	import flare.vis.data.DataSprite;
	import flare.vis.events.SelectionEvent;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import ivis.event.ControlEvent;
	import ivis.manager.GlobalConfig;
	import ivis.manager.GraphManager;
	import ivis.model.Node;

	/**
	 * Multiple selection (rubber-band) control for DataSprite instances.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class SelectControl extends EventControl
	{		
		/**
		 * Indicates whether the selection rectangle is active. 
		 */
		protected var _enclosing:Boolean;
		
		/**
		 * Shape to visualize multiple selection rectangle.
		 */
		protected var _enclosingShape:Shape;
		
		/**
		 * Enclosing rectangular area for multiple selection.
		 */
		protected var _enclosingRect:Rectangle;
		
		//-------------------------- CONSTRUCTOR -------------------------------
		
		public function SelectControl(graphManager:GraphManager,
			stateManager:StateManager,
			filter:* = null)
		{
			super(graphManager, stateManager);
			this.filter = filter;
			
			this._enclosing = false;
			this._enclosingShape = new Shape();
			this._enclosingRect = new Rectangle();
			//this.fireImmediately = false;
		}
		
		//----------------------- PUBLIC FUNCTIONS -----------------------------
		
		/** @inheritDoc */
		public override function attach(obj:InteractiveObject):void
		{
			if (obj == null ||
				!(obj is DisplayObjectContainer))
			{
				detach();
				return;
			}
			
			super.attach(obj);
			
			if (obj != null)
			{
				obj.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			}
		}
		
		/** @inheritDoc */
		public override function detach():InteractiveObject
		{
			if (this.object != null)
			{
				this.object.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
			}
			
			return super.detach();
		}
		
		//----------------------- PROTECTED FUNCTIONS --------------------------
		
		/**
		 * Listener function for MOUSE_DOWN event. Adds listeners for MOUSE_UP
		 * and MOUSE_MOVE events, and updates the enclosing rectangle.
		 * 
		 * @param evt	MouseEvent that triggered the action
		 */
		protected function onDown(evt:MouseEvent):void
		{
			trace("[SelectControl.onDown] target: " + evt.target);
			
			if (this.object != null &&
				this.stateManager.checkState(StateManager.SELECT) &&
				!(evt.target is DataSprite))
			{
				this.object.addEventListener(MouseEvent.MOUSE_UP, onUp);
				this.object.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
				
				this._enclosingRect.x = this.object.mouseX;
				this._enclosingRect.y = this.object.mouseY;
				this._enclosingRect.width = 0;
				this._enclosingRect.height = 1;
				
				this._enclosing = true;
				
				(this.object as DisplayObjectContainer).addChild(
					this._enclosingShape);
				
				this.renderEncloser(this._enclosingShape);
				
				/*
				if (fireImmediately) {
					selectionTest(evt);
				}
				*/
				
				if (!this.stateManager.checkState(StateManager.SELECT_KEY_DOWN))
				{
					this.graphManager.resetSelected();
				}
				
				this.stateManager.setState(StateManager.SELECTING, true);
				// dispatch event on the interactive object
				this.object.dispatchEvent(
					new ControlEvent(ControlEvent.SELECT_START));
			}
			
			/*
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
			*/
		}
		
		/**
		 * Listener function for MOUSE_UP event. Finds the elements enclosed
		 * by the enclosing rectangle.
		 * 
		 * @param evt	MouseEvent that triggered the action
		 */
		protected function onUp(evt:MouseEvent):void
		{
			// when mouse up, the enclosing rectangle becomes inactive
			this._enclosing = false;
			
			//if (!fireImmediately)
			//	selectionTest(evt);
			
			if (this.object != null)
			{
				// select each element within the enclosing rectangle
				for each (var item:Object in 
					this.enclosedObjects(this.object))
				{
					this.graphManager.selectElement(item);
				}
				
				// remove the shape
				(this.object as DisplayObjectContainer).removeChild(
					this._enclosingShape);
				
				this.object.removeEventListener(MouseEvent.MOUSE_UP, onUp);
				this.object.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
				
				this.stateManager.setState(StateManager.SELECTING, false);
				
				// dispatch event on the interactive object
				this.object.dispatchEvent(
					new ControlEvent(ControlEvent.SELECT_END));
			}
		}
		
		/**
		 * Listener function for MOUSE_MOVE event. Updates the bounds of
		 * enclosing rectangle.
		 * 
		 * @param evt	MouseEvent that triggered the action
		 */
		protected function onMove(evt:MouseEvent):void
		{
			if (this._enclosing &&
				this.stateManager.checkState(StateManager.SELECT))
			{
				this._enclosingRect.width = this.object.mouseX -
					this._enclosingRect.x;
				
				this._enclosingRect.height = this.object.mouseY - 
					this._enclosingRect.y;
			
				this.renderEncloser(this._enclosingShape);
				
				/*
				if (fireImmediately) {
					selectionTest(evt);
				}
				*/
			}
		}
		
		/**
		 * Renders the given shape (enclosing rectangle).
		 * 
		 * @param shape	shape (rectangle) to render 
		 */
		protected function renderEncloser(shape:Shape):void
		{
			var lineColor:uint = this.graphManager.globalConfig.getConfig(
				GlobalConfig.ENCLOSING_LINE_COLOR);
			
			var lineAlpha:Number = this.graphManager.globalConfig.getConfig(
				GlobalConfig.ENCLOSING_LINE_ALPHA);
			
			var lineWidth:Number = this.graphManager.globalConfig.getConfig(
				GlobalConfig.ENCLOSING_LINE_WIDTH);
			
			var fillColor:uint = this.graphManager.globalConfig.getConfig(
				GlobalConfig.ENCLOSING_FILL_COLOR);
			
			var fillAlpha:Number = this.graphManager.globalConfig.getConfig(
				GlobalConfig.ENCLOSING_FILL_ALPHA);			
			
			
			shape.graphics.clear();
			
			shape.graphics.beginFill(fillColor, fillAlpha);
			
			shape.graphics.lineStyle(lineWidth,
				lineColor,
				lineAlpha,
				true,
				"none");
			
			shape.graphics.drawRect(_enclosingRect.x,
				_enclosingRect.y,
				_enclosingRect.width,
				_enclosingRect.height);
			
			shape.graphics.endFill();
		}
		
		/**
		 * Collects the elements enclosed by the enclosing rectangle and
		 * returns the collection as an array of DisplayObject instances.
		 * 
		 * @param displayObj	root display object
		 * @return				elements enclosed by the enclosing rectangle
		 */
		protected function enclosedObjects(displayObj:DisplayObject):Array
		{
			var objects:Array = new Array();
			
			// perform a hit test to check if the object is enclosed by the 
			// enclosing rectangle
			if (displayObj.hitTestObject(this._enclosingShape))
			{
				objects.push(displayObj);
			}
			
			// if current display object is a container, recursively check
			// for the child objects for an hit test
			if (displayObj is DisplayObjectContainer)
			{
				var container:DisplayObjectContainer = 
					displayObj as DisplayObjectContainer;
				
				for (var i:uint = 0; i < container.numChildren; i++)
				{
					objects = objects.concat(
						this.enclosedObjects(container.getChildAt(i)));
				}
			}
			
			// retunr collected objects
			return objects;
		}
		
		// TODO not used anymore
		protected function select(evt:SelectionEvent):void
		{
			trace("[SelectControl.select] item count: " + evt.items.length);
			
			/*
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
			*/
			
			
			for each (var item:Object in evt.items)
			{
				this.graphManager.selectElement(item);
			}
		}
		
		// TODO not used anymore
		protected function deselect(evt:SelectionEvent):void
		{
			trace("[SelectControl.deselect] item count: " + evt.items.length);
			var deselect:Boolean = true;
			
			/*
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
			*/
			
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