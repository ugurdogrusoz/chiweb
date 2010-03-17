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
	import mx.events.NumericStepperEvent;

	public class GraphInspector extends InspectorComponent
	{
		public function GraphInspector(component:Component)
		{
			super(component, "Graph Inspector");
		}

		override protected function setupChildren(): void
		{
			var g: Graph = Graph.getInstance();
			var vb: VBox = new VBox;
			
			trace(g);
			for each(var e:* in g.properties()) {
				var keyText: String = e.key;
				var keyLabel: Label = new Label;
				keyLabel.width = 120;
				//keyLabel.opaqueBackground = true;
				keyLabel.setStyle("fontWeight", "bold");
				//keyLabel.setStyle("background", "0x445566");
				keyLabel.text = keyText;
				
				var hb: HBox = new HBox;
				hb.addChild(keyLabel);
				
				var valueText: String = e.value;
				
				if(keyText == "Highlight Color") {
					var cp: ColorPicker = new ColorPicker;
					cp.selectedColor = uint(valueText);
					cp.addEventListener("change", function(e: ColorPickerEvent): void {
						Component.highlightColor = e.color;
					});
					hb.addChild(cp);
				}	
				else if(keyText == "Margin") {
					var ns: NumericStepper = new NumericStepper;
					ns.width = 70;
					ns.maximum = 200;
					ns.minimum = 0;
					ns.value = int(valueText);
					
					hb.addChild(ns);
					
					ns.addEventListener("change", function(e: NumericStepperEvent): void {
						g.margin = uint(e.value);
					});
				} else {
					var l: Label = new Label;
					l.text = valueText;
					hb.addChild(l);
				}
				
				vb.addChild(hb);
				
			}
			
					
			addChild(vb);
		}
		
		override protected function closeButtonClickEvent(e: Event): void
		{
			Graph.getInstance().toggleInspector();
		}
	}
	

}