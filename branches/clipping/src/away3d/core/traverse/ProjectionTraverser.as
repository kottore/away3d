package away3d.core.traverse
{
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.light.*;
	import away3d.core.math.*;
	import away3d.core.project.*;
	import away3d.core.render.*;
	
	import flash.utils.*;
	
	use namespace arcane;
	
    /**
    * Traverser that resolves the transform tree in a scene, ready for rendering.
    */
    public class ProjectionTraverser extends Traverser
    {
        private var _view:View3D;
        private var _mesh:Mesh;
        private var _camera:Camera3D;
        private var _cameraViewMatrix:Matrix3D;
		private var _cameraViewTransforms:Dictionary;
		
		/**
		 * Defines the view being used.
		 */
		public function get view():View3D
		{
			return _view;
		}
		public function set view(val:View3D):void
		{
			_view = val;
			_camera = _view.camera;
            _cameraViewMatrix = _camera.viewMatrix;
			if (_view.statsOpen)
				_view.statsPanel.clearObjects();
		}
		    	
		/**
		 * Creates a new <code>ProjectionTraverser</code> object.
		 */
        public function ProjectionTraverser()
        {
        }
        
		/**
		 * @inheritDoc
		 */
        public override function match(node:Object3D):Boolean
        {
        	//check if node is visible
            if (!node.visible)
                return false;
            
            //compute viewTransform matrix
            _camera.createViewTransform(node).multiply(_cameraViewMatrix, node.sceneTransform);
            
            //check which LODObject is visible
            if (node is ILODObject)
                return (node as ILODObject).matchLOD(_camera);
            
            return true;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function enter(node:Object3D):void
        {
        	if (_view.statsOpen && node is Mesh)
        		_view.statsPanel.addObject(node as Mesh);
        }
        
        public override function apply(node:Object3D):void
        {
            if (node.projectorType == ProjectorType.CONVEX_BLOCK)
                _view._convexBlockProjector.blockers(node, _camera.viewTransforms[node], _view.blockerarray);
            
        	//add to scene meshes dictionary
            if ((_mesh = node as Mesh))
            	_view.scene.meshes[node] = node;
        }
        
        public override function leave(node:Object3D):void
        {
            //update object
            node.updateObject();
        }
    }
}
