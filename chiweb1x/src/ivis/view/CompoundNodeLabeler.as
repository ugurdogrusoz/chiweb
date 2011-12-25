package ivis.view
{	
	import flash.text.TextFormat;
	
	import ivis.util.Groups;
	
	/**
	 * Labeler class for compound nodes.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class CompoundNodeLabeler extends NodeLabeler
	{
		public function CompoundNodeLabeler(source:* = null,
			group:String = Groups.COMPOUND_NODES,
			format:TextFormat = null,
			filter:* = null)
		{
			super(source, group, format, filter);
		}
	}
}