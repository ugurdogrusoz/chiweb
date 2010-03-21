/** 
* Authors: Ebrahim Rajabzadeh
*
* Copyright: i-Vis Research Group, Bilkent University, 2009 - present 
*/
package ivis
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import gs.TweenMax;
	
	import mx.core.UIComponent;
	
	public class Component extends UIComponent
	{
		public static const ELLIPSE: String = "Ellipse";
		public static const RECTANGLE: String = "Rectangle";		
		protected var _shape: String = RECTANGLE;
		protected static var _highlightColor: uint = 0xFF9900

		protected var _highlight: Boolean = false;
		private var _selected: Boolean = false;
		protected var _inspectorShown: Boolean = false;
		protected var _inspector: InspectorComponent;

		public function Component()
		{
			super();
		}

		public static function get highlightColor(): uint
		{
			return _highlightColor;
		}

		public static function set highlightColor(value: uint): void
		{
			_highlightColor = value;
		}
		
		public function hideInspector(): void 
		{
			var s:* = Graph.getInstance().overlay;
			if(_inspector && s.contains(_inspector)) {
				s.removeChild(_inspector);
				_inspectorShown = false;
			}
		}
		
		public function showInspector(p: Point = null): void
		{
			var s:* = Graph.getInstance().overlay;
			if(!s.contains(_inspector)) { // _inspectorShown = false;
				s.addChild(_inspector);
				if(p != null)
				{
					_inspector.x = p.x
					_inspector.y = p.y
				}
				else
					recalcInspectorPosition();
				
				_inspectorShown = true;
				
				// update x,y inputs
				if(_inspector is NodeInspector)
					(_inspector as NodeInspector).onPosChange(null)
			}
		}
		
		public function get inspectorShown(): Boolean
		{
			return this._inspectorShown
		}
		
		public function recalcInspectorPosition(p: Point = null): void {}
		
		public function toggleInspector(p: Point): void
		{
			if(_inspectorShown)
				hideInspector();
			else
				showInspector(p);
		}
		
		public function get selected(): Boolean
		{
			return _selected;
		}		

		public function set selected(value: Boolean): void
		{
			this._selected = value;
		} 
		
		public function get shape(): String
		{
			return _shape;
		}

		public function set shape(value: String): void
		{
			this._shape = value;
			this.invalidateDisplayList();
			dispatchEvent(new Event("shapeChanged"));
		}

		public function get highlight(): Boolean
		{
			return this._highlight;
		}
		
		public function set highlight(value: Boolean): void {
			if(this._highlight == value)
				return;
			
			this._highlight = value;

			var _selectFilter:* = {color: uint(_highlightColor), alpha:.5, blurX:4, blurY:4, strength:3, quality: 1, inner: false};
			var _unselectFilter:* = {color: uint(_highlightColor), alpha:0, blurX:4, blurY:4, strength:3, quality: 1, inner: false, remove: true};
			
			if(value) {
				TweenMax.to(this, .7, {glowFilter: _selectFilter });
			}
			else {
				TweenMax.to(this, .7, {glowFilter: _unselectFilter });
			}
		}
		
		public function pointInParent(p: Point, pr:* = null): Point
		{
			if(pr == null)
				pr = this.parent ? this.parent : Graph.getInstance().surface
			return pr.globalToLocal(this.localToGlobal(p))
		}
		
		protected var _localStart: Point;
		protected var _stageStart: Point;
		
		public function onMouseDown(e: MouseEvent): void
		{				
			_stageStart = new Point(e.stageX, e.stageY);
			Graph.getInstance().overlay.mouseChildren= false
			
			trace("edge mouse down")
		}
		
		public function buddy(): UIComponent { return null; }
		public function onMouseMove(e: MouseEvent): void {}
		
		public function onMouseUp(e: MouseEvent): void
		{
			Graph.getInstance().overlay.mouseChildren= true;
		}
		
		public function get model(): Object { return null }
	}
}