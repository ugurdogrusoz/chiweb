package ivis.model
{
	/**
	 * 
	 * @author Ebrahim
	 */
	public class GraphOptions
	{
		// General consts		
		/**
		 * 
		 * @default 
		 */
		public static const PROOF_QUALITY:int = 0;
		/**
		 * 
		 * @default 
		 */
		public static const DEFAULT_QUALITY:int = 1;
		/**
		 * 
		 * @default 
		 */
		public static const DRAFT_QUALITY:int = 2;

		// CoSE consts
		/**
		 * 
		 * @default 
		 */
		public static const DEFAULT_EDGE_LENGTH:uint = 40;
		/**
		 * 
		 * @default 
		 */
		public static const DEFAULT_SPRING_STRENGTH:Number = 50;
		/**
		 * 
		 * @default 
		 */
		public static const DEFAULT_REPULSION_STRENGTH:Number = 50;
		/**
		 * 
		 * @default 
		 */
		public static const DEFAULT_GRAVITY_STRENGTH:Number = 50;
		/**
		 * 
		 * @default 
		 */
		public static const DEFAULT_COMPOUND_GRAVITY_STRENGTH:Number = 50;

		// CiSE consts
		/**
		 * 
		 * @default 
		 */
		public static const DEFAULT_NODE_SEPARATION:uint = 60;
		/**
		 * 
		 * @default 
		 */
		public static const DEFAULT_CISE_EDGE_LENGTH:uint = 40;
		/**
		 * 
		 * @default 
		 */
		public static const DEFAULT_INTER_CLUSTER_EDGE_LENGTH_FACTOR:Number = 50;

		// General options
		var quality: uint = DEFAULT_QUALITY;
		var incremental: Boolean = false;
		var animateOnLayout: Boolean = true;
		 
		// CoSe options
		var idealEdgeLength: uint = DEFAULT_EDGE_LENGTH;
		var springStrength: uint = DEFAULT_SPRING_STRENGTH;
		var repulsionStrength: uint = DEFAULT_REPULSION_STRENGTH;
		var gravityStrength: uint = DEFAULT_GRAVITY_STRENGTH;
		var compoundGravityStrength: uint = DEFAULT_COMPOUND_GRAVITY_STRENGTH;

		// CiSe options
		var nodeSeparation: uint = DEFAULT_NODE_SEPARATION;
		var desiredEdgeLength: uint = DEFAULT_CISE_EDGE_LENGTH;
		var interClusterEdgeLengthFactor: uint = DEFAULT_INTER_CLUSTER_EDGE_LENGTH_FACTOR;
		
		/**
		 * 
		 */
		public function GraphOptions()
		{
		}

	}
}