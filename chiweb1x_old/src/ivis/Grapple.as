/** 
* Authors: Ebrahim Rajabzadeh
*
* Copyright: i-Vis Research Group, Bilkent University, 2009 - present 
*/

package ivis
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import mx.core.UIComponent;
	
	public class Grapple extends Component
	{
		
		private var _buddy: NodeComponent;
		public static const FILL_COLOR: uint = 0xA77145//0xBE6A7E;
		
		public static const TOP_LEFT: String = "topLeft";
		public static const TOP_RIGHT: String = "topRight";
		public static const BOTTOM_LEFT: String = "bottomLeft";
		public static const BOTTOM_RIGHT: String = "bottomRight";

		public static const GRAPPLE_OFFSET: int = 2; 
		public static const DEFAULT_GRAPPLE_SIZE: int = 3; 

		private var _type: String;
		
		public function Grapple(node: NodeComponent, type: String, x: int = 0, y: int = 0)
		{
			super();
		
			this._type = type;
			this._buddy = node;	
			this.x = x;
			this.y = y;
			this.width = DEFAULT_GRAPPLE_SIZE;
			this.height= DEFAULT_GRAPPLE_SIZE;
//			this.cacheAsBitmap = true;
		}
		
		override public function set selected(value:Boolean):void
		{
			this._buddy.selected = value
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			graphics.clear();
			
			graphics.beginFill(FILL_COLOR);
			graphics.drawCircle(0, 0, this.width);
			graphics.endFill();
		}
	
		private var _locals: Object
		private var _nodes: Array
		
		public override function onMouseDown(e: MouseEvent):void
		{
			super.onMouseDown(e);
			
			var g: Graph = Graph.getInstance()

			g.addEventListener("mouseMove", this.onMouseMove);
			g.addEventListener("mouseUp", this.onMouseUp);
			
			var nds: Array = g.selectedNodes()
			_nodes = new Array
			
			_locals = new Dictionary	
			for each(var n: Node in nds) {
				if(!n.isCompound()) {
					_locals[n] = { 
						x: n.x, y: n.y,
						width: n.width, height: n.height
					}
					_nodes.push(n)
				}
			}
			e.stopImmediatePropagation();
		}
		
		public override function onMouseMove(e: MouseEvent):void
		{
			
			var pa: Graph = Graph.getInstance()
			var dx: Number = pa.unscaledDx(e.stageX - _stageStart.x);
			var dy: Number = pa.unscaledDy(e.stageY - _stageStart.y);
			
			var c: Node
			var d: Object
			
			switch(_type) {
				case TOP_LEFT:
					for each(c in _nodes) {
						d = this._locals[c]
						if(d.width - dx > NodeComponent.MIN_WIDTH) {
							c.width = d.width - dx;
							c.x = d.x + dx;
						}
						if(d.height - dy >= NodeComponent.MIN_HEIGHT) {
							c.height = d.height - dy;
							c.y = d.y + dy;
						}
					}
					break;
				case TOP_RIGHT:
					for each(c in _nodes) {
						d = this._locals[c]
						if(d.width + dx >= NodeComponent.MIN_WIDTH)
							c.width = d.width + dx;
						if(d.height - dy >= NodeComponent.MIN_HEIGHT) {
							c.height = d.height - dy;
							c.y = d.y + dy;
						}
					}
					break;
				case BOTTOM_LEFT:
					for each(c in _nodes) {
						d = this._locals[c]
						if(d.height + dy >= NodeComponent.MIN_HEIGHT)
							c.height = d.height + dy;
						if(d.width - dx >= NodeComponent.MIN_WIDTH) {
							c.width = d.width - dx;
							c.x = d.x + dx;
						}
					}
					break;
				case BOTTOM_RIGHT:
					for each(c in _nodes) {
						d = this._locals[c]
						if(d.width + dx >= NodeComponent.MIN_WIDTH)
							c.width = d.width + dx;
						if(d.height + dy >= NodeComponent.MIN_HEIGHT)
							c.height = d.height + dy;
					}
					break;
			}

			for each(c in _nodes)			
				c.dispatchEvent(new Event("nodeResized"));
		}
		
		public override function onMouseUp(e: MouseEvent): void
		{
			var g: Graph = Graph.getInstance()
			g.removeEventListener("mouseMove", this.onMouseMove);
			g.removeEventListener("mouseUp", this.onMouseUp);
			
			_locals = null
			_nodes = null
		}
	}
}
