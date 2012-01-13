package gui
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.events.FlexEvent;
	
	import spark.components.Label;
	import spark.components.Panel;
	import spark.components.TextInput;

	public class StylePanel extends Panel
	{
		public function StylePanel(title:String)
		{
			this.title = title;
			this.addEventListener(FlexEvent.CREATION_COMPLETE,
				onCreation);
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		protected function onCreation(event:Event):void
		{
			this.updateContent();
		}
		
		protected function onMouseDown(e:MouseEvent):void
		{
			// TODO bounds?
			this.startDrag(false);
		}
		
		protected function onMouseUp(e:MouseEvent):void
		{
			this.stopDrag();
		}
		
		protected function updateContent(): void
		{
			var vb:VBox = new VBox();
			
			var keyText:String = "style";
			
			var keyLabel:Label = new Label();			
			keyLabel.width = 70;
			keyLabel.text = keyText;
			keyLabel.setStyle("fontWeight", "bold");

			var hb:HBox = new HBox();
			hb.addChild(keyLabel);
			
			var input:TextInput = new TextInput();
			input.width = 100;
			input.text = "value";
			
			hb.addChild(input);
			
			vb.addChild(hb);
			
			this.addElement(vb);
		}
	}
}