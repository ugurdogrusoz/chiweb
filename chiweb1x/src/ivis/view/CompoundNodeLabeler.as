package ivis.view
{	
	import flash.text.TextFormat;
	
	import ivis.util.Groups;
	import ivis.util.Labels;
	
	/**
	 * Labeler class for compound nodes.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class CompoundNodeLabeler extends NodeLabeler
	{
		public function CompoundNodeLabeler(
			source:* = Labels.DEFAULT_TEXT_SOURCE,
			group:String = Groups.COMPOUND_NODES,
			format:TextFormat = null,
			filter:* = null)
		{
			super(source, group, format, filter);
		}
	}
}