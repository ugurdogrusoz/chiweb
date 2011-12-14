package ivis.util
{
	import flare.vis.data.EdgeSprite;
	
	import ivis.model.IStyleAttachable;
	import ivis.model.Node;
	import ivis.model.VisualStyle;

	/**
	 * Utility class for visual styles.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class VisualStyles
	{
		//------------------------CONSTANTS-------------------------------------
		
		public static const DEFAULT_STYLE:String = "$defaultStyle";
		public static const SPECIFIC_STYLE:String = "$specificStyle";
		
		//-------------------------CONSTRUCTOR----------------------------------
		
		public function VisualStyles()
		{
			throw new Error("VisualStyles is an abstract class.");
		}
		
		//-----------------------PUBLIC FUNCTIONS-------------------------------
		
		/**
		 * Re-applies all styles attached to the given element. This function
		 * always applies the default style first, and element-specific style
		 * last. Group styles are applied after the default style, and before
		 * the element-specific style.This order gives priority to the 
		 * element-specific style over group styles, and priority to group
		 * styles over the default style. This prevents general styles to
		 * overwrite more specific styles.
		 * 
		 * param element	element to re-apply styles 
		 */
		public static function reApplyStyles(element:IStyleAttachable) : void
		{
			var style:VisualStyle;
			var dirty:Boolean = false;
			
			// re-apply default style
			
			style = element.getStyle(VisualStyles.DEFAULT_STYLE);
			
			if (style != null)
			{
				style.apply(element);
				dirty = true;
			}
			
			// re-apply group styles
			
			for each (style in element.groupStyles)
			{
				style.apply(element);
				dirty = true;
			}
			
			// re-apply specific sytle
			
			style = element.getStyle(VisualStyles.SPECIFIC_STYLE);
			
			if (style != null)
			{
				style.apply(element);
				dirty = true;
			}
			
			
			if (element is Node &&
				dirty)
			{
				// mark incident edges of the node as dirty
				
				for each (var edge:EdgeSprite in 
					Nodes.incidentEdges(element as Node))
				{
					edge.dirty();
				}
			}
		}
		
		/**
		 * Applies the given style to the given element. This function also
		 * re-applies the element-specific style to prevent new style to
		 * overwrite element-specific style.
		 * 
		 * @param element	element to apply style
		 * @param style		style to be applied 
		 */
		public static function applyNewStyle(element:IStyleAttachable,
			style:VisualStyle) : void
		{
			var dirty:Boolean = false;
			
			// apply new style to sprite
			if (style != null)
			{
				style.apply(element);
				dirty = true;
				
				// re-apply specific style
				style = element.getStyle(VisualStyles.SPECIFIC_STYLE);
				
				if (style != null)
				{
					style.apply(element);
					dirty = true;
				}
			}
			
			if (dirty && element is Node)
			{
				// mark incident edges of the node as dirty
				
				for each (var edge:EdgeSprite in 
					Nodes.incidentEdges(element as Node))
				{
					edge.dirty();
				}
			}
		}
	}
}