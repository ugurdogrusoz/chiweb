package ivis.persist
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	import ivis.manager.GlobalConfig;
	import ivis.manager.GraphManager;
	import ivis.manager.GraphStyleManager;
	import ivis.model.Graph;

	/**
	 * A simple interface for graph export/import operations.
	 * 
	 * @author Selcuk Onur Sumer 
	 */
	public interface IGraphPorter
	{
		/**
		 * Processes the given input data object and creates a new Graph
		 * instance. 
		 * 
		 * @param input			input data object to be exported
		 * @param styleManager	style manager to add new styles
		 * @param config		global configuration to add config values
		 * @return				a Graph instance 
		 */
		function importGraph(inputData:Object,
			styleManager:GraphStyleManager = null,
			config:GlobalConfig = null):Graph;
		
		/**
		 * Creates a new data object fot the contents of the given graph.
		 * 
		 * @param graph			graph whose contents to be exported
		 * @param styleManager	style manager to write style info
		 * @param config		global configuration to write config info
		 * @return				graph as a data output object
		 */
		function exportGraph(graph:Graph,
			styleManager:GraphStyleManager = null,
			config:GlobalConfig = null):Object;
	}
}