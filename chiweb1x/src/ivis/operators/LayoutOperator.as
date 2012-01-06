package ivis.operators
{
	import flare.vis.operator.layout.Layout;
	
	import ivis.manager.GraphManager;

	public class LayoutOperator extends Layout
	{
		private var _graphManager:GraphManager;
		
		//---------------------------- ACCESSORS -------------------------------
		
		/**
		 * Graph manager to perform graph related operations. 
		 */
		public function get graphManager():GraphManager
		{
			return _graphManager;
		}
		
		public function set graphManager(value:GraphManager):void
		{
			_graphManager = value;
		}
		
		//-------------------------- CONSTRUCTOR -------------------------------
		
		public function LayoutOperator(graphManager:GraphManager = null)
		{
			super();
			this.graphManager = graphManager;
		}
		
		//------------------------ PROTECTED FUNCTIONS -------------------------
		
		protected override function layout():void
		{
			// subclasses should override this function
		}
	}
}