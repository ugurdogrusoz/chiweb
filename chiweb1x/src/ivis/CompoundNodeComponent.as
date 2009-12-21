/**
* Author: Ebrahim Rajabzadeh, Turgut Isik
*
* Copyright: i-Vis Research Group, Bilkent University, 2009 - present 
*/


package ivis
{
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.SpreadMethod;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import mx.effects.*;
	
	public class CompoundNodeComponent extends NodeComponent
	{
		protected var _margin: uint = 10
		protected var _bodyColor:uint = 0x004358//0x40627C//0x98946C;
		protected var _labelColor:uint = 0xBEDB39
		protected var _labelHeight:int = 10;
	
		public function CompoundNodeComponent(node: CompoundNode)
		{
			super(node)
		}			
		
		public function set labelHeight(h: Number): void
		{
			_labelHeight = h;
		}
		
		public function get bodyColor(): uint
		{
			return _bodyColor;
		}
		
		public function set bodyColor( c: uint): void
		{
			_bodyColor = c;
			this.invalidateDisplayList();
		}
		
		public function get labelColor(): uint
		{
			return _labelColor;
		}
		
		public function set labelColor( c: uint): void
		{
			_labelColor = c;
			this.invalidateDisplayList();
		}
		
		override public function set fontSize(value: int): void
		{
			_fontSize = value;
			refreshLabel();
		}
		
		override protected function setupChildren(): void
		{
			super.setupChildren();
			
			this._inspector = new CompoundInspector(this)
		}

		override public function showInspector(p: Point = null): void
		{
			super.showInspector(p)
		}
		
		public function get margin(): uint
		{
			return _margin	
		}
		
		public function set margin(m: uint): void
		{
			this._margin = m;
			(this.model as CompoundNode).recalcBounds()
			this.invalidateDisplayList()
		}
		
		override protected function refreshLabel(): void
		{
			this._label.htmlText = "<font face='" + _font + "' size='" + 
				_fontSize + "'>" + _originalLabel + "</font>";

			var i: int = _originalLabel.length - 1;
			while(this._label.textWidth + 2*margin > this.width && i >= 0) {
				this._label.htmlText = "<font face='" + _font + "' size='" + 
					_fontSize + "'>" + _originalLabel.substr(0, --i) + "...</font>";
			}
			_labelHeight = _label.textHeight - _label.getLineMetrics(0).leading + _label.getLineMetrics(0).descent;
			this.invalidateDisplayList();
		}
		
		override public function properties(): Array
		{
			return [
				{ key: "Label", value: longLabelText },
				{ key: "X", value: this.model.x },
				{ key: "Y", value: this.model.y },
				{ key: "Body Color", value: _bodyColor},
				{ key: "Label Color", value: _labelColor},
				{ key: "Margin", value: _margin},
				{ key: "Font", value: _font},
				{ key: "Font Size", value: _fontSize},
			];
		}
		
		override public function set highlight(value:Boolean):void {
			super.highlight = value
			removeGrapples();
		}
		
//		override public function onMouseDown(e: MouseEvent): void
//		{
//			super.onMouseDown(e)
//		}
		 
		override public function onMouseMove(e: MouseEvent): void
		{
			var pa: Graph = Graph.getInstance()

			var ox: Number = this.x
			var oy: Number = this.y
			
			// !!copied from super!!		
			var dx: Number = e.stageX - _stageStart.x;
			var dy: Number = e.stageY - _stageStart.y;

			this.model.x = _localStart.x + pa.unscaledDx(dx)
			this.model.y = _localStart.y + pa.unscaledDx(dy)
			
			var cn: CompoundNode = this.model as CompoundNode
			dx = this.x - ox 
			dy = this.y - oy 

			for each(var n: Node in cn.nodes) {
				if(!n.view.selected)
					n.translate(dx, dy)
			}
			
			_transfer &&= e.ctrlKey

			if(pa._clickedAndMoved && !_transfer)
				this.model.revalidate()
				

			if(!_transfer)
			{
				if(this.model.parent)
					this.model.parent.revalidate()
			}
			else if(this.selected)
				pa.removeFromSelection(this)
				
			pa.dispatchEvent(new Event("boundsChanged"))
			
			_moved = true
		}
		
		private function hasSelectedNodes(): Boolean
		{
		 	if(this.selected)
		 		return true
		 		
			for each(var n: Node in this.model.nodes)
		 	{
		 		if(n.isCompound()) 
					if(n.view.selected || (n.view as CompoundNodeComponent).hasSelectedNodes())
		 				return true
		 		else if(n.view.selected)
		 			return true
		 	}
		 	
		 	return false
		}
		
		override public function get color1():uint
		{
			return Utils.brighter(_bodyColor, 180)
		}

		override public function get color2():uint
		{
			return _bodyColor
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number): void
		{
			graphics.clear()
			
			//var d:* = this._node.bounds()
			var l: Number = 0
			var r: Number = model.width
			var t: Number = 0
			var b: Number = model.height - labelHeight
			var w: Number = model.width
			var h: Number = model.height - labelHeight
			
			// gradient fill 			
			var m: Matrix = new Matrix

			m.createGradientBox(w, h, 45)
            graphics.beginGradientFill(GradientType.LINEAR, [color1, color2],
            	[.27, .27], [32, 255], m, SpreadMethod.REFLECT, InterpolationMethod.RGB, 1)
 
 			// normal fill
// 			graphics.beginFill(fillColor, .2)
            graphics.drawRoundRect(l, t, w, h, 10, 10)
 			graphics.endFill();

            graphics.beginFill(labelColor, 0.35);
            graphics.drawRoundRect(l, b, w, labelHeight, 10, 10)
			graphics.endFill();	
			
			_label.y = b //- labelHeight
			_label.x = margin
		}
		
	}
}