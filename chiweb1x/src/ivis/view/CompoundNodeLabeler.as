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
		
		//------------------------- CONSTRUCTOR --------------------------------
		
		/**
		 * Instantiates a labeler for compound nodes.
		 * 
		 * @param source	source property of the label text
		 * 					(default value is "props.labelText")
		 * @param access	target property to store node's label
		 * 					(default value is "props.$label")
		 * @param group		the data group
		 * 					(default value is Groups.COMPOUND_NODES)
		 * @param format	optional text formatting information
		 * @param filter	function determining which compounds to be labelled
		 */
		public function CompoundNodeLabeler(
			source:* = Labels.DEFAULT_TEXT_SOURCE,
			access:String = Labels.DEFAULT_LABEL_ACCESS,
			group:String = Groups.COMPOUND_NODES,
			format:TextFormat = null,
			filter:* = null)
		{
			super(source, access, group, format, filter);
		}
	}
}