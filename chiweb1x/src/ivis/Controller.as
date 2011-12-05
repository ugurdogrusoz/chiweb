package ivis
{
	import flare.display.TextSprite;
	import flare.vis.controls.Control;
	import flare.vis.data.DataSprite;
	import flare.vis.data.NodeSprite;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import ivis.controls.ActionState;
	import ivis.controls.ControlCenter;
	import ivis.util.Groups;
	import ivis.util.NodeUIs;
	import ivis.view.CompoundNodeLabeler;
	import ivis.view.EdgeLabeler;
	import ivis.view.GradientRectUI;
	import ivis.view.GraphView;
	import ivis.view.NodeLabeler;

	// TODO currently, this class is used as the main class that inits the
	// application. But, we should provide another mechanism to init the app.
	public class Controller
	{
		protected var _view:GraphView;
		protected var _controlCenter:ControlCenter;
		
		public function get view():GraphView
		{
			return _view;
		}
		
		public function Controller()
		{	
			// instantiate view
			_view = new GraphView();
			
			// initialize default controls for the visualization
			_controlCenter = new ControlCenter(_view);
			
			// labeler for debug purposes
			_view.vis.nodeLabeler = new NodeLabeler("props.labelText");
			_view.vis.compoundLabeler = new CompoundNodeLabeler("props.labelText");
			_view.vis.edgeLabeler = new EdgeLabeler("props.labelText");
			
			// custom shapes for debugging purposes
			//NodeUIs.registerUI("gradientRect",
			//	GradientRectUI.instance);
			
			// custom listeners for debugging purposes
			
			//_controlCenter.disableDefaultControl(ControlCenter.DRAG_CONTROL);
			//_controlCenter.disableDefaultControl(ControlCenter.CLICK_CONTROL);
			
			//_view.vis.doubleClickEnabled = true;
			
			_controlCenter.addCustomListener("inspector",
				MouseEvent.MOUSE_OVER,
				showInspector,
				NodeSprite);
		}
		
		public function toggle(state:String):Boolean
		{
			var result:Boolean = false;
			
			if (state == ActionState.ADD_NODE)
			{
				result = _controlCenter.state.toggleAddNode();
			}
			else if (state == ActionState.ADD_EDGE)
			{
				result = _controlCenter.state.toggleAddEdge();
			}
			else if (state == ActionState.ADD_BENDPOINT)
			{
				result = _controlCenter.state.toggleAddBendPoint();
			}
			else if (state == ActionState.SELECT)
			{
				result = _controlCenter.state.toggleSelect();
			}
			
			return result;
		}
		
		//------------------------------ DEBUG ---------------------------------
		
		public function printGraph():void
		{
			this.view.graph.printGraph();
		}
		
		public function showInspector(event:MouseEvent):void
		{
			//var evt:MouseEvent = evt as MouseEvent;
			
			trace ("custom listener: " + event.localX + ", " + event.localY);
		}
		
	}
}