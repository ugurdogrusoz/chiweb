package ivis.ui
{
	import __AS3__.vec.Vector;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import gs.TweenMax;
	
	import ivis.model.Edge;
	import ivis.model.Graph;
	import ivis.model.Node;
	
	import mx.containers.Canvas;
	import mx.core.ScrollPolicy;

	/**
	 * 
	 * @author Ebrahim
	 */
	public class GraphComponent extends Canvas
	{
		/**
		 * 
		 * @default 
		 */
		private var _model: Graph;
		/**
		 * 
		 * @default 
		 */
		private var _surface: Canvas;
		/**
		 * 
		 * @default 
		 */
		private var _mouseTarget: DisplayObject;
		/**
		 * 
		 * @default 
		 */
		private var _panning: Boolean = false;
		/**
		 * 
		 * @default 
		 */
		private var _stageX: Number;
		/**
		 * 
		 * @default 
		 */
		private var _stageY: Number;
		/**
		 * 
		 * @default 
		 */
		private var _nodes: Vector.<NodeComponent>;
		/**
		 * 
		 * @default 
		 */
		private var _edges: Vector.<EdgeComponent>;
		
		/**
		 * 
		 * @param model
		 */
		override public function GraphComponent(model: Graph = null)
		{
			super();
			
			this._nodes = new Vector.<NodeComponent>;
			this._edges = new Vector.<EdgeComponent>;
			
			this._model = model != null ? model : new Graph;
			
			this.horizontalScrollPolicy = ScrollPolicy.OFF;
			this.verticalScrollPolicy = ScrollPolicy.OFF;
			
			this.registerMouseHandlers();
		}

		/**
		 * 
		 */
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
		
		/**
		 * 
		 * @return 
		 */
		public function get model(): Graph
		{
			return this._model;
		}
		
		/**
		 * 
		 * @param model
		 */
		public function set model(model: Graph): void
		{
			this._model = model;
		}
		
		//
		// public methods
		//

		/**
		 * 
		 * @param nodeComponent
		 */
		public function addNode(nodeComponent: NodeComponent): void
		{
			var n: Node = nodeComponent.model as Node;
			this.model.addNode(n);
			this._surface.addChild(nodeComponent);
			this._nodes.push(nodeComponent);
			nodeComponent.parentComponent = this;
		}
		
		/**
		 * 
		 * @param nodeComponent
		 */
		public function removeNode(n: NodeComponent): void
		{
			if(!this._surface.contains(n))
				return;
				
			this._surface.removeChild(n);

			n._incidentEdges.forEach(function (item: EdgeComponent, i: int, v: Vector.<EdgeComponent>): void {
				removeEdge(item, false);
			});
			
			this._nodes.splice(this._nodes.indexOf(n), 1);

		}
		
		/**
		 * 
		 * @param e
		 * @param removeIncidents
		 */
		public function removeEdge(e: EdgeComponent, removeIncidents: Boolean = true): void
		{
			if(!this._surface.contains(e))
				return;
			
			this._surface.removeChild(e);
				
			this._edges.splice(this._edges.indexOf(e), 1);
			
			if(removeIncidents) {
				var ies: Vector.<EdgeComponent>;
				ies = e.sourceComponent._incidentEdges; 
				ies.splice(ies.indexOf(e), 1);
				ies = e.targetComponent._incidentEdges;
				ies.splice(ies.indexOf(e), 1);
			}
		}
		
		/**
		 * 
		 * @param edgeComponent
		 */
		public function addEdge(edgeComponent: EdgeComponent): void
		{
			this.model.addEdge(edgeComponent.model as Edge);
			this._surface.addChild(edgeComponent);
			this._edges.push(edgeComponent);
		}

		/**
		 * 
		 * @return 
		 */
		public function asXML(): XML
		{
			var result:String = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><view>'

			this._nodes.forEach(function (item: NodeComponent, i: int, v: Vector.<NodeComponent>): void {
				result += item.asXML();
			}, this._nodes);

			this._edges.forEach(function (item: EdgeComponent, i: int, v: Vector.<EdgeComponent>): void {
				result += item.asXML();
			}, this._edges);
					
			result += "</view>"
			
			return XML(result);
		}
		
		/**
		 * 
		 * @param xml
		 */
		public function animateToNewPositions(xml: XML): void
		{
			//this.smoothPanTo(0, 0)
			
			for each(var xmlNode: XML in xml.node)
			{
				var node: NodeComponent = getNodeById(xmlNode.@id)
				node.animateToNewPositon(xmlNode)
			}
		}
		
		//
		// private methods
		//
				
		/**
		 * 
		 * @param e
		 */
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

		/**
		 * 
		 * @param e
		 */
		private function onPan(e: MouseEvent): void
		{
			var dx: Number = e.stageX - this._stageX;
			var dy: Number = e.stageY - this._stageY;
			
			this._surface.x += dx;
			this._surface.y += dy;
			
			this._stageX = e.stageX;
			this._stageY = e.stageY;
			
		}

		/**
		 * 
		 * @param e
		 */
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
			
			e.updateAfterEvent();
		}
		
		/**
		 * 
		 * @param e
		 */
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
				
		/**
		 * 
		 */
		private function registerMouseHandlers(): void
		{
			this.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_WHEEL, this.onMouseWheel);
		}
		
		/**
		 * 
		 * @param e
		 */
		private function onMouseWheel(e: MouseEvent): void
		{
			var m: Matrix = this._surface.transform.matrix;
			var s: Number = e.delta > 0 ? 1.1 : .9;
			var p: Point = new Point(e.stageX, e.stageY);
			p = this.globalToContent(p);
			
			m.translate(-p.x, -p.y);
			m.scale(s, s);
			m.translate(p.x, p.y);
			this._surface.transform.matrix = m;
			// TODO: fix the clipping issues
			
			e.stopImmediatePropagation();
		}
		
		/**
		 * 
		 * @param id
		 * @return 
		 */
		public function getNodeById(id: String): NodeComponent
		{
			var result: NodeComponent = null;
			
			this._nodes.some(function (item: NodeComponent, i: int, v: Vector.<NodeComponent>): Boolean {
				if(item.model.id == id) {
					result = item;
					return true;
				}
				return false;
			}, this._nodes);
			
			return result;
		}
	}
}