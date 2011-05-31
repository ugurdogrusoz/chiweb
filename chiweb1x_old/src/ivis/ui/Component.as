package ivis.ui
{
	import flash.geom.Rectangle;
	
	import gs.TweenMax;
	
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
		
		//inspector

		/**
		 * 
		 * @default 
		 */
		private var _mouseAdapter: IMouseAdapter;
		
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

		protected static var _highlightColor: uint = 0xFF9900
	
		/**
		 * 
		 * @param go
		 */
		public function Component(go: GraphObject = null)
		{
			super();
			
			this.model = go;
			this._mouseAdapter = null;
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
			if(h == this._highlighted)
				return;

			this._highlighted = h;

			var _selectFilter:* = {color: uint(_highlightColor), alpha:.5, blurX:4, blurY:4, strength:3, quality: 1, inner: false};
			var _unselectFilter:* = {color: uint(_highlightColor), alpha:0, blurX:4, blurY:4, strength:3, quality: 1, inner: false, remove: true};

			if(h) {
				TweenMax.to(this, .7, {glowFilter: _selectFilter });
			}
			else {
				TweenMax.to(this, .7, {glowFilter: _unselectFilter });
			}
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
			this._model = m;
		}

		/**
		 * 
		 * @return 
		 */
		public function get mouseAdapter(): IMouseAdapter
		{
			return this._mouseAdapter;
		} 
		
		/**
		 * 
		 * @param ma
		 */
		public function set mouseAdapter(ma: IMouseAdapter): void
		{
			this._mouseAdapter = ma;
			this._mouseAdapter.component = this;
		}
		
		//
		// public methods
		//
		
		public function addLabel(l: ivis.ui.Label): void
		{
			l.component = this;
		}
		
		public function removeLabel(l: ivis.ui.Label): void
		{
			l.component = null;
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

		/**
		 * this should be overriden by subclasses (NodeComponent, EdgeComponent, etc.)
		 * 
		 * @return 
		 */
		public function asXML(): XML
		{
			// TODO: stub
			return null;
		}
		
		/**
		 * this should be overriden by subclasses (NodeComponent, EdgeComponent, etc.)
		 * 
		 * @return 
		 */
		public function asGraphML(): XML
		{
			// TODO: stub
			return null;			
		}
		
		/**
		 * this is a stub to be overriden by subcalsses
		 * @return 
		 */
		public function get bounds(): Rectangle
		{
			return null;
		}
		
	}
}