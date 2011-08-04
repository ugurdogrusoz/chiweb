package ivis.util
{
	import flare.display.TextSprite;
	import flare.vis.data.EdgeSprite;
	
	import ivis.model.Edge;
	import ivis.model.Node;

	/**
	 * Utility class for nodes.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class Nodes
	{
		//------------------------CONSTANTS-------------------------------------
		
		public static const ALL:String = "all";
		public static const SELECTED:String = "selected";
		public static const NON_SELECTED:String = "non-selected";
		
		public static const LEFT:String = "left";
		public static const RIGHT:String = "right";
		public static const TOP:String = "top";
		public static const BOTTOM:String = "bottom";
		
		
		//-------------------------CONSTRUCTOR----------------------------------
		
		public function Nodes()
		{
			throw new Error("Nodes is an abstract class.");
		}
		
		//-----------------------PUBLIC FUNCTIONS-------------------------------
		
		/**
		 * Recursively populates an array of Node instances with the children
		 * of selected type for the given compound node. All children are
		 * collected by default, type can also be selected and non-selected.
		 * 
		 * @param compound	compound node whose children are collected
		 * @param type		type of the nodes to be collected, valid types are:
		 * 					Nodes.ALL, Nodes.SELECTED and Nodes.NON_SELECTED
		 * @return			array of child nodes matching the given type
		 */
		public static function getChildren(compound:Node,
			type:String = Nodes.ALL) : Array
		{
			var children:Array = new Array();
			var condition:Boolean;
			
			if (compound != null)
			{
				for each (var node:Node in compound.getNodes())
				{
					if (type === Nodes.SELECTED)
					{
						if (node.props.selected)
						{
							condition = true;
						}
						else
						{
							condition = false;
						}
					}
					else if (type === Nodes.NON_SELECTED)
					{
						if (node.props.selected)
						{
							condition = false;
						}
						else
						{
							condition = true;
						}
					}
					else
					{
						// default case is ALL (always true)
						condition = true;
					}
					
					// process the node if the condition meets
					if (condition)
					{
						// add current node to the list
						children.push(node);
					}
										
					// recursively collect child nodes
					children = children.concat(getChildren(node, type));
				}
			}
			
			return children;
		}
		
		/**
		 * Finds the border value for the given array of nodes. There are four
		 * types of border values: left, right, top, bottom. The desired border
		 * type is specified by the type parameter.  
		 * 
		 * @param nodes	array of nodes
		 * @param type	type of the border, valid border types are:
		 * 				Nodes.LEFT, Nodes.RIGHT, Nodes.TOP, Nodes.BOTTOM
		 * @return		border value as a Number
		 */
		public static function borderValue(nodes:Array, type:String):Number
		{
			var values:Array = new Array();
			var node:Node;
			var value:Number;
			
			// collect required values in the array
			
			if (type === Nodes.LEFT)
			{
				for each (node in nodes)
				{
					if (node.props.label != null)
					{
						value = Labels.leftBorder(
							node.props.label as TextSprite);
						
						values.push(value);
					}
					
					values.push(node.left);
				}
			}
			else if (type === Nodes.RIGHT)
			{
				for each (node in nodes)
				{
					if (node.props.label != null)
					{
						value = Labels.rightBorder(
							node.props.label as TextSprite);
						
						values.push(value);
					}
					
					values.push(node.right);
				}
			}
			else if (type === Nodes.TOP)
			{
				for each (node in nodes)
				{
					if (node.props.label != null)
					{
						value = Labels.topBorder(
							node.props.label as TextSprite);
						
						values.push(value);
					}
					
					values.push(node.top);
				}
			}
			if (type === Nodes.BOTTOM)
			{
				for each (node in nodes)
				{
					if (node.props.label != null)
					{
						value = Labels.bottomBorder(
							node.props.label as TextSprite);
						
						values.push(value);
					}
					
					values.push(node.bottom);
				}
			}
			
			// calculate the border value according to the type
			
			if ((type === Nodes.LEFT) || (type === Nodes.TOP))
			{
				value = GeneralUtils.min(values);
			}
			else
			{
				value = GeneralUtils.max(values);
			}
			
			return value;
		}
		
		/**
		 * Calculates the the lowest common ancestor of given two nodes. If
		 * there is no common ancestor, this function returns null.
		 * 
		 * @param firstNode		first node
		 * @param secondNode 	second node
		 * @return				lca if exists, null otherwise
		 */
		public static function calcLowestCommonAncestor(firstNode:Node,
			secondNode:Node):Node
		{
			if (firstNode == secondNode)
			{
				return firstNode.parentN;
			}
			
			var firstOwnerNode:Node = firstNode.parentN;
			var secondOwnerNode:Node;
			
			do
			{
				if (firstOwnerNode == null)
				{
					break;
				}
				
				secondOwnerNode = secondNode.parentN;
				
				do
				{			
					if (secondOwnerNode == null)
					{
						break;
					}
					
					if (secondOwnerNode == firstOwnerNode)
					{
						return secondOwnerNode;
					}
					
					secondOwnerNode = secondOwnerNode.parentN;
				} while (true);
				
				firstOwnerNode = firstOwnerNode.parentN;
			} while (true);
			
			return firstOwnerNode;
		}
		
		/**
		 * Finds the bendpoints (bend nodes) which reside inside the given
		 * compound node. For a bend node in order to satisfy the condition of
		 * "residing inside", it is required to be a bend point on an edge whose
		 * source and target nodes' lowest common ancestor is the given compound
		 * node, or one of its children.
		 * 
		 * @param compound	target node
		 * @param type		type of the nodes to be collected, valid types are:
		 * 					Nodes.ALL, Nodes.SELECTED and Nodes.NON_SELECTED
		 * @return			array of inner bend nodes matching the given type
		 */
		public static function innerBends(compound:Node,
			type:String = Nodes.ALL):Array
		{
			var bendNodes:Object = new Object();
			var edges:Object = new Object();
			var innerBends:Array = new Array();
			
			var children:Array = Nodes.getChildren(compound);
			
			var node:Node;
			
			// collect all candidate edges related to the child nodes
			
			for each (node in children)
			{
				
				for each (var es:EdgeSprite in Nodes.incidentEdges(node))
				{
					edges[es.data.id] = es;
				}
			}
			
			// find inner bend points
			
			for each (var edge:Edge in edges)
			{
				var lca:Node = Nodes.calcLowestCommonAncestor(
					edge.source as Node, edge.target as Node);
				
				var inner:Boolean = false;
				var condition:Boolean;
				
				// if lca is the compound node or one of its children, then
				// add all bendNodes of the edge to the list
				
				while (lca != null)
				{
					if (lca === compound)
					{
						inner = true;
						break;
					}
					
					lca = lca.parentN;
				}				
				
				if (inner)
				{
					for each (var bendNode:Node in edge.getBendNodes())
					{
						
						// check for the node condition
						
						if (type === Nodes.SELECTED)
						{
							if (node.props.selected)
							{
								condition = true;
							}
							else
							{
								condition = false;
							}
						}
						else if (type === Nodes.NON_SELECTED)
						{
							if (node.props.selected)
							{
								condition = false;
							}
							else
							{
								condition = true;
							}
						}
						else
						{
							// default case is ALL (always true)
							condition = true;
						}
						
						// if condition met, add node to the list
						if (condition)
						{
							bendNodes[bendNode.data.id] = bendNode;
						}
					}
				}
			}
			
			// convert object map to an array
			for each (node in bendNodes)
			{
				innerBends.push(node);
			}
			
			return innerBends;
		}
		
		/**
		 * Populates an array of incident edges of selected type for the given 
		 * node. All incident edges are collected by default, type can also be 
		 * selected and non-selected.
		 * 
		 * @param node		node whose incident edges are collected
		 * @param type		type of the edges to be collected, valid types are:
		 * 					Nodes.ALL, Nodes.SELECTED and Nodes.NON_SELECTED
		 * @return			array of incident edges matching the given type
		 */
		public static function incidentEdges(node:Node,
			type:String = Nodes.ALL):Array
		{
			var edges:Array = new Array();
			
			node.visitEdges(function visitor(edge:EdgeSprite):void {				
				var condition:Boolean;
				// check for the edge condition
				
				if (type === Nodes.SELECTED)
				{
					if (edge.props.selected)
					{
						condition = true;
					}
					else
					{
						condition = false;
					}
				}
				else if (type === Nodes.NON_SELECTED)
				{
					if (edge.props.selected)
					{
						condition = false;
					}
					else
					{
						condition = true;
					}
				}
				else
				{
					// default case is ALL (always true)
					condition = true;
				}
				
				if (condition)
				{
					edges.push(edge);
				}
			});
			
			return edges;
		}
		
		/**
		 * Brings all child node sprites of the given compound node sprite as
		 * well as the edges inside the compound node to the front.
		 * 
		 * @param node	node sprite whose children are brougt to front
		 */
		public static function bringNodeToFront(node:Node) : void
		{
			// bring node to front
			GeneralUtils.bringToFront(node);
			
			// bring every child component to the front
			
			for each (var child:Node in node.getNodes())
			{
				// bring node to front
				GeneralUtils.bringToFront(child);
				
				if (child.isInitialized())
				{
					// recursive call
					bringNodeToFront(child);
				}
				
				// find and bring all incident edges to front
				
				for each (var es:EdgeSprite in Nodes.incidentEdges(child))
				{
					GeneralUtils.bringToFront(es);
					
					if ((es is Edge) && !(es as Edge).isSegment)
					{
						for each (var segment:Edge in
							(es as Edge).getSegments())
						{
							GeneralUtils.bringToFront(segment);
						}
						
						for each (var bendNode:Node in
							(es as Edge).getBendNodes())
						{
							GeneralUtils.bringToFront(bendNode);
						}
					}
				}
			}
		}
	}
}