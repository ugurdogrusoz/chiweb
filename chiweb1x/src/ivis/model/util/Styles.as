package ivis.model.util
{
	import flare.vis.data.EdgeSprite;
	
	import ivis.model.Edge;
	import ivis.model.IStyleAttachable;
	import ivis.model.Node;
	import ivis.model.Style;

	/**
	 * Utility class for visual styles.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class Styles
	{
		//------------------------CONSTANTS-------------------------------------
		
		public static const DEFAULT_STYLE:String = "$defaultStyle";
		public static const SPECIFIC_STYLE:String = "$specificStyle";
		
		//-------------------------CONSTRUCTOR----------------------------------
		
		public function Styles()
		{
			throw new Error("Styles is an abstract class.");
		}
		
		//-----------------------PUBLIC FUNCTIONS-------------------------------
		
		/**
		 * Re-applies all styles attached to the given element. This function
		 * always applies the default style first, and element-specific style
		 * last. Group styles are applied after the default style, and before
		 * the element-specific style. This order gives priority to the 
		 * element-specific style over group styles, and priority to group
		 * styles over the default style. This prevents general styles to
		 * overwrite more specific styles.
		 * 
		 * @param element	element to re-apply styles 
		 * @param propagate	indicates whether to propagate to child segments
		 * 					(this parameter is valid only for edges)
		 */
		public static function reApplyStyles(element:IStyleAttachable,
			propagate:Boolean = false):void
		{
			if (element is Node)
			{
				Styles.reApplyNodeStyles(element as Node);
			}
			else if (element is Edge)
			{
				Styles.reApplyEdgeStyles(element as Edge, propagate);
			}
			else
			{
				Styles.applyStyles(element);
			}
			
		}
		
		/**
		 * Re-applies all styles attached to the given node. 
		 * 
		 * @param node	node to re-apply styles
		 */
		private static function reApplyNodeStyles(node:Node):void
		{
			var dirty:Boolean = Styles.applyStyles(node);
			
			if (dirty)
			{
				// mark incident edges of the node as dirty
				for each (var edge:EdgeSprite in Nodes.incidentEdges(node))
				{
					edge.dirty();
				}
			}
		}
		
		/**
		 * Re-applies all styles attached to the given edge. 
		 * 
		 * @param edge		edge to re-apply styles
		 * @param propagate	indicates whether to propagate to child segments
		 */
		private static function reApplyEdgeStyles(edge:Edge,
			propagate:Boolean = true):void
		{
			var dirty:Boolean = Styles.applyStyles(edge);
			
			if (propagate &&
				edge.hasBendPoints())
			{
				// propagate style to the child segments
				for each (var segment:Edge in edge.getSegments())
				{
					Styles.applyStyles(segment);
				}
			}
			
			if (dirty)
			{
				// mark bendpoints of the edge as dirty
				for each (var node:Node in edge.getBendNodes())
				{
					node.dirty();
				}
			}
		}
		
		/**
		 * Applies all styles attached to the given element.
		 * 
		 * @param element	element to re-apply styles
		 * @return			return true if any style is re-applied, false o.w.	
		 */
		private static function applyStyles(element:IStyleAttachable):Boolean
		{
			var style:Style;
			var dirty:Boolean = false;
			
			// re-apply default style
			
			style = element.getStyle(Styles.DEFAULT_STYLE);
			
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
			
			style = element.getStyle(Styles.SPECIFIC_STYLE);
			
			if (style != null)
			{
				style.apply(element);
				dirty = true;
			}
			
			return dirty;
		}
		
		/**
		 * Applies the given style to the given element. This function also
		 * re-applies the element-specific style to prevent new style to
		 * overwrite element-specific style.
		 * 
		 * @param element	element to apply style
		 * @param style		style to be applied 
		 */
		/*
		public static function applyNewStyle(element:IStyleAttachable,
			style:Style) : void
		{
			var dirty:Boolean = false;
			
			// apply new style to sprite
			if (style != null)
			{
				style.apply(element);
				dirty = true;
				
				// re-apply specific style
				style = element.getStyle(Styles.SPECIFIC_STYLE);
				
				if (style != null)
				{
					style.apply(element);
					dirty = true;
				}
			}
			
			if (element is Node && dirty)
			{
				// mark incident edges of the node as dirty
				
				for each (var edge:EdgeSprite in 
					Nodes.incidentEdges(element as Node))
				{
					edge.dirty();
				}
			}
		}
		*/
	}
}