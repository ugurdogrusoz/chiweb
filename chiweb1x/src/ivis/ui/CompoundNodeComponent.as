package ivis.ui
{
	import __AS3__.vec.Vector;
	
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
	
			this.renderer = new CompoundNodeRenderer;
			this.mouseAdapter = new CompoundNodeMouseAdapter;
			
			this._nodes = new Vector.<NodeComponent>;
			this._cachedBounds = new Rectangle;
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
		 * @return 
		 */
		override public function isCompound(): Boolean
		{
			return true;
		}
		
		/**
		 * 
		 */
		public function invalidateBounds(): void
		{
			this._cachedBounds.setEmpty();
			
			this._nodes.forEach(function (item: NodeComponent, i: int, v: Vector.<NodeComponent>): void {
				_cachedBounds = _cachedBounds.union(item.bounds);
			}, this);
			this.invalidateDisplayList();
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
		
		
	}
}