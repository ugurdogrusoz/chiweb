package ivis.ui
{
	import flash.events.MouseEvent;

	/**
	 * 
	 * @author Ebrahim
	 */
	public class NodeMouseAdapter implements IMouseAdapter
	{
		/**
		 * 
		 * @default 
		 */
		private var _nodeComponent: NodeComponent;
		
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
		
		/**
		 * 
		 * @default 
		 */
		private var _nodeStartX: Number;
		
		/**
		 * 
		 * @default 
		 */
		private var _nodeStartY: Number;
		
		/**
		 * 
		 * @default 
		 */
		private var _drag: Boolean = false;
		
		/**
		 * 
		 * @param nodeComponent
		 */
		public function NodeMouseAdapter()
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
			this._nodeComponent = n as NodeComponent;
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
		
			this._nodeStartX = this._nodeComponent.x;
			this._nodeStartY = this._nodeComponent.y;
				
			this._drag = true;
			
			e.updateAfterEvent();
		}
		
		/**
		 * 
		 * @param e
		 */
		public function onMouseMove(e:MouseEvent):void
		{
			if(this._drag)
			{
				var dx: Number = e.stageX - this._stageStartX; 
				var dy: Number = e.stageY - this._stageStartY;
				
				this._nodeComponent.move(this._nodeStartX + dx, this._nodeStartY + dy);
			}
			
			e.updateAfterEvent();
		}
		
		/**
		 * 
		 * @param e
		 */
		public function onMouseUp(e:MouseEvent):void
		{
			this._drag = false;
		}
		
	}
}