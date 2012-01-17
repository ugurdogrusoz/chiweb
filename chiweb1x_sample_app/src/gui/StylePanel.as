package gui
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import ivis.model.Style;
	
	import mx.containers.ControlBar;
	import mx.containers.HBox;
	import mx.containers.Panel;
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.controls.Spacer;
	import mx.controls.TextInput;
	import mx.core.SpriteAsset;
	import mx.events.FlexEvent;
	
//	import spark.components.Label;
//	import spark.components.Panel;
//	import spark.components.TextInput;
//	import spark.layouts.HorizontalLayout;
	

	/**
	 * Base class for style editor panels. Provides an unformatted editor for
	 * name and value pairs of a visual style. This class should be extended 
	 * to provide a style specific editor with formatted content.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class StylePanel extends Panel
	{
		protected var _visualStyle:Style;
	
		protected var _inputMap:Object;
		
		/**
		 * Visual style associated with this style editor panel.
		 */
		public function set visualStyle(value:Style):void
		{
			_visualStyle = value;
			
			// TODO just clear main content and call updateMainContent
			this.initContent();
		}
		
		/**
		 * Instantiates a new panel for the given title & visual style.
		 */
		public function StylePanel(title:String = "",
			visualStyle:Style = null)
		{
			this.title = title;
			this._visualStyle = visualStyle;
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE,
				onCreation);
		}
		
		/**
		 * Listener for CREATION_COMPLETE event. Initializes the panel.
		 */
		protected function onCreation(event:Event):void
		{
			// enable dragging
			this.titleTextField.addEventListener(MouseEvent.MOUSE_DOWN,
				onMouseDown);
			
			this.titleTextField.addEventListener(MouseEvent.MOUSE_UP,
				onMouseUp);
			
			// update contents
			this.initContent();
		}
		
		/**
		 * Listener for MOUSE_DOWN event to start dragging.
		 */
		protected function onMouseDown(e:MouseEvent):void
		{
			this.startDrag(false);
		}
		
		/**
		 * Listener for MOUSE_UP event to stop dragging.
		 */
		protected function onMouseUp(e:MouseEvent):void
		{
			this.stopDrag();
		}
		
		/**
		 * Updates all content of the editor panel.
		 */
		protected function initContent(): void
		{
			this.removeAllElements();
			
			// update title content
			this.updateTitleContent();
			
			// update main content
			this.updateMainContent();
			
			// update control bar content
			this.updateControlBarContent();
			
		}
		
		/**
		 * Updates the main content of the style editor panel. Fills the main
		 * content with all properties and their values without formatting.
		 * For an advanced style configuration child classes should override
		 * this function. 
		 */
		protected function updateMainContent():void
		{
			if (this._visualStyle == null)
			{
				return;
			}
			
			var vb:VBox = new VBox();
			this._inputMap = new Object();
			
			// generic unformatted content with all fields and values
			for each (var name:String in this._visualStyle.getPropNames())
			{
				var propLabel:Label = new Label();
				propLabel.width = 120;
				propLabel.text = name;
				//propLabel.setStyle("fontWeight", "bold");
				
				var input:TextInput = new TextInput();
				input.width = 100;
				input.text = String(this._visualStyle.getProperty(name));
				
				var hb:HBox = new HBox();
				hb.addChild(propLabel);
				hb.addChild(input);
				vb.addChild(hb);
				
				// cache input field for future access
				this._inputMap[name] = input;
				
				this.addElement(vb);
			}
		}
		
		/**
		 * Updates the title of the editor panel.
		 */
		protected function updateTitleContent():void
		{			
			
		}
		
		/**
		 * Updates the control bar content of the editor panel.
		 */
		protected function updateControlBarContent():void
		{
			var controlBar:ControlBar = new ControlBar();
			
			var update:Button = new Button();
			update.label = "Update";
			update.width = 60;
			update.addEventListener(MouseEvent.CLICK, onUpdate);
			
			var ok:Button = new Button();
			ok.label = "OK";
			ok.width = 60;
			ok.addEventListener(MouseEvent.CLICK, onOK);
			
			var cancel:Button = new Button();
			cancel.label = "Cancel";
			cancel.width = 60;
			cancel.addEventListener(MouseEvent.CLICK, onCancel);
			
			var spacer:Spacer = new Spacer();
			spacer.percentWidth = 100;
			
			controlBar.addElement(spacer);
			//controlBar.addElement(update);
			controlBar.addElement(ok);
			controlBar.addElement(cancel);
			controlBar.percentWidth = 100;
			
			//this.controlBar = controlBar;
			//this.controlBar.enabled = true;
			
			this.addElement(controlBar);
			
			// spark version..
			
//			var barLayout:HorizontalLayout = new HorizontalLayout(); 
//			
//			barLayout.gap = 10;
//			barLayout.paddingLeft = 50;
//			barLayout.paddingRight = 50;
//			barLayout.paddingTop = 5;
//			barLayout.paddingBottom = 5;
//			
//			this.controlBarLayout = barLayout;			
//			
//			this.controlBarContent = new Array();
//			this.controlBarContent.push(ok);
//			this.controlBarContent.push(cancel);
			
		}
		
		/**
		 * Updates the style and closes the panel.
		 */
		protected function onOK(evt:MouseEvent):void
		{
			this.onUpdate();
			
			this.visible = false;
		}
		
		/**
		 * Updates the style by using the values in the input fields. Do not
		 * check validity of any value since this class is a generic editor.
		 */
		protected function onUpdate(evt:MouseEvent = null):void
		{
			var props:Object = new Object();
			
			for (var name:String in this._inputMap)
			{
				var value:* = (this._inputMap[name] as TextInput).text;
				
				if (value == "false")
				{
					value = false;
				}
				else if (value == "true")
				{
					value = true;
				}
				
				props[name] = value;
			}
			
			this._visualStyle.mergeProps(props);
		}
		
		/**
		 * Closes the editor window.
		 */
		protected function onCancel(evt:MouseEvent):void
		{
			this.visible = false;
		}
	}
}