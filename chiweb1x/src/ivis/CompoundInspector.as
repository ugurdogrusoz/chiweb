/** 
* Authors: Turgut Isik
*
* Copyright: i-Vis Research Group, Bilkent University, 2009 - present 
*/
package ivis
{
	import flash.events.Event;
	
	import mx.containers.*;
	import mx.controls.ColorPicker;
	import mx.controls.ComboBox;
	import mx.controls.Label;
	import mx.controls.NumericStepper;
	import mx.controls.TextInput;
	import mx.events.ColorPickerEvent;
	import mx.events.ListEvent;
	import mx.events.NumericStepperEvent;
	
	public class CompoundInspector extends NodeInspector
	{
		protected var _cNodeComponent: CompoundNodeComponent;
		
		public function CompoundInspector(cNodeComponent:CompoundNodeComponent)
		{
			this._cNodeComponent = cNodeComponent
			super(_cNodeComponent, "Compound Node Inspector");
		}

		override protected function setupChildren(): void
		{
			
			var vb: VBox = new VBox;
			
			for each(var e:* in _cNodeComponent.properties()) {
				var keyText: String = e.key;
				var keyLabel: Label = new Label;
				keyLabel.width = 70;
				keyLabel.text = keyText;
				keyLabel.setStyle("fontWeight", "bold");
				
				var hb: HBox = new HBox;
				hb.addChild(keyLabel);
				
				var valueText: String = e.value;
				
				if(keyText == "Body Color") {
					var cp: ColorPicker = new ColorPicker;
					cp.selectedColor = uint(valueText);
					cp.addEventListener("change", function(e: ColorPickerEvent): void {
						_cNodeComponent.bodyColor = e.color;
					});
					hb.addChild(cp);
				}	
				else if(keyText == "Label Color") {
					var cp2: ColorPicker = new ColorPicker;
					cp2.selectedColor = uint(valueText);
					cp2.addEventListener("change", function(e: ColorPickerEvent): void {
						_cNodeComponent.labelColor = e.color;
					});
					hb.addChild(cp2);
				}	
				else if(keyText == "Margin") {
					var marginStepper: NumericStepper = new NumericStepper;
					marginStepper.width = 100;
					marginStepper.maximum = 50;
					marginStepper.minimum = 0;
					marginStepper.value = int(valueText);
					
					hb.addChild(marginStepper);
					
					marginStepper.addEventListener("change", function(e: NumericStepperEvent): void {
						_cNodeComponent.margin = marginStepper.value;
					});
				}		
				else if(keyText == "Font") {
					var fb: ComboBox = new ComboBox;
					fb.width = 100;
					var fonts: Array = NodeComponent.availableFonts();
					fb.dataProvider = fonts;

					var i: int = 0;
					for each(var obj:* in fonts) {
						if(_cNodeComponent.font == obj) {
							fb.selectedIndex = i;
							break;
						}
						++i;
					}

					fb.addEventListener("change", function(e: ListEvent): void {
						_cNodeComponent.font = fonts[fb.selectedIndex];
					});
					hb.addChild(fb);
				}
				else if(keyText == "Font Size") {
					var ns: NumericStepper = new NumericStepper;
					ns.width = 100;
					ns.maximum = 36;
					ns.minimum = 3;
					ns.value = int(valueText);
					
					hb.addChild(ns);
					
					ns.addEventListener("change", function(e: NumericStepperEvent): void {
						_cNodeComponent.fontSize = ns.value;
					});
				}	
				else if(keyText == "Label") {
					var ti: TextInput = new TextInput;
					ti.width = 100;
					ti.text = _cNodeComponent.longLabelText;

					ti.addEventListener("change", function(e: Event): void {
						_cNodeComponent.longLabelText = ti.text;
					});
					hb.addChild(ti);
				}
				else if(keyText == "X") {
					_xInput = new TextInput;
					_xInput.width = 100;
					_xInput.restrict = "-.0-9";
					_xInput.addEventListener("change", function(e: Event): void {
						var px: Number = _cNodeComponent.model.relativeX
						_cNodeComponent.model.relativeX = int(_xInput.text);
						
						for each(var n: Node in _cNodeComponent.model.nodes)
							n.translate(_cNodeComponent.model.relativeX - px, 0)
							
						if(_cNodeComponent.model.parent)
							_cNodeComponent.model.parent.revalidate()
					});
					hb.addChild(_xInput);
				}
				else if(keyText == "Y") {
					_yInput = new TextInput;
					_yInput.width = 100;
					_yInput.restrict = "-.0-9";
					_yInput.addEventListener("change", function(e: Event): void {
						var py: Number = _cNodeComponent.model.relativeY
						_cNodeComponent.model.relativeY = int(_yInput.text);

						for each(var n: Node in _cNodeComponent.model.nodes)
							n.translate(0, _cNodeComponent.model.relativeY - py)

						if(_cNodeComponent.model.parent)
							_cNodeComponent.model.parent.revalidate()
					});
					hb.addChild(_yInput);
				} else {
					var l: Label = new Label;
					l.text = valueText;
					hb.addChild(l);
				}
				vb.addChild(hb);
				
				onPosChange(null)
			}
			addChild(vb);
		}	
	}
}