/** 
* Authors: Ebrahim Rajabzadeh
*
* Copyright: i-Vis Research Group, Bilkent University, 2009 - present 
*/
package ivis
{
	import flash.geom.Point;
	
	import mx.containers.*;
	import mx.controls.ColorPicker;
	import mx.controls.ComboBox;
	import mx.controls.Label;
	import mx.controls.NumericStepper;
	import mx.events.ColorPickerEvent;
	import mx.events.ListEvent;
	import mx.events.NumericStepperEvent;
	
	public class EdgeInspector extends InspectorComponent
	{		
		
		private var _edgeComponent: EdgeComponent;
		
		public function EdgeInspector(edgeComponent: EdgeComponent)
		{
			this._edgeComponent = edgeComponent;
			super(edgeComponent, "Edge Inspector");
		}
		
		override protected function setupChildren(): void
		{
			var vb: VBox = new VBox;
			
			for each(var e:* in _edgeComponent.properties()) {
				var keyText: String = e.key;
				var keyLabel: Label = new Label;
				keyLabel.width = 120;
				keyLabel.setStyle("fontWeight", "bold");
				keyLabel.text = keyText;
				
				var hb: HBox = new HBox;
				hb.addChild(keyLabel);
				
				var valueText: String = e.value;
				
				if(keyText == "Line Color") {
					var cp: ColorPicker = new ColorPicker;
					cp.selectedColor = uint(valueText);
					cp.addEventListener("change", function(e: ColorPickerEvent): void {
						_edgeComponent.color = e.color;
					});
					hb.addChild(cp);
				}	
				else if(keyText == "Bend Point Color") {
					var cp2: ColorPicker = new ColorPicker;
					cp2.selectedColor = uint(valueText);
					cp2.addEventListener("change", function(e: ColorPickerEvent): void {
						_edgeComponent.bendPointColor = e.color;
					});
					hb.addChild(cp2);
				}	
				else if(keyText == "Weight") {
					var ns: NumericStepper = new NumericStepper;
					ns.width = 50;
					ns.maximum = 20;
					ns.minimum = 1;
					ns.value = int(valueText);
					
					hb.addChild(ns);
					
					ns.addEventListener("change", function(e: NumericStepperEvent): void {
						_edgeComponent.weight = uint(e.value);
					});
				}	
				else if(keyText == "Source Arrow") {
					var cb: ComboBox = new ComboBox;
					cb.width = 100;
					var arrows: Array = EdgeComponent.arrowTypes();
					cb.dataProvider = arrows;

					var i: int = 0;
					for each(var obj:* in arrows) {
						if(_edgeComponent.sourceArrow == obj.value) {
							cb.selectedIndex = i;
							break;
						}
						++i;
					}

					cb.addEventListener("change", function(e: ListEvent): void {
						_edgeComponent.sourceArrow = arrows[cb.selectedIndex].value;
					});
					hb.addChild(cb);
				}
				else if(keyText == "Line Style") {
					var cb3: ComboBox = new ComboBox;
					cb3.width = 100;
					var styles: Array = EdgeComponent.lineStyles();
					cb3.dataProvider = styles;

					var j: int = 0;
					for each(var obj3:* in arrows2) {
						if(_edgeComponent.lineStyle == obj3.value) {
							cb3.selectedIndex = j;
							break;
						}
						++j;
					}

					cb3.addEventListener("change", function(e: ListEvent): void {
						_edgeComponent.lineStyle = styles[cb3.selectedIndex].value;
					});
					hb.addChild(cb3);
				}
				else if(keyText == "Target Arrow") {
					var cb2: ComboBox = new ComboBox;
					cb2.width = 100;
					var arrows2: Array = EdgeComponent.arrowTypes();
					cb2.dataProvider = arrows2;

					var k: int = 0;
					for each(var obj2:* in arrows2) {
						if(_edgeComponent.targetArrow == obj2.value) {
							cb2.selectedIndex = k;
							break;
						}
						++k;
					}

					cb2.addEventListener("change", function(e: ListEvent): void {
						_edgeComponent.targetArrow = arrows2[cb2.selectedIndex].value;
					});
					hb.addChild(cb2);
				} else {
					var l: Label = new Label;
					l.text = valueText;
					hb.addChild(l);
				}
				
				vb.addChild(hb);
				
			}
			
					
			addChild(vb);
		}
	}
}