package ivis.ui
{
	import flash.events.MouseEvent;
	
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
		}
		
		//
		// public methods
		//
		
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
		
	}
}