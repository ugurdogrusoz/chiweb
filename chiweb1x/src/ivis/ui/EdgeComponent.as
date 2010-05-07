package ivis.ui
{
	import __AS3__.vec.Vector;
	
	import flash.geom.Point;
	
	import ivis.model.Edge;
	import ivis.model.Node;
	
	import mx.events.MoveEvent;

	/**
	 * 
	 * @author Ebrahim
	 */
	public class EdgeComponent extends Component
	{
		
		private var _bends: Vector.<Point>;
		
		private var _sourceComponent: NodeComponent;
		
		private var _targetComponent: NodeComponent;
		
		/**
		 * 
		 * @default 
		 */
		private var _renderer: IEdgeRenderer;
		
		/**
		 * 
		 */
		public function EdgeComponent(source: NodeComponent, target: NodeComponent)
		{
			super();
		
			this.sourceComponent = source;
			this.targetComponent = target;
				
			this.model = new Edge(null, source.model as Node, target.model as Node);
			this._renderer = new EdgeRenderer(this);
			this._bends = new Vector.<Point>
		}
		
		//
		// getters and setters
		//
		
		public function get sourceComponent(): NodeComponent
		{
			return this._sourceComponent;
		}
		
		public function set sourceComponent(sc: NodeComponent): void
		{
			if(this._sourceComponent != null)
				this.unregisterSourceEventHadlers();
				
			this._sourceComponent = sc;
			
			this.registerSourceEventHadlers();			
		}
		
		public function get targetComponent(): NodeComponent
		{
			return this._targetComponent;
		}
		
		public function set targetComponent(tc: NodeComponent): void
		{
			if(this._targetComponent != null)
				this.unregisterTargetEventHadlers();
			
			this._targetComponent = tc;
			
			this.registerTargetEventHadlers();
		}
		
		/**
		 * 
		 * @return 
		 */
		public function get renderer(): IEdgeRenderer
		{
			return this._renderer;
		}
		
		/**
		 * 
		 * @param r
		 */
		public function set renderer(r: IEdgeRenderer): void
		{
			this._renderer = r;
		}

		//
		// public methods
		//
		
		override public function clone(): Component
		{
			var result: EdgeComponent = new EdgeComponent(
				this._sourceComponent, this._targetComponent);
				
			result.model = this.model;
			result.renderer = this.renderer;
			
			return result;
		}

		/**
		 * 
		 * @param p
		 */
		public function addBend(p: Point): void
		{
			this._bends.push(p);
		}
		
		/**
		 * 
		 * @param p
		 * @return 
		 */
		public function removeBend(p: Point): Boolean
		{
			var index: int;
			
			index = this.findBend(p);
			if(index >= 0) {
				this._bends.splice(index, 1)
				return true;
			}
			
			return false; 
		}
		
		//
		// protected methods
		//
		
		/**
		 * 
		 * @param unscaledWidth
		 * @param unscaledHeight
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number): void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			this._renderer.draw(this.graphics);
		}
		
		//
		// private methods
		// 

		private function registerSourceEventHadlers(): void
		{
			this._sourceComponent.addEventListener(MoveEvent.MOVE, this.onNodeMoved);
		}
		
		private function unregisterSourceEventHadlers(): void
		{
			this._sourceComponent.removeEventListener(MoveEvent.MOVE, this.onNodeMoved);
		}
		
		private function registerTargetEventHadlers(): void
		{
			this._targetComponent.addEventListener(MoveEvent.MOVE, this.onNodeMoved);
		}
		
		private function unregisterTargetEventHadlers(): void
		{
			this._targetComponent.removeEventListener(MoveEvent.MOVE, this.onNodeMoved);
		}
		
		private function onNodeMoved(e: MoveEvent): void
		{
			this.invalidateDisplayList();
		}
		
		/**
		 * 
		 * @param p
		 * @return 
		 */
		private function findBend(p: Point): int
		{
			var result: int = -1;
			
			this._bends.some(
				function (item: Point, index: int, vector: Vector.<Point>): Boolean {
					if(item.x != p.x || item.y != p.y)
						return false;
						
					result = index;
					return true;
				}
			);
			
			return result;
		}

		
	}
}