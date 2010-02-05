package away3dlite.loaders.data;

import flash.geom.Matrix3D;
/**
 * Data class for a generic 3d object
 */
class ObjectData
{
	/**
	 * The name of the 3d object used as a unique reference.
	 */
	public var name:String;
	
	/**
	 * The 3d transformation matrix for the 3d object
	 */
	public var transform:Matrix3D;
	
	/**
	 * Colada animation
	 */
	public var id:String;
	public var scale:Float;
	
	public function new()
	{
		transform = new Matrix3D();
	}
}