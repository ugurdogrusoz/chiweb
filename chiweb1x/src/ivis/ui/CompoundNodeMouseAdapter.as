package ivis.ui
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.events.MoveEvent;

	/**
	 * 
	 * @author Ebrahim
	 */
	public class CompoundNodeMouseAdapter implements IMouseAdapter
	{
		/**
		 * 
		 * @default 
		 */
		private var _nodeComponent: CompoundNodeComponent;
		
		/**
		 * 
		 * @default 
		 */
		private var _stageStartX: Number;

		/**
		 * 
		 * @default 
		 */
		private var _stageStartY: Number;
		
		private var _starts: Object;

		/**
		 * 
		 * @default 
		 */
		private var _down: Boolean = false;
		
		/**
		 * 
		 * @param nodeComponent
		 */
		public function CompoundNodeMouseAdapter()
		{
		}

		//
		// getters & setters
		//
		
		public function get component(): Component
		{
			return this._nodeComponent;
		}
		
		public function set component(n: Component): void
		{
			this._nodeComponent = n as CompoundNodeComponent;
		}
		
		//
		// public methods
		//
		
		/**
		 * 
		 * @param e
		 */
		public function onMouseDown(e:MouseEvent):void
		{
			this._stageStartX = e.stageX;
			this._stageStartY = e.stageY;
		
			this._starts = new Object;
			
			this._nodeComponent.forEachNode(
				function (n: NodeComponent): void {
					_starts[n] = new Point(n.x, n.y);
				});
				
			this._down = true;
			
			e.updateAfterEvent();
		}
		
		/**
		 * 
		 * @param e
		 */
		public function onMouseMove(e:MouseEvent):void
		{
			if(this._down)
			{
				var dx: Number = e.stageX - this._stageStartX; 
				var dy: Number = e.stageY - this._stageStartY;
				
			this._nodeComponent.forEachNode(
				function (n: NodeComponent): void {
					var p: Point = _starts[n];
					n.x = p.x + dx;
					n.y = p.y + dy;
				});
			}
			
			this._nodeComponent.dispatchEvent(new MoveEvent(MoveEvent.MOVE));
			e.updateAfterEvent();
		}
		
		/**
		 * 
		 * @param e
		 */
		public function onMouseUp(e:MouseEvent):void
		{
			this._down = false;
		}
		
	}
}