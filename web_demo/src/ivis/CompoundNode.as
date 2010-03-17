/** 
* Authors: Ebrahim Rajabzadeh
*
* Copyright: i-Vis Research Group, Bilkent University, 2009 - present 
*/

package ivis
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import gs.*
	import gs.events.*
	
	public class CompoundNode extends Node
	{
		public static const DEFAULT_WIDTH: Number = 40
		public static const DEFAULT_HEIGHT: Number = 40

		private var _nodes: Array = new Array

		public function CompoundNode(id: String = null, x: Number = 0, y: Number = 0, cn: CompoundNode = null, data: Object = null)
		{
			super(id, x, y, cn, data)
			
			recalcBounds()
		}
		
		override public function get view(): Component
		{
			if(_view == null)
				_view = new CompoundNodeComponent(this)
				
			return _view
		}
		
		override public function bounds(includeGrapples: Boolean = false, exc: Node = null):*
		{
			if(_nodes.length == 0) {
				var nv: CompoundNodeComponent = this._view as CompoundNodeComponent
				return {
					top: Number(y + nv.margin), left: Number(x + nv.margin),
					right: Number(x + DEFAULT_WIDTH),
					bottom: Number(y + DEFAULT_HEIGHT),
					width: Number(DEFAULT_WIDTH),
					height: Number(DEFAULT_HEIGHT)
				}
			}
				
			var ns: Array = this._nodes
			if(exc)
			{
				var ix: int = ns.indexOf(exc)
				if(ix > -1)
				{
					var nn: Array = Utils.cloneArray(ns)
					nn.splice(ix, 1)
					return Utils.boundingRect(nn)
				}
			}
			var b:* = Utils.boundingRect(ns)
			
			return b
		}
		
		override public function isCompound(): Boolean { return true }
		
		public function addNode(n: Node): void
		{
			if(n.parent)
				n.parent.removeNode(n)
			
			if(!Graph.getInstance().surface.contains(n.view))
				Graph.getInstance().surface.addChild(n.view)
				
			this._nodes.push(n)
			n.parent = this
			
			this.bringUpChildren()
			
			this.revalidate()
			
			n.view.dispatchEvent(new Event("addedToCompound"))
		}

		override public function get margin(): uint
		{
			return (this.view as CompoundNodeComponent).margin
		}

		private function bringUpChildren(): void
		{
					
			var s: DisplayObjectContainer = Graph.getInstance().surface
			var p: CompoundNode = this
			
			var n: Node
			var pi: int = s.getChildIndex(p.view)
			var ci: int
			
			// bring up the edges
			var edges: Array = Graph.getInstance()._edges
			for each(var e: Edge in edges)
			{
				if(nodes.indexOf(e.source) >= 0 || nodes.indexOf(e.target) >= 0)
				{
					
					ci = s.getChildIndex(e.view)
					if(pi > ci) {
						s.setChildIndex(e.view, pi)
//						pi++
					}
				}
			}

			for each(n in _nodes)
			{
				ci = s.getChildIndex(n.view)
				if(pi > ci) {
					s.setChildIndex(n.view, pi)
//					pi++
				}
			}
			
			for each(n in _nodes)
				if(n.isCompound())
					(n as CompoundNode).bringUpChildren()


		}
		
		public function removeNode(n: Node): void
		{
			var i: int = _nodes.indexOf(n)
			
			if(i < 0)
				trace("not a child of this node") 
			
			this._nodes.splice(i, 1)[0]
			n.parent = null
			
			this.revalidate()

			n.view.dispatchEvent(new Event("addedToCompound"))
		}
		
		public function forEachChild(f: Function): void
		{
			for each(var n: Node in this._nodes)
				f.call(this, n)
		}
		
		public static function fromMXL(node: XML): CompoundNode
		{
			var cn: CompoundNode = new CompoundNode(node.@id, node.bounds.@x, node.bounds.@y);
			cn.width = node.bounds.@width;
			cn.height = node.bounds.@height;
			
			trace("id=" + cn.id)
			
			for each (var child: XML in node.childList.childNode)
			{
				var ch: Node = Graph.getInstance().nodeFromId(child.@nodeId)
				trace("adding child: " + ch.id)
				ch.x += cn.x
				ch.y += cn.y
				cn.addNode(ch)
			}
		
			return cn
		}
		
		override public function findNode(id: String): Node
		{
			if(this.id == id)
				return this
				
			for each(var n: Node in _nodes)
			{
				var m: Node = n.findNode(id)
				if(m != null)
					return m
			}
			
			return null
		}
		
		override public function asXML(): XML
		{
			var res: String = '<node id="' + id + '" ' +
				'clusterID="' + clusterID + '">' +
				'<bounds height="' + this.height +
				'" width="' + this.width + 
				'" />' + 
				'<children>'
			
			for each(var c: Node in _nodes)
				res += c.asXML()
			
			res += '</children></node>'
			
			return XML(res)
		} 
		
		override public function toGraphML(): XML
		{
			var res: String = "" 
			res +=  '<node id="' + this.id + '">';
			res += '<data key="x">' + this.x + '</data>';
			res += '<data key="y">' + this.y + '</data>';
			res += '<data key="height">' + this.view.height + '</data>';
			res += '<data key="width">' + this.view.width + '</data>';
			
			var cs: Array = Utils.intToRgb((this.view as CompoundNodeComponent).color2)
			res += '<data key="color">' + cs[2] + ' ' +  cs[1]+ ' ' + cs[0] + '</data>';
			//res += '<data key='borderColor'>14 112 130</data>';
			res += '<data key="text">' + (this.view as CompoundNodeComponent).longLabelText + '</data>';
			res += '<data key="textFont">1|"' + (this.view as NodeComponent).font +
				'|' + (this.view as NodeComponent).fontSize +
				'|0|WINDOWS|1|-11|0|0|0|0|0|0|0|1|0|0|0|0|Arial</data>';
			//res += '<data key='textColor'>0 0 0</data>';
			res += '<data key="clusterID">' + this.clusterID + '</data>';

			res += '<graph id="">'
			
			for each(var n: Node in _nodes)
				res += n.toGraphML()
			
			res += '</graph>'
			res += '</node>';
			
			return XML(res)
		}
		
		public function get nodes(): Array
		{
			return _nodes
		}
		
		public function recalcBounds(): void
		{
			if(_nodes.length > 0) {
				var b:* = this.bounds()
				this.x = b.leftmost.x - margin
				this.y = b.topmost.y - margin
				this.width = b.width + 2*margin 
				this.height = b.height + 2*margin + (view as CompoundNodeComponent).labelHeight
			}
			else
			{
				this.width = DEFAULT_WIDTH + 2*margin
				this.height = DEFAULT_HEIGHT + 2*margin
			}
		}
		
		override public function translate(dx: Number, dy: Number): void
		{
			this.x += dx
			this.y += dy
			
			for each(var n: Node in _nodes)
				n.translate(dx, dy)
		}
		
		override internal function revalidate(): void
		{
			this.recalcBounds()
			
			if(this.parent)
				parent.revalidate()
		}
		
		override public function animateTo(xmlNode: XML): TweenMax
		{
			var tm: TweenMax = TweenMax.to(this, Graph.getInstance().animationTime,
				{
					x: Number(xmlNode.bounds.@x),
					y: Number(xmlNode.bounds.@y),
					width: Number(xmlNode.bounds.@width),
					height: Number(xmlNode.bounds.@height),
					ease: Graph.ANIMATION_EASING,
					//paused: true,
					overwrite: 2
				})
				
//			for each(var n: Node in _nodes)
//				n.animateTo(xml)
				
			return tm
		}
		
		override public function compoundUnderPoint(x: Number, y: Number, exc: Node = null): CompoundNode
		{
			for each(var n: Node in _nodes)
			{
				if(n !== exc) {
					var c: CompoundNode =  n.compoundUnderPoint(x, y, exc)
					if(c)
						return c
				}
			}
			
			var b:* = this.bounds(false, exc)
			if(x <= b.right && x >= b.left && y <= b.bottom && y >= b.top)
				return this

			return null 
		}

		override public function toSvg(): String
		{
			var res: String
			var nv: CompoundNodeComponent = this.view as CompoundNodeComponent
			var h: Number = nv.y + nv.height
			var w: Number = nv.x + nv.labelX
			var lh: Number = nv.labelHeight
			
			res = '<defs>' +
					'<linearGradient id="node_' + this.id +'_gradient" x1="0%" y1="0%" ' + 
					'x2="100%" y2="100%" gradientUnits="objectBoundingBox" spreadMethod="pad">' + 
					'<stop offset="13%" style="stop-color: #' + nv.color1.toString(16)  + '; opacity: .3"/>' +
					'<stop offset="100%" style="stop-color: #' + nv.color2.toString(16) + '; opacity: .3"/>' +
					'</linearGradient>' +
				  '</defs>' +
				  '<rect x="' + this.x + '" y="' + this.y + '" width="' + this.width +
				  '" height="' + (this.height - lh) + '" rx="7" ry="7" style="fill: url(#node_' + this.id + '_gradient);"/>' +
				  '<rect x="' + this.x + '" y="' + (h - lh) + '" width="' + this.width +
				  '" height="' + lh + '" rx="5" ry="5" style="fill: #' + nv.labelColor.toString(16) + ';" />' +
				  '<text x="' + w + '" y="' + (h) + '" ' +
				  'font-family="' + nv.font + '" font-size="' + nv.fontSize + '">' +
				  nv.shortLabelText + '</text>'
				  
			return res
		}
	
	}
}