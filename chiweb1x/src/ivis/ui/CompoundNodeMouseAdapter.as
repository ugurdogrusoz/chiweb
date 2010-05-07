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
		private var _nodeComponent: NodeComponent;
		
		/**
		 * 
		 * @param n
		 */
		public function CompoundNodeMouseAdapter(n: CompoundNodeComponent)
		{
			this._nodeComponent = n;
		}

		/**
		 * 
		 * @param e
		 */
		public function onClick(e:MouseEvent):void
		{
		}
		
		/**
		 * 
		 * @param e
		 */
		public function onDoubleClick(e:MouseEvent):void
		{
		}
		
		/**
		 * 
		 * @param e
		 */
		public function onHover(e:MouseEvent):void
		{
		}
		
	}
}