/** 
* Authors: Ebrahim Rajabzadeh
*
* Copyright: i-Vis Research Group, Bilkent University, 2009 - present 
*/

package ivis
{
	import flash.display.CapsStyle;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import ivis.events.EdgeRemoved;
	
	import mx.core.UIComponent;
	import mx.effects.*;
	import mx.events.MoveEvent;
	import mx.events.ResizeEvent;
	
	public class EdgeComponent extends Component
	{
		
		public static const DEFAULT_COLOR: uint = 0xFF45523B;
		public static const DEFAULT_GRAPPLE_COLOR: uint = 0xFF45523B;
		public static const DEFAULT_WIDTH: uint = 1;
		public static const SOLID: String = "Solid";
		public static const DASHED: String = "Dashed";
		public static const ARROW_NONE: String= "None";
		public static const ARROW_SMALL: String= "Small";
		public static const ARROW_LARGE: String= "Large";
		
		public static var PIXEL_HINTING: Boolean = true
		
		private static const LINE_OVERLAY_WIDTH: uint = 15;
		
		private var _width: uint = DEFAULT_WIDTH;
		private var _lineStyle: String = SOLID;
		private var _sourceArrow: String = ARROW_NONE;
		private var _targetArrow: String = ARROW_NONE;
		private var _edge: Edge;
		public var endX: int;
		public var endY: int;
	
		private var _fInterX: Number;
		private var _fInterY: Number;
		private var _tInterX: Number;
		private var _tInterY: Number;
		private var _lastBend: Object = null;
		private var _color: uint = DEFAULT_COLOR;
		private var _grappleColor: uint = DEFAULT_GRAPPLE_COLOR;
		private var _inspectorPosIndex: int;
		private var _inspectorPos: Point;
		
		public function EdgeComponent(edge: Edge)
		{
			super();
			
			this._edge = edge;
			recalcPoints();
			
			_edge.source.view.addEventListener(MoveEvent.MOVE, endChanged, false, 0, true);
			_edge.target.view.addEventListener(MoveEvent.MOVE, endChanged, false, 0, true);
			_edge.source.view.addEventListener(ResizeEvent.RESIZE, onNodeResize, false, 0, true);
			_edge.target.view.addEventListener(ResizeEvent.RESIZE, onNodeResize, false, 0, true);
			_edge.source.view.addEventListener("shapeChanged", endChanged, false, 0, true);
			_edge.target.view.addEventListener("shapeChanged", endChanged, false, 0, true);

			this.doubleClickEnabled = true;
			this.addEventListener("doubleClick", onDoubleClick, false, 0, true);
			this.addEventListener("remove", function(e: Event): void
			{
				hideInspector()
			});
			this._inspector = new EdgeInspector(this)
		}
		
		override public function showInspector(p: Point = null): void
		{
			super.showInspector(p)
		}

		private function onDoubleClick(e: MouseEvent): void {
			var p: Point = Graph.getInstance().overlay.globalToLocal(
				this.localToGlobal(new Point(e.localX, e.localY)))
			toggleInspector(p);
			e.stopImmediatePropagation();
		}

		public function pointInEdgeComponent(p: Point, parent: UIComponent): Point {
			return this.globalToLocal(parent.localToGlobal(p));
		}

		public function get color(): uint {
			return _color & 0x00ffffff;
		}
		
		public function set color(value: uint): void {
			this._color = value;
			this.invalidateDisplayList();
		}
		
		private function onNodeResize(e: ResizeEvent): void
		{
			recalcPoints();
			this.invalidateDisplayList();
		}
		
		private function endChanged(e: Event): void
		{
			var b: Boolean = _edge.source === _edge.target ||
				(_edge.source.view.selected && _edge.target.view.selected)
			
			recalcPoints(b);
			this.invalidateDisplayList();
		}
		
		internal function recalcPoints(moveBends: Boolean = false): void
		{
			var fv: UIComponent = _edge.source.view; 
			var tv: UIComponent = _edge.target.view;

			var oldX: Number = this.x;			
			var oldY: Number = this.y;
			
			var fp: Point = new Point(fv.x + fv.width/2, fv.y + fv.height/2)
			this.x = fp.x;
			this.y = fp.y;
			
			if(!moveBends) {
				// bend positions remain fixed 
				for each(var bd:Object in this._edge.bends) 
				{
					bd.point.x += oldX - this.x;
					bd.point.y += oldY - this.y;
				}
			}
						
			var tp: Point = new Point(tv.x - this.x + tv.width/2, tv.y - this.y + tv.height/2)
			this.endX = tp.x
			this.endY = tp.y

			// clipping points
			var a: Number = fv.width/2;
			var b: Number = fv.height/2;
			var xs: Number;
			var i: int;
			var blen: int = _edge.bends.length;
			var xi: Number = blen > 0 ? _edge.bends[0].point.x : endX 
			var yi: Number = blen > 0 ? _edge.bends[0].point.y : endY
			var m: Number;
			var xf: Number = blen > 0 ? _edge.bends[blen-1].point.x : 0
			var yf: Number = blen > 0 ? _edge.bends[blen-1].point.y : 0
	
			if(_edge.source.view.shape == Component.ELLIPSE)
			{
				if(xi != 0) {
					m = Math.abs(yi/xi);
					xs = a*b / Math.sqrt(b*b+a*a*m*m);
					_fInterY = yi > 0 ? m * xs : -m * xs; 
					_fInterX = xi > 0 ? xs : -xs;
				} else {
					_fInterX = 0;
					_fInterY = yi > 0 ? b : -b;
				}
			}
			else
			{
				var xb: Number = xi > 0 ? a : -a;
				var yb: Number = yi > 0 ? b : -b;
				xs = yi == 0 ? xb : xi*yb/yi;
				xs = xs > 0 ? Math.min(xb, xs) : Math.max(xb, xs); 
				var ys: Number = xi == 0 ? yb : yi*xb/xi;
				ys = ys > 0 ? Math.min(yb, ys) : Math.max(yb, ys); 
				_fInterX = xs;
				_fInterY = ys;
			}
			
			a = tv.width/2;
			b = tv.height/2;
			if(_edge.target.view.shape == Component.ELLIPSE) {
				if(endX != xf) {
					
					m = (endY - yf)/(endX - xf);
					var d0: Number = a*a*m*m + b*b;
					var d1: Number = a*b*Math.sqrt(-yf*yf+yf*(2*m*xf-2*endX*m+2*endY)-m*m*xf*xf+
						xf*(2*endX*m*m-2*endY*m)+(a*a-endX*endX)*m*m+2*endX*endY*m-endY*endY+b*b);
					var d2: Number = a*a*m*(yf-m*xf-endY)-b*b*endX;
					xs = endX > xf ? -(d1 + d2)/d0 : (d1 - d2)/d0;
					_tInterX = xs;
					_tInterY = m*(xs-xf)+yf; 
				} else {
					_tInterX = xf;
					_tInterY = yf < endY ? endY - b : endY + b; 
				} 
				
			} else {
				xb = endX > xf ? endX - tv.width/2 : endX + tv.width/2;
				yb = endY > yf ? endY - tv.height/2 : endY + tv.height/2;
				xs = endY == yf ? xb : (yb-yf)*(endX-xf)/(endY-yf)+xf;
				xs = endX > xf ? Math.max(xb, xs) : Math.min(xb, xs); 
				ys = endX == xf ? yb : (endY-yf)*(xb-xf)/(endX-xf)+yf;
				ys = endY > yf ? Math.max(yb, ys) : Math.min(yb, ys); 
				_tInterX = xs;
				_tInterY = ys;
			}
			
			// move the origin of local coords to the intersection point
			this.x += _fInterX
			this.y += _fInterY
			
			if(!moveBends) {
				for each(var bend:* in this._edge.bends)
				{
					bend.point.x -= _fInterX 
					bend.point.y -= _fInterY
				}
			}
			_tInterX -= _fInterX
			_tInterY -= _fInterY
			_fInterX = 0
			_fInterY = 0
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number): void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			graphics.clear();
			var prevX: Number = _fInterX;
			var prevY: Number = _fInterY;
			
			if(_sourceArrow != ARROW_NONE) {
				
				graphics.lineStyle(_width, _color, 1, PIXEL_HINTING, "normal", CapsStyle.NONE);
				var ex: Number = _edge.bends.length > 0 ? _edge.bends[0].point.x : _tInterX;
				var ey: Number = _edge.bends.length > 0 ? _edge.bends[0].point.y : _tInterY;
				
				if(this._sourceArrow == ARROW_SMALL)
					drawArrow(prevX, prevY, ex, ey, 10, 50);
				else
					drawArrow(prevX, prevY, ex, ey, 17, 60);
					
					
			}
			
			for(var i: int = 0; i < _edge.bends.length; ++i) {
				var b:* = _edge.bends[i];
				graphics.lineStyle(_width + LINE_OVERLAY_WIDTH, 0, 0);
				graphics.lineTo(b.point.x, b.point.y);
				graphics.lineStyle(_width, _color, 1, PIXEL_HINTING, "normal", CapsStyle.ROUND);
				
				if(_lineStyle == DASHED)
					Utils.drawDashedLine(this.graphics, prevX, prevY, b.point.x, b.point.y, 5, 5);
				else {
					graphics.moveTo(prevX, prevY);
					graphics.lineTo(b.point.x, b.point.y);
				}

				if(b.deleted != true) {
					graphics.beginFill(_grappleColor);
					graphics.drawCircle(b.point.x, b.point.y, 2*_width);
					graphics.endFill();
				}
				prevX = b.point.x;
				prevY = b.point.y;
			}
			graphics.lineStyle(_width + LINE_OVERLAY_WIDTH, 0x0, 0);
			graphics.lineTo(_tInterX, _tInterY); 
			graphics.lineStyle(_width, _color, 1, PIXEL_HINTING, "normal", CapsStyle.ROUND);
			
			if(_lineStyle == DASHED)
				Utils.drawDashedLine(this.graphics, prevX, prevY, _tInterX, _tInterY, 5, 5);
			else {
				graphics.moveTo(prevX, prevY);
				graphics.lineTo(_tInterX, _tInterY);
			}
			
			if(_targetArrow != ARROW_NONE) {

				graphics.lineStyle(_width, _color, 1, PIXEL_HINTING, "normal", CapsStyle.NONE);

				if(this._targetArrow == ARROW_SMALL)
					drawArrow(_tInterX, _tInterY, prevX, prevY, 10, 50);
				else
					drawArrow(_tInterX, _tInterY, prevX, prevY, 17, 60);
					
			}
		}

		private function drawArrow(x1: Number, y1: Number, x2: Number, y2: Number, len: Number = 5, deg: Number = 30): void
		{
			var dx: Number = x2 - x1;
			var dy: Number = y2 - y1;
			var m: Number = Math.atan2(dy, dx);
			var rad: Number = deg * Math.PI / 360;
			var hx1: Number = x1 + len * Math.cos(m - rad);
			var hy1: Number = y1 + len * Math.sin(m - rad);
			var hx2: Number = x1 + len * Math.cos(m + rad);
			var hy2: Number = y1 + len * Math.sin(m + rad);
			var hx3: Number = x1 + .6* len * Math.cos(m);
			var hy3: Number = y1 + .6 * len * Math.sin(m);

			graphics.beginFill(_color);
			graphics.moveTo(x1, y1);
			graphics.lineTo(hx1, hy1);
			graphics.lineTo(hx3, hy3);
			graphics.lineTo(hx2, hy2);
			graphics.lineTo(x1, y1);
			graphics.endFill();
		}
		
		override public function get model(): Object
		{
			return this._edge;
		}
		
		override public function onMouseDown(e: MouseEvent): void
		{
			
			super.onMouseDown(e);
			
			_localStart = new Point(e.localX, e.localY);
			
			this._lastBend = _edge.newBendPoint(_localStart);
			
			if(_lastBend) {
				var pa: Graph = Graph.getInstance()
				pa.addEventListener("mouseMove", this.onMouseMove);
				pa.addEventListener("mouseUp", this.onMouseUp);
				_bendAdded = false;
			}
		}
		
		private var _bendAdded: Boolean = false;
		
		override public function onMouseMove(e: MouseEvent): void
		{
			super.onMouseMove(e);
			
			if(!_bendAdded) {
				_bendAdded = true;
				_edge.addBend(_lastBend);
				_lastBend.isNew = false;
			}
			
			var pa: Graph = Graph.getInstance()
			var dx: Number = pa.unscaledDx(e.stageX - _stageStart.x);
			var dy: Number = pa.unscaledDy(e.stageY - _stageStart.y);
			
			_lastBend.point.x += dx;
			_lastBend.point.y += dy;
			
			_stageStart.x = e.stageX;
			_stageStart.y = e.stageY;
			
			recalcPoints();
			invalidateDisplayList();
		}
		
		override public function onMouseUp(e: MouseEvent): void
		{
			super.onMouseUp(e);
			
			if(_bendAdded && _lastBend) {
				if(_edge.removeAlignedBendPoints(_lastBend)) {
					recalcPoints();
					invalidateDisplayList();
				}
			}
			
			var g: Graph = Graph.getInstance()
			g.removeEventListener("mouseMove", this.onMouseMove);
			g.removeEventListener("mouseUp", this.onMouseUp);
			
		}

		public function get sourceArrow(): String
		{
			return this._sourceArrow;
		}
		
		public function set sourceArrow(value: String): void
		{
			this._sourceArrow = value;
			invalidateDisplayList();
		}

		public function get weight(): uint
		{
			return this._width;
		}
		
		public function set weight(value: uint): void
		{
			this._width = Math.max(value, 1);
			invalidateDisplayList();
		}
		
		public function get targetArrow(): String
		{
			return this._targetArrow;
		}
		
		public function set targetArrow(value: String): void
		{
			this._targetArrow = value;
			invalidateDisplayList();
		}

		public function get lineStyle(): String
		{
			return this._lineStyle;
		}
		
		public function set lineStyle(value: String): void
		{
			this._lineStyle = value;
			invalidateDisplayList();
		}

		public function get bendPointColor(): uint
		{
			return this._grappleColor;
		}
		
		public function set bendPointColor(value: uint): void
		{
			this._grappleColor = value;
			invalidateDisplayList();
		}

		public function get sourceIntersection(): Point
		{
			return new Point(_fInterX, _fInterY);
		}

		public function get targetIntersection(): Point
		{
			return new Point(_tInterX, _tInterY);
		}
		

		public function properties(): Array
		{
			return [
				{ key: "Weight", value: _width },
				{ key: "Line Color", value: _color },
				{ key: "Line Style", value: _lineStyle },
				{ key: "Bend Point Color", value: _grappleColor },
				{ key: "Source Arrow", value: _sourceArrow },
				{ key: "Target Arrow", value: _targetArrow },
			];
		}
		
		public static function arrowTypes(): Array {
			return [
				{ label: "None", value: ARROW_NONE },
				{ label: "Small", value: ARROW_SMALL },
				{ label: "Large", value: ARROW_LARGE }
			];
		}

		public static function lineStyles(): Array
		{
			return [
				{ label: "Solid", value: SOLID },
				{ label: "Dashed", value: DASHED },
			];		
		}
	}
}