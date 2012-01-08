package ivis.model.util
{
	import flare.display.TextSprite;
	import flare.vis.data.EdgeSprite;
	
	import flash.geom.Rectangle;
	
	import ivis.model.Edge;
	import ivis.model.Node;
	import ivis.util.GeneralUtils;
	import ivis.util.Labels;

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
		public static const NON_SELECTED:String = "nonSelected";
		public static const VISIBLE:String = "visible";
		public static const INVISIBLE:String = "invisible";
		
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
		 * 					Nodes.ALL, Nodes.SELECTED, Nodes.NON_SELECTED,
		 * 					Nodes.VISIBLE, and Nodes.INVISIBLE
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
						condition = node.props.$selected;
					}
					else if (type === Nodes.NON_SELECTED)
					{
						condition = !(node.props.$selected);
					}
					else if (type === Nodes.VISIBLE)
					{
						condition = node.visible;
					}
					else if (type === Nodes.INVISIBLE)
					{
						condition = !(node.visible);
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
			else if (type === Nodes.BOTTOM)
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
		 * 					Nodes.ALL, Nodes.SELECTED, Nodes.NON_SELECTED,
		 * 					Nodes.VISIBLE, and Nodes.INVISIBLE
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
					for each (node in edge.getBendNodes())
					{
						// check for the node condition
						
						if (type === Nodes.SELECTED)
						{
							condition = node.props.$selected;
						}
						else if (type === Nodes.NON_SELECTED)
						{
							condition = !(node.props.$selected);
						}
						else if (type === Nodes.VISIBLE)
						{
							condition = node.visible;
						}
						else if (type === Nodes.INVISIBLE)
						{
							condition = !(node.visible);
						}
						else
						{
							// default case is ALL (always true)
							condition = true;
						}
						
						// if condition met, add node to the list
						if (condition)
						{
							bendNodes[node.data.id] = node;
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
		 * 					Nodes.ALL, Nodes.SELECTED, Nodes.NON_SELECTED,
		 * 					Nodes.VISIBLE, and Nodes.INVISIBLE
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
					condition = edge.props.$selected;
				}
				else if (type === Nodes.NON_SELECTED)
				{
					condition = !(edge.props.$selected);
				}
				else if (type === Nodes.VISIBLE)
				{
					condition = edge.visible;
				}
				else if (type === Nodes.INVISIBLE)
				{
					condition = !(edge.visible);
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
			
			for each (var child:Node in node.getNodes(false))
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
		
		/**
		 * Adjusts the bounds of the given compound node by using local 
		 * coordinates of the given compound node sprite. This function does
		 * not modify the original bounds of the compound. Instead, creates
		 * a new Rectangle instance and applies changes on that instance.
		 * 
		 * @param node	compound node whose bounds will be adjusted
		 * @return		adjusted bounds as a Rectangle instance
		 */
		public static function adjustBounds(node:Node) : Rectangle
		{
			// create a copy of original node bounds
			var bounds:Rectangle = null;
			
			if (node.bounds != null)
			{
				bounds = node.bounds.clone();
				
				// convert bounds from global to local
				bounds.x -= node.x;
				bounds.y -= node.y;
			}
			
			// return adjusted bounds
			return bounds;
		}
		
		/**
		 * Populates an array of Node instances with the parents of selected
		 * type for the given Node. All parents up to root are collected
		 * by default, type can also be selected and non-selected parents.
		 * 
		 * @param node		node whose parents are collected
		 * @return			array of parents matching the given type 
		 */
		public static function getParents(node:Node,
			type:String = Nodes.ALL):Array
		{
			var parents:Array = new Array();
			var condition:Boolean;
			var parent:Node;
			
			if (node != null)
			{
				// get parent
				parent = node.parentN;
				
				while (parent != null)
				{
					if (type === Nodes.SELECTED)
					{
						condition = parent.props.$selected;
					}
					else if (type === Nodes.NON_SELECTED)
					{
						condition = !parent.props.$selected;
					}
					else
					{
						// default case is all parents (always true)
						condition = true;
					}
					
					// process the node if the condition meets
					if (condition)
					{
						// add current node to the list
						parents.push(parent);
					}
					
					// advance to next parent
					parent = parent.parentN
				}
			}
			
			return parents;
		}
		
		/**
		 * If the given node is filtered out, returns true. If a node itself 
		 * is not filtered out, but at least one of its parents is filtered out,
		 * then the node is also considered as filtered out. If a node is a
		 * bend node, and its parent edge is filtered out, then the node is also
		 * considered as filtered out.
		 * 
		 * @param node	node to be checked
		 * @return		true if filtered out, false otherwise
		 */
		public static function isFiltered(node:Node):Boolean
		{
			var filtered:Boolean = node.props.$filtered;
			
			// if a node is not filtered out, but at least one of its parents
			// is filtered out, then the node should also be filtered out
			for each (var parent:Node in Nodes.getParents(node))
			{
				if (parent.props.$filtered)
				{
					filtered = true;
					break;
				}
			}
			
			// if node is a bend node, check its parent edge
			if (node.isBendNode)
			{
				filtered = filtered ||
					Edges.isFiltered(node.parentE);
			}
			
			return filtered;
		}
	}
}