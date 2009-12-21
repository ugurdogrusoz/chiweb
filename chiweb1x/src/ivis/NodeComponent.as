/** 
* Authors: Turgut Isik, Ebrahim Rajabzadeh
*
* Copyright: i-Vis Research Group, Bilkent University, 2009 - present 
*/
package ivis
{
	import flash.display.GradientType;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import mx.core.UIComponent;
	import mx.effects.*;
	import mx.events.ResizeEvent;

	public class NodeComponent extends Component
	{
		protected var _node: Node;

		public static const MIN_WIDTH: uint = 30;
		public static const MIN_HEIGHT: uint = 20;
		
		protected static const LINE_COLOR:uint = 0xFF45523B;
		protected static const DEFAULT_FILL_COLOR1:uint = 0xFFFFFF;
		public static const DEFAULT_FILL_COLOR2:uint = 0xA4C290;
		protected static const HIGHLIGHT_COLOR:uint = 0xFFF3E843;
		
		protected var _font: String = 'Calibri';
		protected var _fontSize: uint = 12;
		
		protected var _color1:uint = DEFAULT_FILL_COLOR1
		protected var _color2:uint = DEFAULT_FILL_COLOR2
		protected var _label: TextField;
		protected var _originalLabel: String;
		
		public function NodeComponent(node: Node)
		{
			super();
			
			this._node = node;
			
			this.doubleClickEnabled = true;
			this.filters = [ new DropShadowFilter(2, 45, 0, .75, 4, 4, 1, BitmapFilterQuality.MEDIUM, false, false, false) ];
			
			grpTL = new Grapple(this, Grapple.TOP_LEFT);
			grpTR = new Grapple(this, Grapple.TOP_RIGHT);
			grpBL = new Grapple(this, Grapple.BOTTOM_LEFT);
			grpBR = new Grapple(this, Grapple.BOTTOM_RIGHT);
			
			this.addEventListener("resize", onNodeResize, false, 0, true);
			Graph.getInstance().surface.addEventListener("scaleXChanged", function(e: Event): void {
				refreshGrapples()
			})
			setupChildren();
			
		}

		override public function showInspector(p: Point = null): void
		{
			super.showInspector(p)
		}
		
		[Bindable(event="color1Changed")]
		public function get color1(): uint
		{
			return _color1;
		}

		public function set color1(value: uint): void
		{
			this._color1 = value;
			this.invalidateDisplayList();
			
			this.dispatchEvent(new Event("color1Changed"))
		}

		[Bindable(event="color2Changed")]
		public function get color2(): uint
		{
			return _color2;
		}

		public function set color2(value: uint): void
		{
			this._color2 = value;
			this.invalidateDisplayList();

			this.dispatchEvent(new Event("color2Changed"))
		}
		
		public function get longLabelText(): String
		{
			return _originalLabel;
		}

		public function get shortLabelText(): String
		{
			return _label.text;
		}

		public function get labelX(): Number
		{
			return _label.x;
		}

		public function get labelY(): Number
		{
			return _label.y;
		}

		public function get labelHeight(): Number
		{
			return _label.height
		}
		
		public function set longLabelText(value: String): void
		{
			this._originalLabel = value;
			refreshLabel();
		}

		[Bindable]
		public function get font(): String
		{
			return _font;
		}

		public function set font(value: String): void
		{
			_font = value;
			refreshLabel();
		}

		[Bindable]
		public function get fontSize(): int
		{
			return _fontSize;
		}

		public function set fontSize(value: int): void
		{
			_fontSize = value;
			refreshLabel();
		}
		
		protected function refreshLabel(): void
		{
			this._label.htmlText = "<font face='" + _font + "' size='" + 
				_fontSize + "'>" + _originalLabel + "</font>";

			var i: int = _originalLabel.length - 1;
			while(this._label.textWidth > this.width-4 && i >= 0) {
				this._label.htmlText = "<font face='" + _font + "' size='" + 
					_fontSize + "'>" + _originalLabel.substr(0, --i) + "...</font>";
			}
			
			var lh: Number = _label.textHeight - _label.getLineMetrics(0).leading + _label.getLineMetrics(0).descent;
			_label.y = (height - lh)/2
			_label.x = (width - _label.textWidth)/2
	
		}
		
		protected function setupChildren(): void
		{
			this._label = new TextField();
			longLabelText = _node.id;
			this._label.selectable = false;
			this._label.autoSize = TextFieldAutoSize.CENTER;
			this._label.mouseEnabled = false;
			refreshLabel();
//			this._label.antiAliasType = AntiAliasType.ADVANCED;
//			this._label.gridFitType = GridFitType.SUBPIXEL;
			this.addChild(_label);

			_inspector = new NodeInspector(this);
			
			this.addEventListener("doubleClick", onDoubleClick);
			this.addEventListener("remove", function(e: Event): void {
				hideInspector()
			})		
		}
		
		protected function onDoubleClick(e: MouseEvent):void {
			var p: Point = Graph.getInstance().overlay.globalToLocal(
				this.localToGlobal(new Point(e.localX, e.localY)))
			toggleInspector(p);
			e.stopImmediatePropagation();
		}

		override public function recalcInspectorPosition(p: Point = null): void
		{
			var p: Point = pointInParent(
				new Point(width + Grapple.GRAPPLE_OFFSET + Grapple.DEFAULT_GRAPPLE_SIZE, 0),
						Graph.getInstance().overlay); 
			_inspector.x = p.x;
			_inspector.y = p.y;
		}
		
		protected function onNodeResize(e: ResizeEvent): void
		{
			if(width != e.oldWidth || height != e.oldHeight)
				refreshGrapples()
				
			refreshLabel();
			
			if(this.model.parent)
				this.model.parent.revalidate()
		}
		
		private function refreshGrapples(): void
		{
			var z: Number = Graph.getInstance().zoom
			grpTL.x = -Grapple.GRAPPLE_OFFSET / z;
			grpTL.y = -Grapple.GRAPPLE_OFFSET / z;
			grpTL.width = Grapple.DEFAULT_GRAPPLE_SIZE / z

			grpTR.x = width + Grapple.GRAPPLE_OFFSET / z;
			grpTR.y = -Grapple.GRAPPLE_OFFSET / z;
			grpTR.width = Grapple.DEFAULT_GRAPPLE_SIZE / z

			grpBL.x = -Grapple.GRAPPLE_OFFSET / z;
			grpBL.y = height + Grapple.GRAPPLE_OFFSET / z;
			grpBL.width = Grapple.DEFAULT_GRAPPLE_SIZE / z

			grpBR.x = width + Grapple.GRAPPLE_OFFSET / z;
			grpBR.y = height + Grapple.GRAPPLE_OFFSET / z;
			grpBR.width = Grapple.DEFAULT_GRAPPLE_SIZE / z

		}
		
		override public function get highlight(): Boolean
		{
			return super.highlight;
		}
		
		override public function set highlight(value:Boolean):void {
			super.highlight = value;
			
			if(value)
				addGrapples();
			else
				removeGrapples();
		}
		
		protected var grpTL: UIComponent;
		protected var grpTR: UIComponent;
		protected var grpBL: UIComponent;
		protected var grpBR: UIComponent;
		
		public function removeGrapples(): void
		{
			if(this.contains(grpTL))
				removeChild(grpTL);
			if(this.contains(grpTR))
				removeChild(grpTR);
			if(this.contains(grpBL))
				removeChild(grpBL);
			if(this.contains(grpBR))
				removeChild(grpBR);			
		}
		
		public function addGrapples(): void
		{
			this.refreshGrapples()

			this.addChild(grpTL);
			this.addChild(grpTR);
			this.addChild(grpBL);
			this.addChild(grpBR);
		}
		
		override public function get model(): Object {
			return this._node;
		}
		

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number): void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			graphics.clear();
			var mx: Matrix = new Matrix;
			
			mx.createGradientBox(width, height, 45);
			graphics.beginGradientFill(
				GradientType.LINEAR,
				[_color1, _color2],
				[.70, .70],
				[0,  255],
				mx
			);
			
			if(_shape == RECTANGLE)
				graphics.drawRoundRect(0, 0, width, height, 10, 10);
			else if(_shape == ELLIPSE)
				graphics.drawEllipse(0 ,0, width, height);
			graphics.endFill();
		} 
		
		protected static var _sourceNode: NodeComponent = null;

		public var selectedComp: NodeComponent = null;
		protected var _transfer: Boolean = false
		protected var _prevBounds: Object
		protected var _moved: Boolean
		
		override public function onMouseDown(e: MouseEvent):void
		{
			super.onMouseDown(e)

			Graph.getInstance().addEventListener("mouseMove", onMouseMove);
			Graph.getInstance().addEventListener("mouseUp", onMouseUp);
			
			_transfer = e.ctrlKey
			if(_transfer && this.model.parent)
				_prevBounds = this.model.parent.bounds()
				
			_localStart = new Point(this.x, this.y);
			
			_moved = false
		}

		override public function onMouseMove(e: MouseEvent): void
		{
			super.onMouseMove(e);
		
			var dx: Number = e.stageX - _stageStart.x
			var dy: Number = e.stageY - _stageStart.y

			var pa: Graph = Graph.getInstance()
			this.model.x = _localStart.x + pa.unscaledDx(dx)
			this.model.y = _localStart.y + pa.unscaledDx(dy)
			
			_transfer &&= e.ctrlKey

			if(!_transfer)
			{
				if(this.model.parent)
					this.model.parent.revalidate()
					
			} 
			else if(this.selected) {
				pa.removeFromSelection(this)
			}
				
			_moved = true
			pa.dispatchEvent(new Event("boundsChanged"))
		}
		
		override public function onMouseUp(e: MouseEvent): void
		{
			super.onMouseUp(e);
		
			var pa: Graph = Graph.getInstance()
			pa.removeEventListener("mouseMove", onMouseMove);
			pa.removeEventListener("mouseUp", onMouseUp);

			if(_transfer && !pa._clickedAndMoved && _moved)
			{
				var p: Point = pa.surface.globalToLocal(new Point(e.stageX, e.stageY))
				
				// find the new compound parent
				var nd: Node = this.model as Node
				var cn: CompoundNode = pa.compoundUnderPoint(p.x, p.y, nd)
				if(cn !== nd.parent)
				{
					var op: CompoundNode = this.model.parent
					
					if(op)
					{
						op.removeNode(nd)
					}
					
					if(cn) 
					{
						cn.addNode(nd)
					}
					else if(op && Utils.pointInBounds(p.x, p.y, _prevBounds))
					{
						op.addNode(nd)
					}
				}
				if(cn)
					cn.revalidate()
			}

		}
		
		public function properties(): Array
		{
			return [
				{ key: "Label", value: longLabelText },
				{ key: "Cluster", value: this.model.clusterID },
				{ key: "X", value: this.model.x },
				{ key: "Y", value: this.model.y },
				{ key: "Color 1", value: _color1},
				{ key: "Color 2", value: _color2},
				{ key: "Shape", value: _shape},
				{ key: "Font", value: _font},
				{ key: "Font Size", value: _fontSize},
			];
		}
		
		public static function availableShapes(): Array {
			return [
				{ label: "Rectangle", value: RECTANGLE },
				{ label: "Ellipse", value: ELLIPSE }
			];
		}
		
		public static function availableFonts(): Array {
			return [
				"Arial", "Calibri", "Verdana"
			];
		}
	}
}

