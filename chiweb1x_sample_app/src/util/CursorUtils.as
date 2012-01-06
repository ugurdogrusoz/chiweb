package util
{
	import mx.managers.CursorManager;
	import mx.managers.CursorManagerPriority;

	/**
	 * Utility class for custom cursors.
	 * 
	 * @author Selcuk Onur Sumer
	 */
	public class CursorUtils
	{
		[Embed(source="/assets/images/opened_hand.png")]
		internal static var _openHandCursor:Class;
		
		[Embed(source="/assets/images/closed_hand.png")]
		internal static var _closedHandCursor:Class;
		
		internal static var _closedHandId:int = -1;
		internal static var _openHandId:int = -1;
		
		public function CursorUtils()
		{
			throw new Error("CursorUtils is an abstract class.");
		}
		
		/**
		 * Shows a closed hand cursor.
		 */
		public static function showClosedHand():void
		{
			// TODO may not work corretly in linux distributions
			// TODO we may need to implement GeneralUtils.isLinux function in the core
			if (_closedHandId === -1)
			{
				_closedHandId = CursorManager.setCursor(_closedHandCursor,
					CursorManagerPriority.MEDIUM,
					-5);
				
				CursorManager.showCursor();
			}
		}
		
		/**
		 * Hides closed hand cursor.
		 */
		public static function hideClosedHand():void
		{
			if (_closedHandId !== -1)
			{
				CursorManager.removeCursor(_closedHandId);
				_closedHandId = -1;
			}
		}
		
		/**
		 * Shows an open hand cursor.
		 */
		public static function showOpenHand():void
		{
			if (_openHandId === -1)
			{
				_openHandId = CursorManager.setCursor(_openHandCursor,
					CursorManagerPriority.LOW,
					-5);
				
				CursorManager.showCursor();
			}
		}
		
		/**
		 * Hides open hand cursor.
		 */
		public static function hideOpenHand():void
		{
			if (_openHandId !== -1)
			{
				CursorManager.removeCursor(_openHandId);
				_openHandId = -1;
			}
		}
	}
}