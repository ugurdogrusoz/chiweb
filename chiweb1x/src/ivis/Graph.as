/** 
* Authors: Ebrahim Rajabzadeh, Turgut Isik
*
* Copyright: i-Vis Research Group, Bilkent University, 2009 - present 
*/

package ivis
{
	import flash.display.BitmapData;
	import flash.events.*;
	import flash.geom.*;
	import flash.ui.Keyboard;
	
	import gs.*;
	import gs.easing.*;
	import gs.events.*;
	
	import ivis.events.*;
	
	import mx.containers.Canvas;
	import mx.controls.scrollClasses.ScrollBar;
	import mx.controls.sliderClasses.Slider;
	import mx.core.Container;
	import mx.core.ScrollPolicy;
	import mx.core.UIComponent;
	import mx.events.ScrollEvent;
	import mx.events.SliderEvent;
	import mx.managers.BrowserManager;

	public class Graph extends Canvas
	{
		public var _nodes: Array = new Array;
		public var _edges: Array = new Array;
		public static const ZOOM_MIN: Number = .25;
		public static const ZOOM_MAX: Number = 10;
		public static const DEFAULT_ANIMATION_TIME: Number = 1.0
		public static const ANIMATION_EASING:* = gs.easing.Expo.easeOut
		public static const CANVAS_BACKGROUND_COLOR: int = 0xffffff
		private static const MAP_BACKGROUND_COLOR: uint = 0xffffff
		
		private var _animationTime: Number = DEFAULT_ANIMATION_TIME
		private var _zoomBuddy: Slider; 
		private var _stageStart: Point = null;
		private var _localStart: Point = null;
		private var _target: * = null;
		private var _isAddingEdges: Boolean = false;
		private var _isMarqueeZooming: Boolean = false;
		private var _isPanning: Boolean = false;
		private var _isRectSeleting: Boolean = true;
		private var _isCreatingSimpleNode: Boolean = false;
		private var _isCreatingCompoundNode: Boolean = false;
		private var _surface: Canvas = new Canvas;
		private var _miniMap: UIComponent
		private var _selecteds: Array = new Array;
		private var _inspectorShown: Boolean = false;
		private var _inspector: InspectorComponent;
		private var _overlay: Container;
		private var _inspectorPos: Point;
		private var _margin: uint = 10;
		private var _selectionRect: UIComponent
		private var _vscroll: ScrollBar = null
		private var _hscroll: ScrollBar = null
		internal var _clickedAndMoved: Boolean = false
		private namespace gmlns = "http://graphml.graphdrawing.org/xmlns";
		private static var _instance: Graph;

		// General options consts		
		public static const PROOF_QUALITY:int = 0;
		public static const DEFAULT_QUALITY:int = 1;
		public static const DRAFT_QUALITY:int = 2;
		// CoSE options consts
		public static const DEFAULT_EDGE_LENGTH:uint = 60;
		public static const DEFAULT_SPRING_STRENGTH:Number = 50;
		public static const DEFAULT_REPULSION_STRENGTH:Number = 50;
		public static const DEFAULT_GRAVITY_STRENGTH:Number = 50;
		public static const DEFAULT_COMPOUND_GRAVITY_STRENGTH:Number = 50;
		// CiSE options consts
		public static const DEFAULT_NODE_SEPARATION:uint = 60;
		public static const DEFAULT_CISE_EDGE_LENGTH:uint = 60;
		public static const DEFAULT_INTER_CLUSTER_EDGE_LENGTH_FACTOR:Number = 50;
		

		private var _generalOptions:Object = {
			quality: DEFAULT_QUALITY,
			incremental: false,
			animateOnLayout: true
		} 

		private var _CoSEOptions:Object = {
			idealEdgeLength: DEFAULT_EDGE_LENGTH,
			springStrength: DEFAULT_SPRING_STRENGTH,
			repulsionStrength: DEFAULT_REPULSION_STRENGTH,
			gravityStrength: DEFAULT_GRAVITY_STRENGTH,
			compoundGravityStrength: DEFAULT_COMPOUND_GRAVITY_STRENGTH
		} 

		private var _CiSEOptions:Object = {
			nodeSeparation: DEFAULT_NODE_SEPARATION,
			desiredEdgeLength: DEFAULT_CISE_EDGE_LENGTH,
			interClusterEdgeLengthFactor: DEFAULT_INTER_CLUSTER_EDGE_LENGTH_FACTOR
		}
				
		public function Graph()
		{
// 			if (_instance != null)
//            {
//                throw new Error("Graph is a singleton class");
//            }
			_instance = this;

//			this.percentWidth = 100;
//			this.percentHeight = 100;
			
			this.addEventListener("mouseDown", onMouseDown);
			this.addEventListener("mouseMove", onMouseMove);
			this.addEventListener("mouseUp", onMouseUp);
			this.addEventListener("mouseUp", refreshMinimap)
			this.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);

			this.doubleClickEnabled = true;
			this.addEventListener("doubleClick", onDoubleClick);
			
			this.addEventListener(Event.ADDED_TO_STAGE, function(e: Event): void {
				stage.addEventListener("keyUp", keyboardHandler)
			})
			this.addEventListener("creationComplete", refreshMinimap)
			this.addEventListener("render", refreshMinimap)
//			this.addEventListener("childAdd", refreshMinimap)
//			this.addEventListener("mouseDown", refreshMinimap)
			
			this.horizontalScrollPolicy = ScrollPolicy.OFF
			this.verticalScrollPolicy = ScrollPolicy.OFF
			this.clipContent = true;
			this._surface.clipContent = false;
			this._surface.opaqueBackground = CANVAS_BACKGROUND_COLOR;
			this.addChild(_surface);

			var mask:UIComponent = new UIComponent(); 
			mask.graphics.beginFill(0,1); 
			mask.graphics.drawRect(0, 0, 1000000, 1000000);
			mask.graphics.endFill();
			this.mask = mask;
			this.addChild(mask);

			this._inspector = new GraphInspector(null);
			
//			this._surface.addEventListener("move", revalidateSurfaceBounds)
			this._surface.addEventListener("resize", revalidateSurfaceBounds)
			this.addEventListener("boundsChanged", revalidateSurfaceBounds)
//			this.addEventListener("boundsChanged", refreshMinimap)

		}

		private function revalidateSurfaceBounds(e: Event): void
		{
			var b:* = this.bounds
			
			b.left += this._surface.x
			b.top += this._surface.y
			
			vscroll.minScrollPosition = 0
			vscroll.maxScrollPosition = Math.max(0, -b.top) + Math.max(_surface.y + _surface.height - this.height, 0)
			vscroll.scrollPosition = Math.max(0, -b.top)
//			trace("min=" + vscroll.minScrollPosition + ", cur=" + vscroll.scrollPosition + ", max=" + vscroll.maxScrollPosition)
			
			hscroll.minScrollPosition = 0
			hscroll.maxScrollPosition = Math.max(0, -b.left) + Math.max(_surface.x + _surface.width - this.width, 0)
			hscroll.scrollPosition = Math.max(0, -b.left)
			
		}

		public function get vscroll(): ScrollBar
		{
			return _vscroll
		}
		
		private var _prevVPos: Number
		private var _prevHPos: Number
		
		public function set vscroll(value: ScrollBar): void
		{
			this._vscroll = value
			
			if(this._vscroll) {
				this._vscroll.addEventListener("scroll", function(e: ScrollEvent): void
				{
					if(e.position == _prevVPos)
						return
					_surface.y -= e.delta
					_prevVPos = e.position
					refreshMinimap(null)
				})
			}
		}
		
		public function get hscroll(): ScrollBar
		{
			return _hscroll
		}

		public function set hscroll(value: ScrollBar): void
		{
			this._hscroll = value

			if(this._hscroll) {
				this._hscroll.addEventListener("scroll", function(e: ScrollEvent): void
				{
					if(e.position == _prevHPos)
						return
					_surface.x -= e.delta
					_prevHPos = e.position
					refreshMinimap(null)
				})
			}
		}
		
		private function keyboardHandler(e: KeyboardEvent): void
		{
			if(e.keyCode == Keyboard.ESCAPE) {
				if(this.isAddingEdges && _sourceNode != null)
				{
					this.removeNode(_dummyNode)
					_sourceNode = null	
				}
				else if(isSeleting || isMarqueeZooming)
				{
					if(_selectionRect) {
						removeSelectioRectangle()
					}
					
					if(isSeleting)
						clearSelection()
				}
			}
			else if(e.keyCode == Keyboard.DELETE)
				this.remove(this.selection)
		}
		
		public function get bounds(): Object
		{
			var pts: Array = Utils.cloneArray(this._nodes)
			
			for each(var e: Edge in _edges) {
				if(e.bends.length > 0)
					pts = Utils.merge(pts, e.bendPoints)
			}
			var b:* = Utils.boundingRect(pts)

			return { left: b.left, top: b.top, width: b.width, height: b.height }			
		}

		private function zoomToBounds(b: Object): void
		{
				
			var car: Number;
			var sar: Number
			var sw: Number = b.width
			var sh: Number = b.height
			var w: Number = 800;
			var h: Number = 500;
			
			sar = (sw + 2*_margin)/ (sh + 2*_margin);
			car = w / h;
			
			var z: Number;
			
			if(car > sar)
			{
				z = h / (sh + 2*_margin);
				z = Math.min(z, ZOOM_MAX)
				z = Math.max(z, ZOOM_MIN)
				zoom = z
//				_surface.move(-b.left*z + (w - sw*z)/2, -b.top*z + _margin*z);
				smoothPanTo(-b.left*z + (w - sw*z)/2, -b.top*z + _margin*z)
			}
			else
			{
				z = w / (sw + 2*_margin);
				z = Math.min(z, ZOOM_MAX)
				z = Math.max(z, ZOOM_MIN)
				zoom = z;
//				_surface.move(-b.left*z + _margin*z, -b.top*z + (h - sh*z)/2);
				smoothPanTo(-b.left*z + _margin*z, -b.top*z + (h - sh*z)/2)
			}
			
		}	
		
		public function get miniMap(): UIComponent
		{
			return _miniMap
		}
		
		public function set miniMap(value: UIComponent): void
		{
			this._miniMap = value
			
			if(_miniMap)
			{
				_miniMap.addEventListener("mouseDown", onMapZoomStart)
			}
		}
		
		private var _mapLocalStart: Point
		private var _mapSelectionRect: UIComponent
		private var _validMapSelection: Boolean
		
		private function onMapZoomStart(e: MouseEvent): void
		{
			if(_mapSelectionRect)
				_miniMap.removeChild(_mapSelectionRect)
				
			_mapLocalStart = new Point(e.localX, e.localY)
			
			
			_miniMap.addEventListener("mouseMove", onMapMove)
			_miniMap.addEventListener("mouseUp", onMapUp)
			
			_mapSelectionRect = new UIComponent
			_mapSelectionRect.mouseEnabled = false
			_miniMap.addChild(_mapSelectionRect)
			_validMapSelection = false
		}
		
		private function onMapMove(e: MouseEvent): void
		{
			if(!e.buttonDown)
			{
				_miniMap.removeChild(_mapSelectionRect)
				_mapSelectionRect = null
				_miniMap.removeEventListener("mouseMove", onMapMove)
				_miniMap.removeEventListener("mouseUp", onMapUp)
				return
			}
			
			var dx: Number =  e.localX - _mapLocalStart.x
			var dy: Number =  e.localY - _mapLocalStart.y

			_mapSelectionRect.graphics.clear()
			_mapSelectionRect.graphics.lineStyle(2, 0xF8B584, .6)
			_mapSelectionRect.graphics.drawRect(
				_mapLocalStart.x, _mapLocalStart.y,
				dx, dy)
				
			_validMapSelection = true
		}
		
		private function onMapUp(e: MouseEvent): void
		{
			_miniMap.removeChild(_mapSelectionRect)
			_mapSelectionRect = null
			_miniMap.removeEventListener("mouseMove", onMapMove)
			_miniMap.removeEventListener("mouseUp", onMapUp)

			if(!_validMapSelection)
				return

			var dx: Number =  e.localX - _mapLocalStart.x
			var dy: Number =  e.localY - _mapLocalStart.y
			
			var mar: Number = _miniMap.width / _miniMap.height
			var sar: Number = _surface.width / _surface.height
			var scale: Number
			var x: Number
			var y: Number
			var w: Number
			var h: Number
			
			if(mar > sar)
			{
				scale = _miniMap.height / _surface.height
				w = scale*_surface.width
				h = _miniMap.height
				x = (_miniMap.width - w)/2
				y = 0
			}
			else
			{
				scale = _miniMap.width / _surface.width
				h = scale*_surface.height
				w = _miniMap.width
				x = 0
				y = (_miniMap.height - h)/2
			}
			
//			trace("x=" + ((_mapLocalStart.x - x)/ scale) + ", y=" + ((_mapLocalStart.y - y)/ scale))
			scale *= zoom
			x = Math.min((_mapLocalStart.x - x)/ scale, (_mapLocalStart.x - x + dx)/ scale)
			y = Math.min((_mapLocalStart.y - y)/ scale, (_mapLocalStart.y - y + dy)/ scale)
			dx = Math.abs(dx) / scale
			dy = Math.abs(dy) / scale
			this.zoomToBounds(
				{ left: x, top: y, width: dx, height: dy })
		}
		
		public function zoomToFit(): void
		{
			this.zoomToBounds(this.bounds)
		}

		public function zoomIn(inc: Number = .15): void
		{
			this.zoom += inc
		}
		
		public function zoomOut(inc: Number = .15): void
		{
			this.zoom -= inc
		}
		
		public function get overlay(): Container
		{
			return this._overlay;
		}
		
		public function set overlay(value: Container): void
		{
			_overlay = value;
			_overlay.clipContent = false;
			_overlay.width = 800
			_overlay.height = 500

//			var m:UIComponent = new UIComponent(); 
//			m.graphics.beginFill(0,1); 
//			m.graphics.drawRect(0, 0, 800, 500); 
//			m.graphics.endFill();
//			_overlay.mask = m;
//			_overlay.addChild(m);
		}
		
		private function onDoubleClick(e: MouseEvent): void
		{
			if(e.target !== this)
				return;
				
			toggleInspector();
		}
		
		public function toggleInspector(): void
		{
			if(_inspectorShown)
			{
				if(this._overlay.contains(_inspector))
					this._overlay.removeChild(_inspector);
				_inspectorShown = false
			}
			else
			{
				this._inspector.x = mouseX;
				this._inspector.y = mouseY;
				_inspectorPos = new Point(mouseX, mouseY);
				this._overlay.addChild(_inspector);
				_inspectorShown = true;	
			}
		}
		
		public static function getInstance(): Graph
		{
			return _instance;
		}
		
		private function onMouseWheel(e: MouseEvent): void {
			
			var inc: Number = e.delta > 0 ? 1.15 : .85;
			this.zoom *= inc;
			
			e.stopImmediatePropagation();
		}


		private var _prevMap: BitmapData = null
				
		public function refreshMinimap(e: Event): void
		{
			if(!_miniMap)
				return
			
			if(_prevMap)
				_prevMap.dispose()

			map = this.getCompatibleBitmap()
			if(map == null) {
				_miniMap.graphics.clear()
				_miniMap.graphics.beginFill(MAP_BACKGROUND_COLOR)
				_miniMap.graphics.drawRect(0, 0, _miniMap.width, _miniMap.height)
				_miniMap.graphics.endFill()
				return
			}
					
			var mat: Matrix = new Matrix
			var map: BitmapData
			var mar: Number = _miniMap.width / _miniMap.height
			var sar: Number = _surface.width / _surface.height
			var x: Number
			var y: Number
			var w: Number
			var h: Number
			var scale: Number
			
			if(mar > sar)
			{
				scale = _miniMap.height / _surface.height
				w = scale*_surface.width
				h = _miniMap.height
				x = (_miniMap.width - w)/2
				y = 0
			}
			else
			{
				scale = _miniMap.width / _surface.width
				h = scale*_surface.height
				w = _miniMap.width
				x = 0
				y = (_miniMap.height - h)/2
			}
			
			mat.scale(scale * zoom, scale * zoom)
			mat.translate(x, y)
			this.drawOnBitmap(map, mat)
			
			this._miniMap.graphics.clear();
			this._miniMap.graphics.beginBitmapFill(map, null, false, true);
			this._miniMap.graphics.drawRect(0, 0, _miniMap.width, _miniMap.height);
			this._miniMap.graphics.endFill();
			
 			this._miniMap.graphics.lineStyle(2, 0xF8B584, .6)

			var scb: ScrollBar
			var b:* = this.bounds
			
			if(hscroll.maxScrollPosition > 0) {
				
				scb = this.hscroll
				x += Math.max(0, -this._surface.x) * scale
				x = Math.min(x, _miniMap.width)
				
				if(this._surface.x > 0)
					w = Math.max(0, this.width - this._surface.x) * scale
				else
					w = Math.min(this.width, this._surface.width + this._surface.x) * scale
				w = Math.min(w, _miniMap.width)
				w = Math.max(w, 0)
			}
			
			if(vscroll.maxScrollPosition > 0) {
				
				scb = this.vscroll
				y += Math.max(0, -this._surface.y) * scale
				y = Math.min(y, _miniMap.height)
				
				if(this._surface.y > 0)
					h = Math.max(0, this.height - this._surface.y) * scale
				else
					h = Math.min(this.height, this._surface.height + this._surface.y) * scale
				h = Math.min(h, _miniMap.height)
				h = Math.max(h, 0)
			}
									
			this._miniMap.graphics.drawRect(x, y, w, h)
 			_prevMap = map
		}

		[Bindable(event="zoomChanged")]
		public function get zoom(): Number {
			return this._surface.scaleX; // == scaleY
		}
		
		public function set zoom(value: Number): void
		{
			value = Math.min(value, ZOOM_MAX)			
			value = Math.max(value, ZOOM_MIN)

			// TODO: correct zooming wrt mouse position			
//			zoomTo(value)	

			var t: TweenMax = TweenMax.to(_surface, .65, { scaleX: Number(value), scaleY: Number(value), ease:Expo.easeOut, overwrite: 2 } );
//			t.addEventListener(TweenEvent.UPDATE, onZoomUpdate, false, 0, true);
			t.addEventListener(TweenEvent.COMPLETE, onZoomComplete, false, 0, true);
		}
		
		private function onZoomUpdate(e: Event): void
		{
			dispatchEvent(new Event("zoomChanged"));
		}
		
		private function onZoomComplete(e: Event):void
		{
			var tm: TweenMax = e.target as TweenMax
//			tm.removeEventListener(TweenEvent.UPDATE, onZoomUpdate, false);
			tm.removeEventListener(TweenEvent.COMPLETE, onZoomComplete, false);

			this.refreshMinimap(null)

			dispatchEvent(new Event("zoomChanged"));
		}
		
		private function zoomTo(value: Number, x: Number = 0, y: Number = 0): void
		{
			var t: Matrix= this._surface.transform.matrix
			t.translate(-x, -y)
			t.scale(value, value)
			t.translate(x, y)
			this._surface.transform.matrix = t
		}
		
		public function resetTools(): void
		{
			this.isAddingEdges = false
			this.isCreatingCompoundNode = false
			this.isCreatingSimpleNode = false
			this.isMarqueeZooming = false
			this.isSeleting = false
		}
		
		[Bindable]
		public function get isAddingEdges(): Boolean
		{
			return this._isAddingEdges;
		}
		
		public function set isAddingEdges(value: Boolean): void
		{
			if(value) {
				this.resetTools()
			}
			else
			{
				if(_sourceNode)
				{
					removeNode(_dummyNode)
					_sourceNode = null
				}
			}
			this._isAddingEdges = value;
		}

		[Bindable]
		public function get isCreatingSimpleNode(): Boolean
		{
			return _isCreatingSimpleNode
		}

		public function set isCreatingSimpleNode(value: Boolean): void
		{
			if(value)
				this.resetTools()
			this._isCreatingSimpleNode = value
		}
		
		[Bindable]
		public function get isCreatingCompoundNode(): Boolean
		{
			return _isCreatingCompoundNode
		}

		public function set isCreatingCompoundNode(value: Boolean): void
		{
			if(value)
				this.resetTools()
			this._isCreatingCompoundNode = value
		}
		
		[Bindable]
		public function get isSeleting(): Boolean
		{
			return _isRectSeleting
		}

		public function set isSeleting(value: Boolean): void
		{
			if(value)
				this.resetTools()
			this._isRectSeleting = value
		}
		
		[Bindable]
		public function get isMarqueeZooming(): Boolean
		{
			return _isMarqueeZooming
		}

		public function set isMarqueeZooming(value: Boolean): void
		{
			if(value)
				this.resetTools();
			
			this._isMarqueeZooming = value
		}
		
		private var _prevSelected: Boolean
		
		private function onMouseDown(e: MouseEvent): void
		{
			this._clickedAndMoved = false
			_target = e.target;
			
			var clickedCanvas: Boolean = _target === this		
			var clickedNodeOrEdge: Boolean =
				_target is NodeComponent || _target is EdgeComponent
			var clickedNode: Boolean = 	_target is NodeComponent
			var clickedComponent: Boolean = _target is Component


			if(clickedComponent)
				this._prevSelected = (_target as Component).selected
				
			_stageStart = new Point(e.stageX, e.stageY);

			if(this.isAddingEdges)
			{
				if(clickedNodeOrEdge)
					this.onAddingEdgeStart(e)
			}
			else if(this.isCreatingSimpleNode)
			{
				this.onSimpleNodeStart(e)
			}
			else if(this.isCreatingCompoundNode)
			{
				this.onCompoundNodeStart(e)
			}
			else if(this.isMarqueeZooming)
			{
				this.onMarqueeZoomStart(e)
			}
			else if(this.isSeleting)
			{
				if(e.altKey)
					this.onPanStart(e)
				else
				{
					if(!e.ctrlKey && !((clickedNodeOrEdge && _target.selected) || _target is Grapple))
					{
						clearSelection()
					}

					if(clickedCanvas)
					{
						this.onSelectionStart(e)
					}
					else if(clickedNodeOrEdge) 
					{
						this.addToSelection(_target)
					}
					
					if(clickedNode)
					{
						for each(var c: Component in _selecteds)
							if(c is NodeComponent)
								c.onMouseDown(e)
					}
					
					if(_target is EdgeComponent || _target is Grapple)
					{
						_target.onMouseDown(e)
					}
					
				}
			}

			//e.stopImmediatePropagation()
		}

		private function onMouseMove(e: MouseEvent): void
		{
			this._clickedAndMoved = (e.buttonDown && !e.ctrlKey)
		}
		
		private function onMouseUp(e: MouseEvent): void
		{
			if(!this.isSeleting)
				return
			
			if(!e.ctrlKey && !this._selectionRect) 
			{
				if(!this._clickedAndMoved || (e.target is Component &&
					!(e.target as Component).selected) && !(e.target is Grapple)) {
						this.clearSelection()
					}
			}

			if(e.target is NodeComponent || e.target is EdgeComponent)
			{
				var c: Component = e.target as Component
					this.addToSelection(c)
				if(!this._clickedAndMoved && _prevSelected)
					this.removeFromSelection(c)
			}
		}
		
		private var _sourceNode: NodeComponent = null
		private var _dummyNode: Node
		
		private function onAddingEdgeStart(e: MouseEvent): void
		{
			var eg: Edge
			for each(eg in _edges)
				eg.view.mouseEnabled = false
				
			if(_target is NodeComponent)
			{
				if(_sourceNode == null) {
					_sourceNode = _target
					_dummyNode = new Node(null, _target.x, _target.y)
					_dummyNode.view.visible = false
					_dummyNode.view.mouseEnabled = false
					_dummyNode.width = 0
					_dummyNode.height = 0
					this.addNode(_dummyNode)
					var te: Edge = this.addEdge(
						_sourceNode.model.id +"_"+_dummyNode.id,
						_sourceNode.model.id,
						_dummyNode.id)
					te.view.mouseEnabled = false
					this.addEventListener("mouseMove", onAddingEdgeMove)
				}
				else
				{
					var ed: Edge = this.addEdge(
						_sourceNode.model.id +"_"+_dummyNode.id,
						_sourceNode.model.id,
						_target.model.id)
					var tcp: CompoundNode = _target.model.parent
					var scp: CompoundNode = _sourceNode.model.parent
					var i1: int = tcp ? this.surface.getChildIndex(tcp.view) : -1
					var i2: int = scp ? this.surface.getChildIndex(scp.view) : -1
					var ie: int = this.surface.getChildIndex(ed.view)
					var i: int = Math.max(i1, i2)
					
					if(ie < i)
					{
						this.surface.setChildIndex(ed.view, i)
					}
					
					this.removeNode(_dummyNode)
					_sourceNode = null;
					this.removeEventListener("mouseMove", onAddingEdgeMove)
					
					for each(eg in _edges)
						eg.view.mouseEnabled = true

				}
			}
		}
		
		private function onAddingEdgeMove(e: MouseEvent): void
		{
			var p: Point = this.surface.globalToLocal(new Point(e.stageX, e.stageY))
			_dummyNode.x = p.x
			_dummyNode.y = p.y
		}
		
		internal function addToSelection(c: Component): void
		{
			var i: int = _selecteds.indexOf(c)
			
			if(i < 0) {
				_selecteds.push(c)
				c.highlight = true;
				c.selected = true	
				
				if(c is NodeComponent && !(c is CompoundNodeComponent)) {
					i = _selecteds.length - 2
					while(i >= 0) {
						if(_selecteds[i] is NodeComponent) {
							(_selecteds[i] as NodeComponent).removeGrapples()
							//break
						}
						--i
					}
				}
			}
		}
		
		public function clearSelection(): void {
			
			var all: Array = Utils.merge(_nodes, _edges) 
			for each(var c:* in all) {
				c.view.highlight = false;
				c.view.selected = false;
			}
				
			_selecteds = [];
		}
		
		internal function removeFromSelection(c: Component): void
		{
			var i: int = this._selecteds.indexOf(c)
			
			if(i >= 0) {
				this._selecteds[i].selected = false
				this._selecteds[i].highlight = false
				
				this._selecteds.splice(i, 1)
			}
		}

		private function onSimpleNodeStart(e: MouseEvent):void
		{
			this.addEventListener("mouseUp", onSimpleNodeUp);
		}
		
		private function onSimpleNodeUp(e: MouseEvent): void
		{
			this.removeEventListener("mouseUp", onSimpleNodeUp)
			
			var p: Point = this.surface.globalToLocal(new Point(e.stageX, e.stageY))
			var n: Node = new Node(null, p.x, p.y)
			this.addNode(n)
		}
		
		private function onCompoundNodeStart(e: MouseEvent):void
		{
			this.addEventListener("mouseUp", onCompoundNodeUp);
		}
		
		private function onCompoundNodeUp(e: MouseEvent): void
		{
			this.removeEventListener("mouseUp", onCompoundNodeUp)
			
			var p: Point = this.surface.globalToLocal(new Point(e.stageX, e.stageY))
			var n: Node = new CompoundNode(null, p.x, p.y)
			this.addNode(n)
			
		}

		private function createSelectionRectangle(p: Point): void
		{
			var lp: Point = this.overlay.globalToLocal(p)
			this._selectionRect = new UIComponent
			this._selectionRect.x = lp.x
			this._selectionRect.y = lp.y
			this._selectionRect.width = 0
			this._selectionRect.height = 0
			
			this.overlay.addChildAt(this._selectionRect, 0)
		}
		
		private function updateSelectionRectangle(nw: Number, nh: Number): void
		{
			if(!_selectionRect)
				return
				
			this._selectionRect.width = nw
			this._selectionRect.height = nh
			
			this._selectionRect.graphics.clear()
			this._selectionRect.graphics.lineStyle(2, 0xF8B584, .65)
			Utils.drawDashedLine(this._selectionRect.graphics, 0, 0, 0, nh, 3, 3)
			Utils.drawDashedLine(this._selectionRect.graphics, 0, 0, nw, 0, 3, 3)
			Utils.drawDashedLine(this._selectionRect.graphics, nw, 0, nw, nh, 3, 3)
			Utils.drawDashedLine(this._selectionRect.graphics, 0, nh, nw, nh, 3, 3)

			this._selectionRect.graphics.lineStyle(2, 0xF8B584, 0)
			this._selectionRect.graphics.beginFill(0xFACAA6, .18)
			this._selectionRect.graphics.drawRect(0, 0, nw, nh)
			this._selectionRect.graphics.endFill()
			
		}

		private function removeSelectioRectangle(): void
		{
			if(this._selectionRect)
			{
				this.overlay.removeChild(this._selectionRect)
				this._selectionRect = null
			}
		}
		
		private var _prevSelection: Array
		
		private function onSelectionStart(e: MouseEvent): void
		{
			this.addEventListener("mouseMove", onSelectionMove);
			this.addEventListener("mouseUp", onSelectionUp);
			this.mouseChildren = false;	
			this.overlay.mouseChildren = false;
			
			this.createSelectionRectangle(new Point(e.stageX, e.stageY))
			this._prevSelection = Utils.cloneArray(this._selecteds)
		}
		
		private function onSelectionMove(e: MouseEvent): void
		{
			if(!this._selectionRect)
				return
			
			if(!e.buttonDown) {
				this.onSelectionUp(e)
				return
			}
			
			var dx: Number = (e.stageX - _stageStart.x) ;/// _surface.scaleX;
			var dy: Number = (e.stageY - _stageStart.y) ;/// _surface.scaleY;

			this.updateSelectionRectangle(dx, dy)
			
			var all: Array = Utils.merge(_nodes, _edges)
			for each(var c:* in all)
			{
				var i: int = _prevSelection.indexOf(c.view)
				
				if(this._selectionRect.getBounds(this.surface)
					.containsRect(c.view.getBounds(this.surface)))
				{
					addToSelection(c.view)
					
					if(i >= 0)
						_prevSelection.splice(i, 1)
				}
				else
				{
					if(i < 0) {
						removeFromSelection(c.view)
					}
				}
			}
			
		}
		
		private function onSelectionUp(e: MouseEvent): void
		{
			this.removeEventListener("mouseMove", onSelectionMove);
			this.removeEventListener("mouseUp", onSelectionUp);
			this.mouseChildren = true;
			this.overlay.mouseChildren = true;

			this.removeSelectioRectangle()
		}
		
		private function onMarqueeZoomStart(e: MouseEvent): void
		{
			this.addEventListener("mouseMove", onMarqueeZoomMove);
			this.addEventListener("mouseUp", onMarqueeZoomUp);
			this.mouseChildren = false;	
			this.overlay.mouseChildren = false;
			
			var lp: Point = this.overlay.globalToLocal(new Point(e.stageX, e.stageY))
			this._selectionRect = new UIComponent
			this._selectionRect.x = lp.x
			this._selectionRect.y = lp.y
			this._selectionRect.width = 0
			this._selectionRect.height = 0
			this.overlay.addChildAt(this._selectionRect, 0)
		}

		private function onMarqueeZoomMove(e: MouseEvent): void
		{
			if(!_selectionRect)
				return
				
			if(!e.buttonDown) {
				onMarqueeZoomUp(e, false)
				return
			}
			var dx: Number = (e.stageX - _stageStart.x) ;/// _surface.scaleX;
			var dy: Number = (e.stageY - _stageStart.y) ;/// _surface.scaleY;

			this._selectionRect.width = dx
			this._selectionRect.height = dy
			
			this._selectionRect.graphics.clear()
			this._selectionRect.graphics.lineStyle(2, 0xF8B584, .80)
			Utils.drawDashedLine(this._selectionRect.graphics, 0, 0, 0, dy, 3, 3)
			Utils.drawDashedLine(this._selectionRect.graphics, 0, 0, dx, 0, 3, 3)
			Utils.drawDashedLine(this._selectionRect.graphics, dx, 0, dx, dy, 3, 3)
			Utils.drawDashedLine(this._selectionRect.graphics, 0, dy, dx, dy, 3, 3)
			this._selectionRect.graphics.lineStyle(2, 0xF8B584, 0)
//			this._selectionRect.graphics.drawRect(0, 0, dx, dy)
			this._selectionRect.graphics.beginFill(0xFACAA6, .18)
			this._selectionRect.graphics.drawRect(0, 0, dx, dy)
			this._selectionRect.graphics.endFill()
		}
		
		private function onMarqueeZoomUp(e: MouseEvent, boundsValid: Boolean = true): void
		{

			this.removeEventListener("mouseMove", onMarqueeZoomMove);
			this.removeEventListener("mouseUp", onMarqueeZoomUp);
			this.mouseChildren = true;
			this.overlay.mouseChildren = true;

			if(boundsValid && _selectionRect)
			{
				var rect: Rectangle = this._selectionRect.getBounds(this.surface)
				if(rect.width > 5 || rect.height > 5) 
					this.zoomToBounds(rect)
			}
			
			removeSelectioRectangle()
		}

		private function onPanStart(e: MouseEvent): void
		{
			this.addEventListener("mouseMove", onPan);
			this.addEventListener("mouseUp", onPanStop);
			this.mouseChildren = false;	
			this.overlay.mouseChildren = false;
		}

		public static function unscaledPoint(p: Point): Point
		{
			return new Point(p.x / _instance._surface.scaleX, p.y / _instance._surface.scaleY);
		}	
		
		public function unscaledDx(dx: Number): Number {
			return dx / zoom
		}

		public function unscaledDy(dy: Number): Number {
			return dy / zoom
		}

		private function onPan(e: MouseEvent): void
		{

			var dx: Number = (e.stageX - _stageStart.x) ;/// _surface.scaleX;
			var dy: Number = (e.stageY - _stageStart.y) ;/// _surface.scaleY;

			_surface.x += dx;
			_surface.y += dy;

			this.dispatchEvent(new Event("boundsChanged"))
			
			_stageStart.x = e.stageX;
			_stageStart.y = e.stageY;

		}
		
		private function onPanStop(e: MouseEvent): void
		{
			this.removeEventListener("mouseMove", onPan);
			this.removeEventListener("mouseUp", onPanStop);
			this.mouseChildren = true;
			this.overlay.mouseChildren = true;
		}
		
		public function addNode(node:Node):void {
			
			this._surface.addChildAt(node.view, 0)
			
			if(node.parent)
				node.parent.removeNode(node)
				
			_nodes.push(node);
			node.parent = null

//			this.refreshMinimap(null)
		}

		public function remove(a: Array): void
		{
			var c:*;
			var i: int = 0;

			i = 0;
			while(i < a.length)
			{ 
				if(a[i] is NodeComponent && (_nodes.indexOf(a[i].model) > -1))
					removeNode(a[i].model);
				++i;
			}

			i = 0;
			while(i < a.length)
			{
				if(a[i] is EdgeComponent && (_edges.indexOf(a[i].model) > -1))
					removeEdge((a[i] as EdgeComponent).model as Edge);
				++i;
			}
			
		}	
		
		public function hasEdge(fromId: String, toId: String, directed: Boolean = false): Boolean
		{
			for each(var e: Edge in _edges)
				if((e.source.id == fromId && e.target.id == toId) ||
				 (!directed && e.source.id == toId && e.target.id == fromId))
					return true;
			
			return false;
		}
		
		public function removeNode(node: Node): void
		{
			if(node.isCompound())
			{
				var c: CompoundNode = node as CompoundNode
				while(c.nodes.length > 0)
					removeNode(c.nodes[0])
			}
			
			var i: int = 0;
			while(i < _edges.length) {
				if(_edges[i].source === node || _edges[i].target === node)
					removeEdge(_edges[i]);
				else
					++i;
			}
							
			TweenMax.killTweensOf(node.view);
			
			if(node.parent)
				node.parent.removeNode(node)

			this._surface.removeChild(node.view)
				
			i = _nodes.indexOf(node)
			if(i < 0)
				trace("WARNING: node index out of bounds")
			
			_nodes.splice(i, 1);
			
			dispatchEvent(new NodeRemoved(node));
//			this.refreshMinimap(null)
			
		}
		
		public function removeEdge(edge: Edge): void
		{
			TweenMax.killTweensOf(edge.view);
			
			var b1: Boolean = this.contains(edge.view)
			var b2: Boolean = _edges.indexOf(edge) > -1
			
			this._surface.removeChild(edge.view);
			var ei: int = _edges.indexOf(edge)
			
			if(ei < 0)
				trace("WARNING: edge index out of bounds")
		
			_edges.splice(ei, 1);
			
			dispatchEvent(new EdgeRemoved(edge));
//			this.refreshMinimap(null)
		}
		
		public function addEdge(edgeId: String, fromId: String, toId: String): Edge
		{
			var source: Node = nodeFromId(fromId)
			var target: Node = nodeFromId(toId)
			
			var e: Edge = new Edge(edgeId, source, target)
			
			if(source === target)
			{
				var p: Point = new Point(source.width/2, 1.5*source.height)
				var bnd:* = { point: p, index: 0, isNew: true }	
				e.addBend(bnd)
				
				p = new Point(1.5*source.width, source.height/2)
				bnd = { point: p, index: 1, isNew: true }
				e.addBend(bnd)
				
				var ev: EdgeComponent = e.view as EdgeComponent
				ev.recalcPoints()
				ev.invalidateDisplayList()
			}
			
			_edges.push(e);
			this._surface.addChildAt(e.view, 0);

			// bring the edge on top of the compound ancestors
			var anc1: Node = e.source.parent
			var anc2: Node = e.target.parent
			var i: int = -1
			
			while(anc1 || anc2)
			{
				var pi1: int = anc1 ? surface.getChildIndex(anc1.view) : -1
				var pi2: int = anc2 ? surface.getChildIndex(anc2.view) : -1
				i = Math.max(i, pi1, pi2)

				if(anc1)
					anc1 = anc1.parent
				if(anc2)
					anc2 = anc2.parent
									
			}
			var ci: int = surface.getChildIndex(e.view)
			if(i > ci)
				surface.setChildIndex(e.view, i)
			
//			this.refreshMinimap(null)
			
			return e;
		}

		public function nodeFromId(id: String): Node
		{
			for each(var n: Node in _nodes)
			{
				var m: Node = n.findNode(id)
				if(m != null)
					return m
			}
			
			return null;
		}

		private function nodeFromGraphML(xml: XML): Node
		{
			use namespace gmlns
			var isCompound: Boolean = (xml.graph.length() > 0)
			var d: XMLList= xml.data;
			var n: Node = isCompound ? new CompoundNode(xml.@id): new Node(xml.@id)
			var node: XML
			
			n.x = d.(@key == "x");
			n.y = d.(@key == "y");
			n.width = d.(@key == "width");
			n.height = d.(@key == "height");
			n.clusterID = d.(@key == "clusterID");
			
			var nv: NodeComponent = n.view as NodeComponent;
			nv.color2 = Utils.colorFromString(d.(@key == "color"));
			var s: String = d.(@key == "color1");
			if('' != s)
				nv.color1 = Utils.colorFromString(s);
			nv.shape = d.(@key == "shape");
			nv.longLabelText = d.(@key == "text")

			this.addNode(n)
			
			for each(node in xml.graph.node)
				(n as CompoundNode).addNode(this.nodeFromGraphML(node))
			
			if(isCompound)
				(n as CompoundNode).recalcBounds()			

			return n
			
		}
		
		public function fromGraphML(xml: XML): void
		{
			reset();
			
			var d: XMLList;
			use namespace gmlns;
			
			for each (var node: XML in xml.graph.node) {
				var n: Node = nodeFromGraphML(node)
//				this.addNode(n)
			}
			
			for each (var ed: XML in xml..graph.edge)
			{
				d = ed.data;
				//TOOD: set edge ids
				var e: Edge = addEdge(
					null,
					ed.@source,
					ed.@target);
				e.id = ed.@id
				var ev: EdgeComponent = e.view as EdgeComponent;
				ev.color = Utils.colorFromString(d.(@key == "color"));
				ev.lineStyle = d.(@key == "style");
				ev.weight = d.(@key == "width");
				ev.targetArrow = d.(@key == "arrow");
			}

			centerView()			
		}	

		private function centerView(): void
		{
			
			var b:* = this.bounds
			var xs: int = (this.width - b.width) / 2
			var ys: int = (this.height - b.height) / 2
			this._surface.x = xs > 0 ? xs : 0
			this._surface.y = ys > 0 ? ys : 0
		}
		
		public function toGraphML(): XML
		{
			var res: String = '<graphml xmlns="http://graphml.graphdrawing.org/xmlns"> <key id="x" for="node" attr.name="x" attr.type="int"/> <key id="y" for="node" attr.name="y" attr.type="int"/> <key id="height" for="node" attr.name="height" attr.type="int"/> <key id="width" for="node" attr.name="width" attr.type="int"/> <key id="shape" for="node" attr.name="shape" attr.type="string"/> <key id="clusterID" for="node" attr.name="clusterID" attr.type="string"/> <key id="margin" for="graph" attr.name="margin" attr.type="int"/> <key id="style" for="edge" attr.name="style" attr.type="string"/> <key id="arrow" for="edge" attr.name="arrow" attr.type="string"/> <key id="bendpoint" for="edge" attr.name="bendpoint" attr.type="string"/> <key id="color" for="all" attr.name="color" attr.type="string"/> <key id="color1" for="node" attr.name="color1" attr.type="string"/> <key id="borderColor" for="all" attr.name="borderColor" attr.type="string"/> <key id="text" for="all" attr.name="text" attr.type="string"/> <key id="textFont" for="all" attr.name="textFont" attr.type="string"/> <key id="textColor" for="all" attr.name="textColor" attr.type="string"/> <key id="highlightColor" for="all" attr.name="highlightColor" attr.type="string"/>';
			res += '<graph id="" edgedefault="undirected">';
			
			for each(var n: Node in _nodes)
				if(n.parent == null)
					res += n.toGraphML()
						
			var e: Edge;
			for each(e in _edges)
			{
				var ev: EdgeComponent = e.view as EdgeComponent;
				res += '<edge id="' + e.id + '" source="' + e.source.id + '" target="' + e.target.id + '">';
				var cs: Array = Utils.intToRgb(ev.color)
				res += '<data key="color">' + cs[2] + ' ' +  cs[1]+ ' ' + cs[0] + '</data>';
				res += '<data key="text"/>';
				//res += '<data key="textFont">1|Arial|8|0|WINDOWS|1|-11|0|0|0|0|0|0|0|1|0|0|0|0|Arial</data>'
				//res += '<data key="textColor">0 0 0</data>'
				res += '<data key="style">' + ev.lineStyle + '</data>';
				res += '<data key="arrow">' + ev.sourceArrow + '</data>';
				res += '<data key="width">' + ev.weight + '</data>';
				res += '</edge>'
			}
			res += '</graph>\n</graphml>';
  			
			return XML(res);
		}
		
		public function toXML(): XML
		{
			var result:String = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><view>'
			
			for each(var n: Node in _nodes)
				if (n.parent == null)
					result += n.asXML()
			
			for each(var e: Edge in _edges)
				result += e.asXML()
			
			result += "</view>"
			
			return XML(result);
		}
		
		public function toSvg(): XML
		{
			var b:* = this.bounds
			
			var res: String = '<?xml version="1.0" encoding="UTF-8"?>' +
				'<svg xmlns="http://www.w3.org/2000/svg" version="1.2"' +
     			'>'

			var n: Node
			var cs: Array = new Array
			for each(n in _nodes)
				if(n.isCompound())
					res += n.toSvg()
				else
					cs.push(n)
			for each(n in cs)
				if(!n.isCompound())
					res += n.toSvg()
			
			for each(var e: Edge in _edges)
				res += e.toSvg()

			res += '</svg>'
			
			return XML(res)
		}
		
		public function reset(): void {
			
			BrowserManager.getInstance().setTitle("i-Vis Layout Demo - Untitled");

			// TODO: remove graph inspector??
			
			TweenMax.killAllTweens();
			this.surface.removeAllChildren()
			
			resetView()
							
			var i: int = 0
			for(; i < _nodes.length; ++i)
				delete _nodes[i]

			for(i = 0; i < _edges.length; ++i)
				delete _edges[i]
								
			_edges = new Array;
			_nodes = new Array;
			
			Node.resetIDCounter()
			Node.resetClusterCounter()
			
		}

		public function resetView(resetPosition: Boolean = true): void
		{
			if(resetPosition) {
				// reset origin
				this.surface.x = this.surface.y = 0
			}
			
			// reset zoom
			this.zoom = 1;
		}
		
		public function fromXML(xml: XML): void
		{
			this.reset()
			var graph: Graph = _instance
						
			for each(var xn: XML in xml..node)
				graph.addNode(Node.fromXML(xn))
			
			for each(var edge: XML in xml..edge) {
				var fromId: String = edge.sourceNode.@id;
				var toId: String = edge.targetNode.@id;
				if((fromId != null) && (toId != null)) {
					graph.addEdge(edge.@id, fromId, toId);
				}
			}
			
		}
		
		public function animateToNewPositions(xml: XML): void
		{
			var tm: TweenMax
			
			this.smoothPanTo(0, 0)
			
			for each(var xmlNode: XML in xml..node)
			{
				var node: Node = nodeFromId(xmlNode.@id)
				tm = node.animateTo(xmlNode)
			}

			tm.addEventListener(TweenEvent.COMPLETE, function(e: Event): void {
				refreshMinimap(null)
//				centerView()				
			}, false, 0, true)
		}
		
		public function compoundUnderPoint(x: Number, y: Number, exc: Node = null): CompoundNode
		{
			var res: CompoundNode
			
			for each(var n: Node in _nodes)
			{
				if(n != exc) {
					res = n.compoundUnderPoint(x, y, exc)
					if(res)
						break
				}
			}
			
			return res
		}
		
		public function get selection(): Array {
			return _selecteds;
		}

		internal function selectedNodes(): Array
		{
			var res: Array = new Array
			
			for each(var n: Node in _nodes)
				if(n.view.selected)
					res.push(n)
					
			return res
		}	
			
		override public function toString():String
		{
			var n: Node;
			var result: String = "==nodes==\n";
			for each (n in _nodes)
				result += n + "\n";

			result += "==edges==\n";
			for each(var e: Edge in _edges)
				result += e + "\n";
				
			return result;			
		}
		
		public function get zoomBuddy(): Slider
		{
			return _zoomBuddy;
		}
		
		public function set zoomBuddy(value: Slider): void
		{
			this._zoomBuddy = value;
			this._zoomBuddy.minimum = ZOOM_MIN
			this._zoomBuddy.maximum = ZOOM_MAX
			this._zoomBuddy.addEventListener("change", function(e: SliderEvent): void {
				zoom = e.value;
			});
		}
		
		public function get surface(): Canvas {
			return _surface;
		}
		
		public function set surface(value: Canvas): void {
			_surface = value;
//			this._surface.opaqueBackground = CANVAS_BACKGROUND_COLOR;
		}
		
		public function get margin(): uint
		{
			return _margin;
		}
		
		public function set margin(value: uint): void
		{
			this._margin = value;
		}
		
		public function properties(): Array
		{
			return [
						{ key: "Margin", value: _margin },
						{ key: "Highlight Color", value: Component.highlightColor },
					];
		}
		
		public function getCompatibleBitmap(forMap: Boolean = true): BitmapData
		{
			if(this.surface.width <= zoom || this.surface.height <= zoom)
				return null
			
			var res: BitmapData = new BitmapData(this.surface.width / zoom, this.surface.height / zoom,
				!forMap, MAP_BACKGROUND_COLOR)
			return res
		}
		
		public function drawOnBitmap(bm: BitmapData, mat: Matrix = null): void
		{
			bm.draw(this.surface, mat, null, null, null, false)
		}
	
		public function smoothPanTo(x: Number, y: Number, time: Number = .75): void
		{
			TweenMax.to(_surface, time, { x: Number(x), y: Number(y), ease: gs.easing.Expo.easeOut })
		}
		
		public function assignClusterIDs(): void
		{
			if(_selecteds.length == 0)
				return
			
			var cid: int = Node.nextClusterID()
			
			for each(var n:* in _selecteds)
			{
				if(n is NodeComponent)
				{
					(n as NodeComponent).model.clusterID = cid
				}
			}
		}
		
		public function assignRandomClusterIDs(): void
		{
			var num: uint = this._nodes.length
			if(num < 1)
				return

			var parts: Array = Utils.randomPartition(num)
			var pl: uint = parts.length
			var track: Array = Utils.cloneArray(this._nodes)

			for(var i: int = 0; i < pl; ++i)
			{
				var cid: int = Node.nextClusterID()
				
				for(var j: int = 0; j < parts[i]; ++j)
				{
					var nn: uint = Math.floor(Math.random() * track.length)
					
					var node: Node = track[nn] as Node
					node.clusterID = cid
					track.splice(nn, 1)
				}
			}
			
			colorUsingClusterIDs()
		}
		
		public function resetClusterOfSelected(): void
		{
			for each(var n:* in _selecteds)
				if(n is NodeComponent)
				{
					var nv: NodeComponent = n as NodeComponent
					nv.model.clusterID = 0
					nv.color2 = NodeComponent.DEFAULT_FILL_COLOR2
				}
		}
		
		private function clustersNo(): uint
		{
			var clusters: Object = new Object
			var count: uint = 0
			
			for each(var n: Node in _nodes)
				if(!clusters.hasOwnProperty(n.clusterID)) {
					++count
					clusters[n.clusterID] = "done"
				}
			
			return count
		}
		
		public function colorUsingClusterIDs(): void
		{
			var colors: Object = new Object
			var n: Node
			var nv: NodeComponent
			
			var minRgb: uint = 32
			var maxRgb: uint = 250
			var step: int = 6 * Math.ceil((maxRgb - minRgb) / clustersNo())
			var i: int = 0
			var rgb: Array = new Array
			
			rgb[0] = rgb[1] = rgb[2] = minRgb
						
			var tc: Array = Utils.cloneArray(rgb)

			for each(n in _nodes)
			{
				
				nv = n.view as NodeComponent
				
				if(n.clusterID > 0)
				{
					var c: uint = 0

					if(!colors.hasOwnProperty(n.clusterID))
					{
						tc[i % 3] = Math.min(rgb[i % 3] + step, maxRgb)
						if(i > 2) {
							var j: int = ((i / 3) + (i % 3)) % 3
							tc[j] = Math.min(rgb[j] + step, maxRgb)
						} 
						var color: int = Utils.rgbToInt(tc)
						colors[n.clusterID] = color
						c = color
						
						++i
						if(i == 6) {
							rgb[0] = Math.min(rgb[0] + step, maxRgb)
							rgb[1] = Math.min(rgb[1] + step, maxRgb)
							rgb[2] = Math.min(rgb[2] + step, maxRgb)
							i = 0
						}
						tc = Utils.cloneArray(rgb)
					}
					else
						c = colors[n.clusterID]
					
					nv.color2 = c
				}
				else
					nv.color2 = NodeComponent.DEFAULT_FILL_COLOR2
					
			}
		}
		
		public function get animationTime(): Number
		{
			return _animationTime
		}
		
		public function set animationTime(value: Number): void
		{
			this._animationTime = value
		}
		
		public function get generalOptions(): Object
		{
			return _generalOptions
		}
		
		public function set generalOptions(value: Object): void
		{
			this._generalOptions = value
			
			if(!_generalOptions.animateOnLayout)
				this.animationTime = 0
			else
				this.animationTime = DEFAULT_ANIMATION_TIME
		}
		
		public function get CoSEOptions(): Object
		{
			return this._CoSEOptions
		}
		
		public function set CoSEOptions(value: Object): void
		{
			this._CoSEOptions = value
		}

		public function get CiSEOptions(): Object
		{
			return this._CiSEOptions
		}
		
		public function set CiSEOptions(value: Object): void
		{
			this._CiSEOptions = value
		}
	}
}