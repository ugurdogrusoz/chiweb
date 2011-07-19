/** 
* Authors: Turgut Isik, Ebrahim Rajabzadeh
*
* Copyright: i-Vis Research Group, Bilkent University, 2009 - present 
*/

package ivis
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	import gs.TweenMax;
	
	public class Node extends EventDispatcher
	{
		private static const ID_PATTERN: RegExp = /\d+/

		private static var _idCount:uint = 0
		private static var _clusterCount:uint = 0
		
		private var _id: String = null;
		public var _x: Number = 0;
		public var _y: Number = 0;
		private var _w: Number;
		private var _h: Number;

		
		private var _data: Object = null
		protected var _view: Component = null;
		protected static const DEFAULT_WIDTH: uint = 40;
		protected static const DEFAULT_HEIGHT: uint = 40;		
		protected var _clusterID: uint
		
		public var _parent: CompoundNode = null;

		public function Node(id: String = null, x: Number = 0, y: Number = 0, cn: CompoundNode = null, data: Object = null)
		{
			if(id == null) {
				this._id = _idCount++.toString();
			} else {
				this._id = id;
				
				if(ID_PATTERN.test(id)) {
					_idCount = Math.max(int(id) + 1, _idCount)
				}
			}
			this.x = x;
			this.y = y;
			this.width = DEFAULT_WIDTH
			this.height = DEFAULT_HEIGHT
			this._data = data;
			this.parent = cn
			this.clusterID = 0
		}

		public function get x(): Number {
			return view.x;
		}
		
		public function set x(value: Number): void {
			this.view.x = value
		}
		
		public function get y(): Number {
			return view.y;
		}
		
				
		public function set y(value: Number): void {
			this.view.y = value
		}

		public function get width(): Number
		{
			return view.width//_w
		}
		
		public function set width(value: Number): void
		{
//			if(value > NodeComponent.MIN_WIDTH) {
				_w = value
				view.width = value
				view.explicitWidth = value
//			}
		}
		
		public function get height(): Number
		{
			return view.height//_h
		}
		
		public function set height(value: Number): void
		{
//			if(value > NodeComponent.MIN_HEIGHT) {
				_h = value
				view.height = value
				view.explicitHeight = value
//			}

		}

		public function get relativeX(): Number
		{
			return parent ? this.x - parent.x : this.x
		}

		public function set relativeX(value: Number): void
		{
			if(parent)
				this.x = parent.x + value
			else
				this.x = value
		}

		public function get relativeY(): Number
		{
			return parent ? this.y - parent.y : this.y
		}
		
		public function set relativeY(value: Number): void
		{
			if(parent)
				this.y = parent.y + value
			else
				this.y = value
		}

		public function get margin(): uint
		{
			return 0
		}
		
		public function get parent(): CompoundNode
		{
			return _parent
		}	

		public function set parent(value: CompoundNode): void
		{
			_parent = value
		}	
		
		public function get id(): String {
			return _id;
		}

		public function get clusterID(): uint
		{
			return this._clusterID
		}
		
		public function set clusterID(value: uint): void
		{
			this._clusterID = value
			
			this.dispatchEvent(new Event("clusterChanged"))
		}
		
		public function bounds(includeGrapples: Boolean = false, exc: Node = null): *
		{
			return Utils.boundingRect([ Node(this) ])
		}	
			
		public function get view(): Component {
			if(_view == null)
				_view = new NodeComponent(this);

			return _view
		}
		
		public function isCompound(): Boolean { return false }
		
		public static function fromXML(node: XML): Node
		{
			var n: Node = new Node(node.@id, node.bounds.@x, node.bounds.@y)
			trace("added simple node: " + n.id)
			n.view.width = node.bounds.@width
			n.view.height = node.bounds.@height
			
			return n
		}
		
		public function findNode(id: String): Node
		{
			return (this.id == id) ? this : null
		}
		
		public function translate(dx: Number, dy: Number): void
		{
			x += dx
			y += dy
		}
		
		public function asXML(): XML
		{
			return XML('<node id="' + id + '" ' + 
					'clusterId="' + clusterID + '">' + 
					'<bounds height="' + this.height + 
					'" width="' + this.width + 
					'" x="' + this.x + 
					'" y="' + this.y + 
					'" />' + 
					'</node>')
		} 
		
		public function toGraphML(): XML
		{
			var res: String = "" 
			res +=  '<node id="' + this.id + '">';
			res += '<data key="x">' + this.x + '</data>';
			res += '<data key="y">' + this.y + '</data>';
			res += '<data key="height">' + this.height + '</data>';
			res += '<data key="width">' + this.width + '</data>';
			
			var cs: Array = Utils.intToRgb((this.view as NodeComponent).color2)
			res += '<data key="color">' + cs[2] + ' ' +  cs[1]+ ' ' + cs[0] + '</data>';
			cs = Utils.intToRgb((this.view as NodeComponent).color1)
			res += '<data key="color1">' + cs[2] + ' ' +  cs[1]+ ' ' + cs[0] + '</data>';
			//res += '<data key='borderColor'>14 112 130</data>';
			res += '<data key="text">' + (this.view as NodeComponent).longLabelText + '</data>';
			res += '<data key="textFont">1|' + (this.view as NodeComponent).font +
				'|' + (this.view as NodeComponent).fontSize +
				'|0|WINDOWS|1|-11|0|0|0|0|0|0|0|1|0|0|0|0|Arial</data>';
			//res += '<data key='textColor'>0 0 0</data>';
			res += '<data key="clusterID">' + this.clusterID + '</data>';
			res += '<data key="shape">' + (this.view as NodeComponent).shape + '</data>';
			res += '</node>';
			
			return XML(res)
		}

		public function toSvg(): String
		{
			var res: String
			var nv: NodeComponent = this.view as NodeComponent
			res = '<defs>' +
					'<linearGradient id="node_' + _id +'_gradient" x1="0%" y1="0%" ' + 
					'x2="100%" y2="100%" gradientUnits="objectBoundingBox" spreadMethod="pad">' + 
					'<stop offset="0%" style="stop-color: #' + nv.color1.toString(16)  + '; opacity: .7"/>' +
					'<stop offset="100%" style="stop-color: #' + nv.color2.toString(16) + '; opacity: .7"/>' +
					'</linearGradient>' +
				  '</defs>' +
				  '<rect x="' + this.x + '" y="' + this.y + '" width="' + this.width +
				  '" height="' + this.height + '" rx="7" ry="7" style="fill: url(#node_' + _id + '_gradient);"/>' +
				  '<text x="' + (nv.x + nv.labelX) + '" y="' + (nv.y + nv.labelY + nv.labelHeight/2) + '" ' +
				  'font-family="' + nv.font + '" font-size="' + nv.fontSize + '">' +
				  nv.shortLabelText + '</text>'
					
			return res
		}
		
		public function get parentView(): DisplayObject
		{
			return parent ? parent.view : Graph.getInstance().surface
		}
		
		override public function toString():String
		{
			return "[" + id + "] x=" + x + ", y=" + y + ", w=" + width + ", h=" + height
		}
		
		protected var targetPosition: Point = new Point
		
		public function animateTo(xmlNode: XML): TweenMax
		{
			var tm: TweenMax = TweenMax.to(this, Graph.getInstance().animationTime, 
				{ 
					x: Number(xmlNode.bounds.@x),
				  	y: Number(xmlNode.bounds.@y),
				  	ease: Graph.ANIMATION_EASING,
				  	//paused: true,
				  	overwrite: 2
				})
				
			return tm
		}
		
		public function compoundUnderPoint(x: Number, y: Number, exc: Node = null): CompoundNode
		{
			return null
		}
		
		internal function revalidate(): void {}
		
		internal static function nextClusterID(): uint
		{
			return ++_clusterCount
		}
		
		internal static function resetClusterCounter(): void
		{
			_clusterCount = 0
		}

		internal static function resetIDCounter(): void
		{
			_idCount = 0
		}

		public function equals(o: Object): Boolean
		{
			if(o is Node) {
				return this.id == o.id
			}
			
			return false
		}
	}
}