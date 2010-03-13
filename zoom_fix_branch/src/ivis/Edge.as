/** 
* Authors: Ebrahim Rajabzadeh
*
* Copyright: i-Vis Research Group, Bilkent University, 2009 - present 
*/
package ivis
{
	import flash.geom.Point;
	
	public class Edge extends Object
	{
		
		private var _id: String;
		private var _source: Node;
		private var _target: Node;
		private var _bends: Array = new Array;
		private var _view: EdgeComponent = null;
		
		public function Edge(id: String = null, source: Node = null, target: Node = null)
		{
			this._id = id;
			this._source = source;
			this._target = target;
			this._view = new EdgeComponent(this);
		}

		public function get id(): String {
			return _id;
		}

		public function set id(value: String): void
		{
			this._id = value;
		}

		public function get source(): Node {
			return _source;
		}

		public function get target(): Node {
			return _target;
		}

		public function get bends(): Array {
			return _bends;
		}
		
		public function get view(): Component {
			return _view;
		}
		
		public function addBend(b: Object): void
		{
			if(b.isNew) {
				var i: int = b.index;
				_bends.splice(i, 0, b);
				while(++i < _bends.length) {
					++_bends[i].index;
				}
			}
		}

		public function removeBend(b: Object): void
		{
			var i: int = b.index;
			_bends.splice(i, 1);
			while(i < _bends.length) {
				--_bends[i].index;
				++i;
			}
		}

		public function nearestBendPoint(p: Point, d: Number = 5): Object {
			
			for each(var bp:* in bends) {
				if(Point.distance(bp.point, p) < d) {
					return bp;
				}
			}
			
			var i: int = nextIndex(p, d);
			if(i >= 0) {
				return { point: p, index: i, isNew: true };
			}
				
			return null;
		}		

		public function get length(): Number
		{
			var ap: Array = allPoints();
			var result: Number = 0;
			for(var i: int = 0; i < ap.length - 1; ++i)
				result += Point.distance(ap[i].point, ap[i+1].point);
				
			return result;
		}
		
		public function halfLengthPoint(i: int = -1): Point
		{
			var hl: Number = this.length / 2;
			var p: Point;
			var t: Number = 0;
			var ap: Array = allPoints(true);
			var p1: Point;
			var p2: Point;

			if(i >= 0) {
				p1 = ap[i].point;
				p2 = ap[i+1].point;
			}
			else
			{
				for(var i: int = 0; i < ap.length - 1 && t < hl; ++i)
					t += Point.distance(ap[i].point, ap[i+1].point);
				
				p1 = ap[i-1].point;
				p2 = ap[i].point;
			}
			return new Point((p1.x + p2.x)/2, (p1.y + p2.y)/2);
		}
		
		public function allPoints(useIntersections: Boolean = false): Array
		{
			var bs: Array = new Array().concat(_bends);
			var p1: Point = useIntersections ? _view.sourceIntersection : new Point;
			var p2: Point = useIntersections ? _view.targetIntersection : 
				new Point(_view.endX, _view.endY);
			bs.unshift({ point: p1, index: 0 });
			bs.push({ point: p2, index: bs.length });
			
			return bs;
		}
		
		public function nextIndex(p: Point, d: Number = 7): int
		{
			var bs: Array = allPoints(true);
			
			for(var index: uint = 0;
				index < bs.length - 1;
				++index) 
				{
					var p0: Point = bs[index].point;
					var p1: Point = bs[index+1].point;
					var t: Number = 
						Math.abs((p1.x-p0.x)*p.y-(p1.y-p0.y)*p.x+
						p0.x*(p1.y-p0.y)-p0.y*(p1.x-p0.x))/
						Math.sqrt((p1.x-p0.x)*(p1.x-p0.x)+(p1.y-p0.y)*(p1.y-p0.y));
//					trace("d=" + t + ", point=" + p + ", ps=" + p0 + ", " + p1);
					
					var xMin: Number = Math.min(p0.x, p1.x);
					var xMax: Number = Math.max(p0.x, p1.x);
					var yMin: Number = Math.min(p0.y, p1.y);
					var yMax: Number = Math.max(p0.y, p1.y);
					if(t < d && p.x <= xMax + d && p.y <= yMax + d &&
						p.x >= xMin - d && p.y >= yMin - d)
						return index;						
				}
				
			return -1;
		}		

		public static function projection(p0: Point, p1: Point, p: Point): Point
		{
			var l: Number = Point.distance(p1, p0);
			var u: Point = new Point((p1.x - p0.x) / l, (p1.y - p0.y) / l);
			var dot: Number = Math.max(u.x * (p.x - p0.x) + u.y * (p.y - p0.y), 0);
			dot = Math.min(l, dot);
			return new Point(p0.x + dot * u.x, p0.y + dot * u.y);
		}
		
		public function removeAlignedBendPoints(bp:*): Boolean
		{
			var bs: Array = allPoints();
			var i: int = bs.indexOf(bp);
			var proj: Point;
			if(i > 1) {
				proj = projection(bs[i-2].point, bp.point, bs[i-1].point);
				if(Point.distance(proj, bs[i-1].point) < 10) {
					removeBend(bs[i-1]);
					bs.splice(i, 1);
					return true;//res = true;
				}
			}
			proj = projection(bs[i-1].point, bs[i+1].point, bp.point);
			if(Point.distance(proj, bp.point) < 10) {
				removeBend(bp);
				bs.splice(i, 1);
				return true;//res = true;
			}
			if(i < bs.length - 2) {
				proj = projection(bp.point, bs[i+2].point, bs[i+1].point);
				if(Point.distance(proj, bs[i+1].point) < 10) {
					removeBend(bs[i+1]);
					return true;
				}
			}
			return false;
		}
		
		public function newBendPoint(p: Point): Object
		{
			var nb: Object = nearestBendPoint(p);
			return nb;
		}
		
		public function asXML(): XML
		{
			return XML('<edge id="' + id + '">' + 
					'<sourceNode id="' + source.id + '"/>' + 
					'<targetNode id="' + target.id + '"/></edge>')
		} 
		
		public function toSvg(): String
		{
			var res: String = ""
			var ps: Array = this.allPoints(true)
			var ev: EdgeComponent = this.view as EdgeComponent
			
			for (var i: int = 0; i < ps.length - 1; ++i)
			{
				var x1: Number = ev.x + ps[i].point.x
				var y1: Number = ev.y + ps[i].point.y
				var x2: Number = ev.x + ps[i+1].point.x
				var y2: Number = ev.y + ps[i+1].point.y
				res += '<line x1="' + x1 + '" y1="' + y1 + '"' +
					' x2="' + x2 + '" y2="' + y2 + '" style="stroke-width:' +
					ev.weight + '; stroke: #' + Utils.colorToString(ev.color) + ';'
					 
				if(ev.lineStyle == EdgeComponent.DASHED)
					res += 'stroke-dasharray: 3 3;'
					
				res += '"/>' 
			}
			
			return res
		}
		
		public function toGraphML(): XML
		{
			var res: String = ""
			
			return XML(res)
		}

		public function get bendPoints(): Array
		{
			var res: Array = new Array(_bends.length)
			
			for(var i: int = 0; i < _bends.length; ++i)
				res[i] = { x: Number(this.view.x + bends[i].point.x),
					y: Number(this.view.y + bends[i].point.y),
					width: 0, height: 0 }
				
			return res
		}
		
		public function equals(o: Object): Boolean
		{
			if(o is Edge) {
				var e: Edge = o as Edge
				
				// compare IDs ??
				return this.source.equals(o.source) && this.target.equals(o.target)
			}
			
			return false
		}
	}
}