package ivis.ui
{
	import flash.events.MouseEvent;

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

			this._nodeComponent.mouseChildren = false;
			
			this._nodeComponent.forEachNode(function (item: NodeComponent): void {
				item.mouseAdapter.onMouseDown(e);
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
				this._nodeComponent.forEachNode(function (item: NodeComponent): void {
					item.mouseAdapter.onMouseMove(e);
				});
			}				
			
			e.updateAfterEvent();
		}
		
		/**
		 * 
		 * @param e
		 */
		public function onMouseUp(e:MouseEvent):void
		{
			this._nodeComponent.mouseChildren = true;
			this._nodeComponent.stopDrag();
			this._down = false;
		}
		
	}
}