/**
* Author: Ebrahim Rajabzadeh
*
* Copyright: i-Vis Research Group, Bilkent University, 2009 - present 
*/

package ivis
{
	import flash.events.Event;
	
	import mx.containers.*;
	import mx.controls.*;
	import mx.events.ColorPickerEvent;
	import mx.events.ListEvent;
	import mx.events.NumericStepperEvent;
	
	public class NodeInspector extends InspectorComponent
	{
		protected var _nodeComponent: NodeComponent;
		protected var _xInput: TextInput;
		protected var _yInput: TextInput;
		
		public function NodeInspector(nodeComponent:NodeComponent, title: String = "Node Inspector")
		{
			this._nodeComponent = nodeComponent;
			
			nodeComponent.addEventListener("xChanged", onPosChange);
			nodeComponent.addEventListener("yChanged", onPosChange);
			nodeComponent.addEventListener("addedToCompound", onPosChange);
			nodeComponent.addEventListener("removedFromCompound", onPosChange);
			
			super(nodeComponent, title);
		}

		internal function onPosChange(e: Event): void
		{
			if (this._nodeComponent.inspectorShown && _xInput && _yInput) {
				_xInput.text = Utils.formatNumber(_nodeComponent.model.relativeX)
				_yInput.text = Utils.formatNumber(_nodeComponent.model.relativeY)
			}
		}
		
		override protected function setupChildren(): void
		{
			
			var vb: VBox = new VBox;
			
			for each (var e:* in _nodeComponent.properties())
			{
				var keyText: String = e.key;
				var keyLabel: Label = new Label;
				keyLabel.width = 70;
				keyLabel.text = keyText;
				keyLabel.setStyle("fontWeight", "bold");
				
				var hb: HBox = new HBox;
				hb.addChild(keyLabel);
				
				var valueText: String = e.value;
				
				if (keyText == "Color 1") {
					var cp: ColorPicker = new ColorPicker;
					cp.selectedColor = uint(valueText);
					_nodeComponent.addEventListener("color1Changed", function(e: Event): void {
						cp.selectedColor = _nodeComponent.color1
					})
					cp.addEventListener("change", function(e: ColorPickerEvent): void {
						_nodeComponent.color1 = e.color;
					});
					hb.addChild(cp);
				}	
				else if (keyText == "Color 2") {
					var cp2: ColorPicker = new ColorPicker;
					cp2.selectedColor = uint(valueText);
					cp2.addEventListener("change", function(e: ColorPickerEvent): void {
						_nodeComponent.color2 = e.color;
					});
					_nodeComponent.addEventListener("color2Changed", function(e: Event): void {
						cp2.selectedColor = _nodeComponent.color2
					})
					hb.addChild(cp2);
				}	
				else if (keyText == "Shape") {
					var cb: ComboBox = new ComboBox;
					cb.width = 100;
					var shapes: Array = NodeComponent.availableShapes();
					cb.dataProvider = shapes;

					var i: int = 0;
					for each(var obj:* in shapes) {
						if(_nodeComponent.shape == obj.value) {
							cb.selectedIndex = i;
							break;
						}
						++i;
					}

					cb.addEventListener("change", function(e: ListEvent): void {
						_nodeComponent.shape = shapes[cb.selectedIndex].value;
					});
					hb.addChild(cb);
				}	
				else if (keyText == "Font") {
					var fb: ComboBox = new ComboBox;
					fb.width = 100;
					var fonts: Array = NodeComponent.availableFonts();
					fb.dataProvider = fonts;

					i = 0;
					for each(var obj2:* in fonts) {
						if(_nodeComponent.font == obj2) {
							fb.selectedIndex = i;
							break;
						}
						++i;
					}

					fb.addEventListener("change", function(e: ListEvent): void {
						_nodeComponent.font = fonts[fb.selectedIndex];
					});
					hb.addChild(fb);
				}
				else if (keyText == "Font Size") {
					var ns: NumericStepper = new NumericStepper;
					ns.width = 100;
					ns.maximum = 36;
					ns.minimum = 3;
					ns.value = int(valueText);
					
					hb.addChild(ns);
					
					ns.addEventListener("change", function(e: NumericStepperEvent): void {
						_nodeComponent.fontSize = ns.value;
					});
				}	
				else if (keyText == "Label") {
					var ti: TextInput = new TextInput;
					ti.width = 100;
					ti.text = _nodeComponent.longLabelText;

					ti.addEventListener("change", function(e: Event): void {
						_nodeComponent.longLabelText = ti.text;
					});
					hb.addChild(ti);
				}
				else if (keyText == "X") {
					_xInput = new TextInput;
					_xInput.width = 100;
					_xInput.restrict = "-.0-9";
					_xInput.addEventListener("change", function(e: Event): void {
						_nodeComponent.model.relativeX = int(_xInput.text);
						if(_nodeComponent.model.parent)
							_nodeComponent.model.parent.revalidate()
					});
					hb.addChild(_xInput);
				}
				else if (keyText == "Y") {
					_yInput = new TextInput;
					_yInput.width = 100;
					_yInput.restrict = "-.0-9";
					_yInput.addEventListener("change", function(e: Event): void {
						_nodeComponent.model.relativeY = int(_yInput.text);
						if(_nodeComponent.model.parent)
							_nodeComponent.model.parent.revalidate()
					});
					hb.addChild(_yInput);
				}
				else if (keyText == "Cluster")
				{
					var cin: TextInput = new TextInput
					cin.restrict = "0-9"
					cin.width = 100
					cin.text = valueText
					cin.addEventListener("change", function(e: Event): void {
						_nodeComponent.model.setClusterID(uint((e.target as TextInput).text))
					})
					_nodeComponent.model.addEventListener("clusterChanged", function(e: Event): void {
						cin.text = _nodeComponent.model.getClusterID()
					})
					hb.addChild(cin)
				}
				else
				{
					var l: Label = new Label;
					l.text = valueText;
					hb.addChild(l);
				}
				
				onPosChange(null)
				
				vb.addChild(hb);
				
			}
					
			addChild(vb);
		}
	}
}