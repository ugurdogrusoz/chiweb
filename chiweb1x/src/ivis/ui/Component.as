package ivis.ui
{
	import ivis.model.GraphObject;
	import ivis.model.events.*;
	
	import mx.core.UIComponent;

	/**
	 * 
	 * @author Ebrahim
	 */
	public class Component extends UIComponent
	{
		
		/**
		 * 
		 * @default 
		 */
		private var _model: GraphObject;
		
		// visual cues are added as children..do we need a separate list?
//		private var _cues: Vector.<VisualCue>;
		//inspector
		
		/**
		 * 
		 * @default 
		 */
		private var _selected: Boolean;
		/**
		 * 
		 * @default 
		 */
		private var _highlighted: Boolean;
		
		/**
		 * 
		 * @param go
		 */
		public function Component(go: GraphObject = null)
		{
			super();
			
			this.model = go;
		}
		
		//
		// getters and setters
		//
		
		/**
		 * 
		 * @return 
		 */
		public function get selected(): Boolean
		{
			return this._selected;
		} 
		
		/**
		 * 
		 * @param s
		 */
		public function set selected(s: Boolean): void
		{
			this._selected = s;
		}
		
		/**
		 * 
		 * @return 
		 */
		public function get highlighted(): Boolean
		{
			return this._highlighted;
		}
		
		/**
		 * 
		 * @param h
		 */
		public function set highlighted(h: Boolean): void
		{
			this._highlighted = h;
		}
		
		/**
		 * 
		 * @return 
		 */
		public function get model(): GraphObject
		{
			return this._model;
		}
		
		/**
		 * 
		 * @param m
		 */
		public function set model(m: GraphObject): void
		{
			if(this._model != null)
			{
				this._model.removeEventListener(XChangeEvent, onModelXChanged);
				this._model.removeEventListener(YChangeEvent, onModelYChanged);
				this._model.removeEventListener(WidthChangeEvent, onModelWidthChanged);
				this._model.removeEventListener(HeightChangeEvent, onModelHeightChanged);
			}
			
			this._model = m;

			this._model.addEventListener(XChangeEvent, onModelXChanged);
			this._model.addEventListener(YChangeEvent, onModelYChanged);
			this._model.addEventListener(WidthChangeEvent, onModelWidthChanged);
			this._model.addEventListener(HeightChangeEvent, onModelHeightChanged);
		}
		
		//
		// public methods
		//
		
		/**
		 * 
		 * @param v
		 */
		public function addVisualCue(v: VisualCue): void
		{
			// use model's width/height?
			v.x = this.width * v.relativeX + v.offsetX;
			v.y = this.height * v.relativeY + v.offsetY;
			
			this.addChild(v);
		}
		
		/**
		 * 
		 * @param v
		 */
		public function removeVisualCue(v: VisualCue): void
		{
			this.removeChild(v);
		}
		
		/**
		 * this should be overriden by subclasses (NodeComponent, EdgeComponent, etc.)
		 * 
		 * @return 
		 */
		public function clone(): Component
		{
			return new Component(this.model);
		}
		
		//
		// protected methods
		//
		
		//
		// private methods
		//
		
		/**
		 * 
		 * @param event
		 */
		private function onModelXChanged(event: XChangeEvent): void
		{
		}

		/**
		 * 
		 * @param event
		 */
		private function onModelYChanged(event: YChangeEvent): void
		{
		}
		
		/**
		 * 
		 * @param event
		 */
		private function onModelWidthChanged(event: WidthChangeEvent): void
		{
		}
		
		/**
		 * 
		 * @param event
		 */
		private function onModelHeightChanged(event: HeightChangeEvent): void
		{
		}
	}
}