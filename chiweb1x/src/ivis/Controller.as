package ivis
{
	import flare.display.TextSprite;
	import flare.vis.controls.Control;
	import flare.vis.data.DataSprite;
	import flare.vis.data.NodeSprite;
	
	import ivis.controls.ActionState;
	import ivis.controls.ClickControl;
	import ivis.controls.KeyControl;
	import ivis.controls.MultiDragControl;
	import ivis.controls.SelectControl;
	import ivis.util.Groups;
	import ivis.view.CompoundNodeLabeler;
	import ivis.view.GraphView;
	import ivis.view.NodeLabeler;

	// TODO currently, this class is used as the main class that inits the
	// application. But, we may provide another mechanism to init the app.
	public class Controller
	{
		protected var _view:GraphView;
		protected var _state:ActionState;
		
		public function get view():GraphView
		{
			return _view;
		}
		
		public function Controller()
		{
			// instantiate state control
			_state = new ActionState();
			
			// instantiate view
			_view = new GraphView();
			
			// initialize default controls for the visualization
			
			var keyControl:KeyControl = new KeyControl(_view);
			var clickControl:ClickControl = new ClickControl(_view);
			var dragControl:MultiDragControl =
				new MultiDragControl(_view, NodeSprite); 
			var selectControl:SelectControl = new SelectControl(_view, DataSprite);
			
			clickControl.state = _state;
			keyControl.state = _state;
			selectControl.state = _state;
			//dragControl.state = _state;
			
			this.addControl(selectControl);
			this.addControl(clickControl);
			this.addControl(dragControl);
			this.addControl(keyControl);
			
			// TODO labeler for debug purposes
			_view.vis.nodeLabeler = new NodeLabeler("props.labelText");
			_view.vis.compoundLabeler = new CompoundNodeLabeler("props.labelText");
			
		}
		
		public function addControl(control:Control):void
		{
			_view.vis.controls.add(control);
		}
		
		public function removeControl(control:Control):void
		{
			_view.vis.controls.remove(control);
		}
		
		public function toggle(state:String):Boolean
		{
			var result:Boolean = false;
			
			if (state == ActionState.ADD_NODE)
			{
				result = _state.toggleAddNode();
			}
			else if (state == ActionState.ADD_EDGE)
			{
				result = _state.toggleAddEdge();
			}
			else if (state == ActionState.ADD_BENDPOINT)
			{
				result = _state.toggleAddBendPoint();
			}
			else if (state == ActionState.SELECT)
			{
				result = _state.toggleSelect();
			}
			
			
			return result;
		}
		
		//------------------------------ DEBUG ---------------------------------
		
		public function printGraph():void
		{
			this.view.graph.printGraph();
		}
		
	}
}