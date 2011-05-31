/** 
* Authors: Turgut Isik, Ebrahim Rajabzadeh
*
* Copyright: i-Vis Research Group, Bilkent University, 2009 - present 
*/
package ivis
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import mx.containers.*;
	import mx.controls.DataGrid;
	import mx.core.SpriteAsset;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	public class InspectorComponent extends Panel
	{		
		
		//private var closeButton: Button;
		private var canAddChild:Boolean = true;
		private var myTitleBar: UIComponent;
		protected var minShape: SpriteAsset;
		protected var closeShape: SpriteAsset;
		protected var _title: String;
		protected var _owner: Component = null;
		//private var controlBar: ControlBar;
	
		public function InspectorComponent(component: Component, title: String = "")
		{
			super();
			
			this.title = title;
			
			this._owner = component;
			
			this.setStyle("paddingTop", 10)
			this.setStyle("paddingBottom", 10)
			this.setStyle("paddingLeft", 5)
			this.setStyle("paddingRight", 5)
			
			addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
		}

		protected function onMouseDown(e: MouseEvent): void
		{
			var g: Graph = Graph.getInstance()
			this.startDrag(false,
				new Rectangle(g.x, g.y, g.width, g.height))
		}
		
		protected function onMouseUp(e: MouseEvent): void
		{
			this.stopDrag();
		}
		
		protected function setupChildren(): void {}
		
		protected function closeButtonClickEvent(e: Event): void {
			if(_owner)
				_owner.hideInspector()
			else
				parent.removeChild(this);
				
		}
		
		private function creationCompleteHandler(event:Event):void
		{
			addEventListener("doubleClick", function(e: Event):void {
				// no doubleclicking on inspector
				e.preventDefault();
				e.stopImmediatePropagation();
			});
			myTitleBar = titleBar;			
	
			setupChildren();
		}		

		override protected function createChildren():void
		{
			super.createChildren();

			closeShape = new SpriteAsset();
			closeShape.addEventListener(MouseEvent.CLICK, closeButtonClickEvent);
			this.titleTextField.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			this.titleTextField.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			titleBar.addChild(closeShape);
		}
			
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			closeShape.graphics.clear();
			closeShape.graphics.lineStyle(0, 0, 0);
			closeShape.graphics.beginFill(0xFFFFFF, 0);
			closeShape.graphics.drawRect(unscaledWidth - 22, 10, 12, 12);

			closeShape.graphics.lineStyle(2);
			closeShape.graphics.beginFill(0xFFFFFF, 0.0);		
			closeShape.graphics.moveTo(unscaledWidth - 20, 20);
			closeShape.graphics.lineTo(unscaledWidth - 12, 11);
			closeShape.graphics.moveTo(unscaledWidth - 20, 11);
			closeShape.graphics.lineTo(unscaledWidth - 12, 20);
			
		}
				
	}
}