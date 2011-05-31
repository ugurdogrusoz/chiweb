package ivis.ui
{
	import __AS3__.vec.Vector;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * 
	 * @author Ebrahim
	 */
	public class CompoundNodeComponent extends NodeComponent
	{
		
		internal const MIN_WIDTH: Number = 60;

		internal const MIN_HEIGHT: Number = 60;
		
		/**
		 * 
		 * @default 
		 */
		private var _nodes: Vector.<NodeComponent>;
		
		internal var _cachedBounds: Rectangle;
		
		/**
		 * 
		 */
		public function CompoundNodeComponent()
		{
			super();
		}
		
		//
		// public methods
		//

		/**
		 * 
		 * @param n
		 */
		public function addNode(n: NodeComponent): void
		{
			if(n.parentComponent != null)
				n.parentComponent.detachNode(n);
				
			this._nodes.push(n);
			n.parentComponent = this;
			
			this.invalidateBounds();
		}	
		
		/**
		 * 
		 * @param n
		 */
		public function removeNode(n: NodeComponent): void
		{
			this._nodes.splice(this._nodes.indexOf(n), 1);
			this.invalidateBounds();
		}
		
		/**
		 * 
		 * @param n
		 */
		public function detachNode(n: NodeComponent): void
		{
			this._nodes.splice(this._nodes.indexOf(n), 1);
		}

		/**
		 * 
		 * @param f
		 */
		public function forEachNode(f: Function): void
		{
			this._nodes.forEach(function (item: NodeComponent, i: int, v: Vector.<NodeComponent>): void {
				f.call(item, item);
			});
		}
		
		/**
		 * 
		 * @return 
		 */
		override public function get bounds(): Rectangle
		{
			return this._cachedBounds;
		}

		/**
		 * 
		 * @param xmlNode
		 */
		override public function animateToNewPositon(xmlNode: XML): void
		{
			
			for each(var xml: XML in xmlNode.children.node) {
				var node: NodeComponent = this.getNodeById(xml.@id);
				node.animateToNewPositon(xml);
			}
		}
		
		/**
		 * 
		 * @return 
		 */
		override public function clone(): Component
		{
			var result: NodeComponent = new CompoundNodeComponent;
			result.model = this.model;
			result.renderer = this.renderer;
			
			return result;
		}

		/**
		 * 
		 * @return 
		 */
		override public function asXML(): XML
		{
			var res: String = '<node id="' + this.model.id + '" ' +
				'clusterID="' + clusterId + '">' +
				'<bounds height="' + this.height +
				'" width="' + this.width + 
				'" />' + 
				'<children>'
			
			for each(var c: NodeComponent in _nodes)
				res += c.asXML()
			
			res += '</children></node>'
			
			return XML(res)
		} 
		
		/**
		 * 
		 * @return 
		 */
		override public function get center(): Point
		{
			return new Point(this._cachedBounds.x + this._cachedBounds.width / 2,
				this._cachedBounds.y + this._cachedBounds.height / 2);
		}
		
		//
		// public methods
		//
		
		/**
		 * 
		 * @param doc
		 */
		public function bringUpChildren(doc: DisplayObjectContainer): void
		{
			this._nodes.forEach(function (item: NodeComponent, i: int, v: Vector.<NodeComponent>): void {
				if(item.isCompound())
					(item as CompoundNodeComponent).bringUpChildren(doc);
			}, this);

			doc.setChildIndex(this, 0);
		}
		
		/**
		 * 
		 * @return 
		 */
		override public function isCompound(): Boolean
		{
			return true;
		}
		
		/**
		 * 
		 * @param dx
		 * @param dy
		 */
		override public function translate(dx: Number, dy: Number): void
		{
			this._nodes.forEach(function (item: NodeComponent, i: int, v: Vector.<NodeComponent>): void {
				item.translate(dx, dy);
			});
			
			this.invalidateBounds();
		}
		
		/**
		 * 
		 */
		public function invalidateBounds(): void
		{
			this._cachedBounds.setEmpty();
			
			if(this._nodes.length == 0)
				this._cachedBounds = new Rectangle(this.x, this.y, this.MIN_WIDTH, this.MIN_HEIGHT);
			else
				this._nodes.forEach(function (item: NodeComponent, i: int, v: Vector.<NodeComponent>): void {
					this._cachedBounds = this._cachedBounds.union(item.bounds);
				}, this);
			
			this._cachedBounds.inflate(this.margin, this.margin);
			
			this.x = this._cachedBounds.x;
			this.y = this._cachedBounds.y;
			this.width = this._cachedBounds.width;
			this.height = this._cachedBounds.height;
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

		/**
		 * 
		 */
		override protected function initializeComponent(): void
		{
			this.margin = DEFAULT_MARGIN;

			this.renderer = new CompoundNodeRenderer;
			this.mouseAdapter = new CompoundNodeMouseAdapter;
			
			this._nodes = new Vector.<NodeComponent>;

			this._cachedBounds = new Rectangle;

			this.parentComponent = null;
		
			this._incidentEdges = new Vector.<EdgeComponent>;
			
			this.shadow = true;
			
			this.registerEventHandlers();
		}
		
		//
		// private methods
		//
		
		/**
		 * 
		 * @param e
		 */
		private function onChildChanged(e: Event): void
		{
			this.invalidateBounds();
			this.invalidateDisplayList();
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
	
		/**
		 * 
		 * @param e
		 */
		override protected function onGeometryChanged(e: Event): void
		{
			if(this.parentComponent is CompoundNodeComponent) {
				this.parentComponent.invalidateBounds();
			}
			
			this._incidentEdges.forEach(function (item: EdgeComponent, i: int, v: Vector.<EdgeComponent>): void {
				item.invalidateDisplayList();
			});
			
			
		}
		
	}
}