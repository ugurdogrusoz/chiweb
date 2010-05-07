package ivis.ui
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import ivis.model.Edge;
	import ivis.model.Graph;
	import ivis.model.Node;
	
	import mx.containers.Canvas;
	import mx.core.ScrollPolicy;

	public class GraphComponent extends Canvas
	{
		private var _model: Graph;
		private var _surface: Canvas;
		private var _mouseTarget: DisplayObject;
		private var _panning: Boolean = false;
		private var _stageX: Number;
		private var _stageY: Number;
		
		
		override public function GraphComponent(model: Graph = null)
		{
			super();
			
			this._model = model != null ? model : new Graph;
			
			this.horizontalScrollPolicy = ScrollPolicy.OFF;
			this.verticalScrollPolicy = ScrollPolicy.OFF;
			
			this.registerMouseHandlers();
		}

		override protected function createChildren():void
		{
			super.createChildren();
			
			this._surface = new Canvas;			
			this._surface.clipContent = false;
			this.addChild(this._surface);
		}
		
		//
		// getters and setters		
		//
		
		public function get model(): Graph
		{
			return this._model;
		}
		
		public function set model(model: Graph): void
		{
			this._model = model;
		}
		
		//
		// public methods
		//

		public function addNode(nodeComponent: NodeComponent): void
		{
			var n: Node = nodeComponent.model as Node;
			this.model.addNode(n);
			this._surface.addChild(nodeComponent);
		}
		
		public function removeNode(nodeComponent: NodeComponent): void
		{
			// TODO: remove edges...
		}
		
		public function addEdge(edgeComponent: EdgeComponent): void
		{
			this.model.addEdge(edgeComponent.model as Edge);
			this._surface.addChild(edgeComponent);
		}
		
		//
		// private methods
		//
		
		private function initScrollRect(): void
		{
			this.scrollRect = new Rectangle(0, 0, 1000, 1000);
		}
		
		private function onMouseDown(e: MouseEvent): void
		{
			this._mouseTarget = e.target as DisplayObject;
			
			if(this._mouseTarget == this)
			{
				this._panning = true;
				
				this._stageX = e.stageX; 				
				this._stageY = e.stageY;
			}
			else if(this._mouseTarget is Component)
			{
				var c: Component = e.target as Component;
				c.mouseAdapter.onMouseDown(e);
			}

			this.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
			this.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);
		}

		private function onPan(e: MouseEvent): void
		{
			var dx: Number = e.stageX - this._stageX;
			var dy: Number = e.stageY - this._stageY;
			
			this._surface.x += dx;
			this._surface.y += dy;
			
			this._stageX = e.stageX;
			this._stageY = e.stageY;
			
			e.updateAfterEvent();
		}

		private function onMouseMove(e: MouseEvent): void
		{
			if(this._mouseTarget == this)
			{
				this.onPan(e);
			}
			else if(this._mouseTarget is Component)
			{
				var c: Component = this._mouseTarget as Component;
				c.mouseAdapter.onMouseMove(e);
			}
		}
		
		private function onMouseUp(e: MouseEvent): void
		{
			if(this._mouseTarget == this)
			{
				this._panning = false;
			}
			else if(this._mouseTarget is Component)
			{
				var c: Component = this._mouseTarget as Component;
				c.mouseAdapter.onMouseUp(e);
			}
			
			this.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			this.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
				
		private function registerMouseHandlers(): void
		{
			this.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_WHEEL, this.onMouseWheel);
		}
		
		private function onMouseWheel(e: MouseEvent): void
		{
			var m: Matrix = this._surface.transform.matrix;
			var s: Number = e.delta > 0 ? 1.1 : .9;
			m.translate(-e.stageX, -e.stageY);
			m.scale(s, s);
			m.translate(e.stageX, e.stageY);
			this._surface.transform.matrix = m;
			// TODO: fix clipping issues
		}
		
	}
}