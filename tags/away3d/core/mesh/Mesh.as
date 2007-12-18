package away3d.core.mesh
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    import away3d.core.render.*;
    import away3d.core.scene.*;
    import away3d.core.utils.*;
    import away3d.objects.*;
    
    import flash.display.*;
    import flash.utils.Dictionary;
    
    /** Mesh constisting of faces and segments */
    public class Mesh extends BaseMesh implements IPrimitiveProvider
    {
        use namespace arcane;

        private var _faces:Array = [];
		
		
        public function get faces():Array
        {
            return _faces;
        }

        public override function get elements():Array
        {
            return _faces;
        }

        private var _neighboursDirty:Boolean = true;
        private var _neighbour01:Dictionary; 
        private var _neighbour12:Dictionary; 
        private var _neighbour20:Dictionary; 

        private var _vertfacesDirty:Boolean = true;
        private var _vertfaces:Dictionary;
        
        private var _vertnormalsDirty:Boolean = true;
		private var _vertnormals:Dictionary;
		
        private function findVertFaces():void
        {
            if (!_vertfacesDirty)
                return;
            
            _vertfaces = new Dictionary();
            for each (var face:Face in faces)
            {
                var v0:Vertex = face.v0;
                if (_vertfaces[face.v0] == null)
                    _vertfaces[face.v0] = [face];
                else
                    _vertfaces[face.v0].push(face);
                var v1:Vertex = face.v1;
                if (_vertfaces[face.v1] == null)
                    _vertfaces[face.v1] = [face];
                else
                    _vertfaces[face.v1].push(face);
                var v2:Vertex = face.v2;
                if (_vertfaces[face.v2] == null)
                    _vertfaces[face.v2] = [face];
                else
                    _vertfaces[face.v2].push(face);
            }
            
            _vertfacesDirty = false;
        }
        
        private function findVertNormals():void
        {
        	if (!_vertnormalsDirty)
                return;
            
            _vertnormals = new Dictionary();
            for each (var v:Vertex in vertices)
            {
            	var vF:Array = _vertfaces[v];
            	var nX:Number = 0;
            	var nY:Number = 0;
            	var nZ:Number = 0;
            	for each (var f:Face in vF)
            	{
	            	var fNormal:Number3D = f.normal;
            		nX += fNormal.x;
            		nY += fNormal.y;
            		nZ += fNormal.z;
            	}
            	var vertNormal:Number3D = new Number3D(nX, nY, nZ);
            	vertNormal.normalize();
            	_vertnormals[v] = vertNormal;
            }            
            
            _vertnormalsDirty = false;    
        }

        arcane function getFacesByVertex(vertex:Vertex):Array
        {
            if (_vertfacesDirty)
                findVertFaces();

            return _vertfaces[vertex];
        }
		
		arcane function getVertexNormal(vertex:Vertex):Number3D
        {
        	if (_vertfacesDirty)
                findVertFaces();
            
            if (_vertnormalsDirty)
                findVertNormals();
            
            return _vertnormals[vertex];
        }
        
        arcane function neighbour01(face:Face):Face
        {
            if (_neighboursDirty)
                findNeighbours();
            return _neighbour01[face];
        }

        arcane function neighbour12(face:Face):Face
        {
            if (_neighboursDirty)
                findNeighbours();
            return _neighbour12[face];
        }

        arcane function neighbour20(face:Face):Face
        {
            if (_neighboursDirty)
                findNeighbours();
            return _neighbour20[face];
        }

        private function findNeighbours():void
        {
            if (!_neighboursDirty)
                return;

            _neighbour01 = new Dictionary();
            _neighbour12 = new Dictionary();
            _neighbour20 = new Dictionary();
            for each (var face:Face in _faces)
            {
                var skip:Boolean = true;
                for each (var another:Face in _faces)
                {
                    if (skip)
                    {
                        if (face == another)
                            skip = false;
                        continue;
                    }

                    if ((face._v0 == another._v2) && (face._v1 == another._v1))
                    {
                        _neighbour01[face] = another;
                        _neighbour12[another] = face;
                    }

                    if ((face._v0 == another._v0) && (face._v1 == another._v2))
                    {
                        _neighbour01[face] = another;
                        _neighbour20[another] = face;
                    }

                    if ((face._v0 == another._v1) && (face._v1 == another._v0))
                    {
                        _neighbour01[face] = another;
                        _neighbour01[another] = face;
                    }
                
                    if ((face._v1 == another._v2) && (face._v2 == another._v1))
                    {
                        _neighbour12[face] = another;
                        _neighbour12[another] = face;
                    }

                    if ((face._v1 == another._v0) && (face._v2 == another._v2))
                    {
                        _neighbour12[face] = another;
                        _neighbour20[another] = face;
                    }

                    if ((face._v1 == another._v1) && (face._v2 == another._v0))
                    {
                        _neighbour12[face] = another;
                        _neighbour01[another] = face;
                    }
                
                    if ((face._v2 == another._v2) && (face._v0 == another._v1))
                    {
                        _neighbour20[face] = another;
                        _neighbour12[another] = face;
                    }

                    if ((face._v2 == another._v0) && (face._v0 == another._v2))
                    {
                        _neighbour20[face] = another;
                        _neighbour20[another] = face;
                    }

                    if ((face._v2 == another._v1) && (face._v0 == another._v0))
                    {
                        _neighbour20[face] = another;
                        _neighbour01[another] = face;
                    }
                }
            }

            _neighboursDirty = false;
        }
         
        arcane function recalcNeighbours():void
        {
            if (!_neighboursDirty)
            {
                _neighboursDirty = true;
                var sn01:Dictionary = _neighbour01;
                var sn12:Dictionary = _neighbour12;
                var sn20:Dictionary = _neighbour20;
                findNeighbours();
                /*
                for each (var f:Face in faces)
                {
                    if (sn01[f] != _neighbour01[f])
                        throw new Error("Got you!");
                    if (sn12[f] != _neighbour12[f])
                        throw new Error("Got you!");
                    if (sn20[f] != _neighbour20[f])
                        throw new Error("Got you!");
                }
                */
            }
        }

        public var material:ITriangleMaterial;
        public var outline:ISegmentMaterial;
        public var back:ITriangleMaterial;

        public var bothsides:Boolean;
        public var debugbb:Boolean;

        public function Mesh(init:Object = null)
        {
            super(init);

            init = Init.parse(init);
            
            material = init.getMaterial("material");
            outline = init.getSegmentMaterial("outline");
            back = init.getMaterial("back");
            bothsides = init.getBoolean("bothsides", false);
            debugbb = init.getBoolean("debugbb", false);

            if ((material == null) && (outline == null))
                material = new WireColorMaterial();
        }
		
        public function addFace(face:Face):void
        {
            addElement(face);

            _faces.push(face);
			
			face._dt.source = face.parent = this;
			face._dt.create = createDrawTriangle;
			
            face.addOnVertexChange(onFaceVertexChange);
            rememberFaceNeighbours(face);
            _vertfacesDirty = true;
        }

        public function removeFace(face:Face):void
        {
            var index:int = _faces.indexOf(face);
            if (index == -1)
                return;

            removeElement(face);

            _vertfacesDirty = true;
            forgetFaceNeighbours(face);
            face.removeOnVertexChange(onFaceVertexChange);

            _faces.splice(index, 1);
        }

        private function rememberFaceNeighbours(face:Face):void
        {
            if (_neighboursDirty)
                return;
            
            for each (var another:Face in _faces)
            {
                if (face == another)
                    continue;

                if ((face._v0 == another._v2) && (face._v1 == another._v1))
                {
                    _neighbour01[face] = another;
                    _neighbour12[another] = face;
                }

                if ((face._v0 == another._v0) && (face._v1 == another._v2))
                {
                    _neighbour01[face] = another;
                    _neighbour20[another] = face;
                }

                if ((face._v0 == another._v1) && (face._v1 == another._v0))
                {
                    _neighbour01[face] = another;
                    _neighbour01[another] = face;
                }
            
                if ((face._v1 == another._v2) && (face._v2 == another._v1))
                {
                    _neighbour12[face] = another;
                    _neighbour12[another] = face;
                }

                if ((face._v1 == another._v0) && (face._v2 == another._v2))
                {
                    _neighbour12[face] = another;
                    _neighbour20[another] = face;
                }

                if ((face._v1 == another._v1) && (face._v2 == another._v0))
                {
                    _neighbour12[face] = another;
                    _neighbour01[another] = face;
                }
            
                if ((face._v2 == another._v2) && (face._v0 == another._v1))
                {
                    _neighbour20[face] = another;
                    _neighbour12[another] = face;
                }

                if ((face._v2 == another._v0) && (face._v0 == another._v2))
                {
                    _neighbour20[face] = another;
                    _neighbour20[another] = face;
                }

                if ((face._v2 == another._v1) && (face._v0 == another._v0))
                {
                    _neighbour20[face] = another;
                    _neighbour01[another] = face;
                }
            }
        }
        
		internal var n01:Face;
		internal var n12:Face;
		internal var n20:Face;
		
        private function forgetFaceNeighbours(face:Face):void
        {
            if (_neighboursDirty)
                return;
            
            n01 = _neighbour01[face];
            if (n01 != null)
            {
                delete _neighbour01[face];
                if (_neighbour01[n01] == face)
                    delete _neighbour01[n01];
                if (_neighbour12[n01] == face)
                    delete _neighbour12[n01];
                if (_neighbour20[n01] == face)
                    delete _neighbour20[n01];
            }
            n12 = _neighbour12[face];
            if (n12 != null)
            {
                delete _neighbour12[face];
                if (_neighbour01[n12] == face)
                    delete _neighbour01[n12];
                if (_neighbour12[n12] == face)
                    delete _neighbour12[n12];
                if (_neighbour20[n12] == face)
                    delete _neighbour20[n12];
            }
            n20 = _neighbour20[face];
            if (n20 != null)
            {
                delete _neighbour20[face];
                if (_neighbour01[n20] == face)
                    delete _neighbour01[n20];
                if (_neighbour12[n20] == face)
                    delete _neighbour12[n20];
                if (_neighbour20[n20] == face)
                    delete _neighbour20[n20];
            }
        }

        private function onFaceVertexChange(event:MeshElementEvent):void
        {
            if (!_neighboursDirty)
            {
                var face:Face = event.element as Face;
                forgetFaceNeighbours(face);
                rememberFaceNeighbours(face);
            }

            _vertfacesDirty = true;
        }

        private function clear():void
        {
            for each (var face:Face in _faces.concat([]))
                removeFace(face);
        }

        public function invertFaces():void
        {
            for each (var face:Face in _faces)
                face.invert();
        }

        public function quarterFaces():void
        {
            var medians:Dictionary = new Dictionary();
            for each (var face:Face in _faces.concat([]))
            {
                var v0:Vertex = face.v0;
                var v1:Vertex = face.v1;
                var v2:Vertex = face.v2;

                if (medians[v0] == null)
                    medians[v0] = new Dictionary();
                if (medians[v1] == null)
                    medians[v1] = new Dictionary();
                if (medians[v2] == null)
                    medians[v2] = new Dictionary();

                var v01:Vertex = medians[v0][v1];
                if (v01 == null)
                {
                   v01 = Vertex.median(v0, v1);
                   medians[v0][v1] = v01;
                   medians[v1][v0] = v01;
                }
                var v12:Vertex = medians[v1][v2];
                if (v12 == null)
                {
                   v12 = Vertex.median(v1, v2);
                   medians[v1][v2] = v12;
                   medians[v2][v1] = v12;
                }
                var v20:Vertex = medians[v2][v0];
                if (v20 == null)
                {
                   v20 = Vertex.median(v2, v0);
                   medians[v2][v0] = v20;
                   medians[v0][v2] = v20;
                }
                var uv0:UV = face.uv0;
                var uv1:UV = face.uv1;
                var uv2:UV = face.uv2;
                var uv01:UV = UV.median(uv0, uv1);
                var uv12:UV = UV.median(uv1, uv2);
                var uv20:UV = UV.median(uv2, uv0);
                var material:ITriangleMaterial = face.material;
                removeFace(face);
                addFace(new Face(v0, v01, v20, material, uv0, uv01, uv20));
                addFace(new Face(v01, v1, v12, material, uv01, uv1, uv12));
                addFace(new Face(v20, v12, v2, material, uv20, uv12, uv2));
                addFace(new Face(v12, v20, v01, material, uv12, uv20, uv01));
            }
        }

        public function movePivot(dx:Number, dy:Number, dz:Number):void
        {
            var nd:Boolean = _neighboursDirty;
            _neighboursDirty = true;
            for each (var vertex:Vertex in vertices)
            {
                vertex.x += dx;
                vertex.y += dy;
                vertex.z += dz;
            }
            x -= dx;
            y -= dy;
            z -= dz;
            _neighboursDirty = nd;
        }

        internal var _debugboundingbox:WireCube;
		internal var tri:DrawTriangle;
        internal var transparent:ITriangleMaterial;
        internal var backmat:ITriangleMaterial;
        internal var backface:Boolean;
        
        internal var vt:ScreenVertex;
        internal var uvt:UV;
        
        override public function primitives(projection:Projection, consumer:IPrimitiveConsumer, session:RenderSession):void
        {
        	super.primitives(projection, consumer, session);
        	
        	_dtStore = _dtStore.concat(_dtActive);
        	_dtActive = new Array();
        	
            if (outline != null)
                if (_neighboursDirty)
                    findNeighbours();

            if (debugbb)
            {
                if (_debugboundingbox == null)
                    _debugboundingbox = new WireCube({material:"#white"});
                _debugboundingbox.v000.x = minX;
                _debugboundingbox.v001.x = minX;
                _debugboundingbox.v010.x = minX;
                _debugboundingbox.v011.x = minX;
                _debugboundingbox.v100.x = maxX;
                _debugboundingbox.v101.x = maxX;
                _debugboundingbox.v110.x = maxX;
                _debugboundingbox.v111.x = maxX;
                _debugboundingbox.v000.y = minY;
                _debugboundingbox.v001.y = minY;
                _debugboundingbox.v010.y = maxY;
                _debugboundingbox.v011.y = maxY;
                _debugboundingbox.v100.y = minY;
                _debugboundingbox.v101.y = minY;
                _debugboundingbox.v110.y = maxY;
                _debugboundingbox.v111.y = maxY;
                _debugboundingbox.v000.z = minZ;
                _debugboundingbox.v001.z = maxZ;
                _debugboundingbox.v010.z = minZ;
                _debugboundingbox.v011.z = maxZ;
                _debugboundingbox.v100.z = minZ;
                _debugboundingbox.v101.z = maxZ;
                _debugboundingbox.v110.z = minZ;
                _debugboundingbox.v111.z = maxZ;
                if (_faces.length > 0)
                    _debugboundingbox.primitives(projection, consumer, session);
            }
            
            transparent = TransparentMaterial.INSTANCE;
            backmat = back || material;
			
            for each (var face:Face in _faces)
            {
                if (!face._visible)
                    continue;
				
				//project each Vertex to a ScreenVertex
				tri = face._dt;
                tri.v0 = face._v0.project(projection);
                tri.v1 = face._v1.project(projection);
                tri.v2 = face._v2.project(projection);
				
				//check each ScreenVertex is visible
                if (!tri.v0.visible)
                    continue;

                if (!tri.v1.visible)
                    continue;

                if (!tri.v2.visible)
                    continue;
				
				//calculate DrawTriangle properties
                tri.calc();
				
				//check triangle is not behind the camera
                if (tri.maxZ < 0)
                    continue;
				
				//determine if triangle is facing towards or away from camera
                backface = tri.area < 0;
				
				//if triangle facing away, check for backface material
                if (backface) {
                    if (!bothsides)
                        continue;
                    tri.material = face._back;
                } else
                    tri.material = face._material;
				
				//determine the material of the triangle
                if (tri.material == null)
                    if (backface)
                        tri.material = backmat;
                    else
                        tri.material = material;
				
				//do not draw material if visible is false
                if (tri.material != null)
                    if (!tri.material.visible)
                        tri.material = null;
				
				//if there is no material and no outline, continue
                if (outline == null)
                    if (tri.material == null)
                        continue;
				
                if (pushback)
                    tri.screenZ = tri.maxZ;

                if (pushfront)
                    tri.screenZ = tri.minZ;
				
				
				//swap ScreenVerticies if triangle facing away from camera
                if (backface) {
                    // Make cleaner
                    vt = tri.v1;
                    tri.v1 = tri.v2;
                    tri.v2 = vt;
					
					//pass accross uv values
	                tri.uv0 = face._uv0;
	                tri.uv1 = face._uv2;
	                tri.uv2 = face._uv1;

                    tri.area = -tri.area;
                } else {
					//pass accross uv values
	                tri.uv0 = face._uv0;
	                tri.uv1 = face._uv1;
	                tri.uv2 = face._uv2;
                }
                
                //check if face swapped direction
                if (tri.backface != backface && tri.material is IUVMaterial) {
                	tri.backface = backface;
                	tri.texturemapping = null;
                }
                
                if (outline != null && !backface)
                {
                    n01 = _neighbour01[face];
                    if (n01 == null || n01.front(projection) <= 0)
                    	consumer.primitive(createDrawSegment(outline, projection, tri.v0, tri.v1));

                    n12 = _neighbour12[face];
                    if (n12 == null || n12.front(projection) <= 0)
                    	consumer.primitive(createDrawSegment(outline, projection, tri.v1, tri.v2));

                    n20 = _neighbour20[face];
                    if (n20 == null || n20.front(projection) <= 0)
                    	consumer.primitive(createDrawSegment(outline, projection, tri.v2, tri.v0));

                    if (tri.material == null)
                    	continue;
                }
                tri.projection = projection;
                consumer.primitive(tri);
            }
        }
        
		protected var _dtStore:Array = new Array();
        protected var _dtActive:Array = new Array();
        
		public function createDrawTriangle(material:ITriangleMaterial, projection:Projection, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex, uv0:UV, uv1:UV, uv2:UV):DrawTriangle
		{
			
			if (_dtStore.length) {
            	tri = _dtStore.pop();
            	tri.texturemapping = null;
   			} else {
            	_dtActive.push(tri = new DrawTriangle());
	            tri.source = this;
		        tri.create = createDrawTriangle;
            }
            tri.material = material;
            tri.projection = projection;
            tri.v0 = v0;
            tri.v1 = v1;
            tri.v2 = v2;
            tri.uv0 = uv0;
            tri.uv1 = uv1;
            tri.uv2 = uv2;
            tri.calc();
            return tri;
		}
		
        public override function clone(object:* = null):*
        {
            var mesh:Mesh = object || new Mesh();
            super.clone(mesh);
            mesh.material = material;
            mesh.outline = outline;
            mesh.back = back;
            mesh.bothsides = bothsides;
            mesh.debugbb = debugbb;

            var clonedvertices:Dictionary = new Dictionary();
            var clonevertex:Function = function(vertex:Vertex):Vertex
            {
                var result:Vertex = clonedvertices[vertex];
                if (result == null)
                {
                    result = new Vertex(vertex._x, vertex._y, vertex._z);
                    result.extra = (vertex.extra is IClonable) ? (vertex.extra as IClonable).clone() : vertex.extra;
                    clonedvertices[vertex] = result;
                }
                return result;
            }

            var cloneduvs:Dictionary = new Dictionary();
            var cloneuv:Function = function(uv:UV):UV
            {
                if (uv == null)
                    return null;

                var result:UV = cloneduvs[uv];
                if (result == null)
                {
                    result = new UV(uv._u, uv._v);
                    cloneduvs[uv] = result;
                }
                return result;
            }
            
            for each (var face:Face in _faces)
                mesh.addFace(new Face(clonevertex(face._v0), clonevertex(face._v1), clonevertex(face._v2), face.material, cloneuv(face._uv0), cloneuv(face._uv1), cloneuv(face._uv2)));

            return mesh;
        }

        public function asAS3Class(classname:String = null, packagename:String = ""):String
        {
            classname = classname || name || "MyAway3DObject";
            var source:String = "package "+packagename+"\n{\n\timport away3d.core.mesh.*;\n\n\tpublic class "+classname+" extends Mesh\n\t{\n";
            source += "\t\tprivate var varr:Array = [];\n";
            source += "\t\tprivate var uvarr:Array = [];\n\n";
            source += "\t\tprivate function v(x:Number,y:Number,z:Number):void\n\t\t{\n";
            source += "\t\t\tvarr.push(new Vertex(x,y,z));\n\t\t}\n\n";
            source += "\t\tprivate function uv(u:Number,v:Number):void\n\t\t{\n";
            source += "\t\t\tuvarr.push(new UV(u,v));\n\t\t}\n\n";
            source += "\t\tprivate function f(vn0:int, vn1:int, vn2:int, uvn0:int, uvn1:int, uvn2:int):void\n\t\t{\n";
            source += "\t\t\taddFace(new Face(varr[vn0],varr[vn1],varr[vn2], null, uvarr[uvn0],uvarr[uvn1],uvarr[uvn2]));\n\t\t}\n\n";
            source += "\t\tpublic function "+classname+"(init:Object = null)\n\t\t{\n\t\t\tsuper(init);\n\t\t\tbuild();\n\t\t}\n\n";
            source += "\t\tprivate function build():void\n\t\t{\n";
            
            var refvertices:Dictionary = new Dictionary();
            var verticeslist:Array = [];
            var remembervertex:Function = function(vertex:Vertex):void
            {
                if (refvertices[vertex] == null)
                {
                    refvertices[vertex] = verticeslist.length;
                    verticeslist.push(vertex);
                }
            }

            var refuvs:Dictionary = new Dictionary();
            var uvslist:Array = [];
            var rememberuv:Function = function(uv:UV):void
            {
                if (uv == null)
                    return;

                if (refuvs[uv] == null)
                {
                    refuvs[uv] = uvslist.length;
                    uvslist.push(uv);
                }
            }

            for each (var face:Face in _faces)
            {
                remembervertex(face._v0);
                remembervertex(face._v1);
                remembervertex(face._v2);
                rememberuv(face._uv0);
                rememberuv(face._uv1);
                rememberuv(face._uv2);
            }

            for each (var v:Vertex in verticeslist)
                source += "\t\t\tv("+v._x+","+v._y+","+v._z+");\n";

            for each (var uv:UV in uvslist)
                source += "\t\t\tuv("+uv._u+","+uv._v+");\n";

            for each (var f:Face in _faces)
                source += "\t\t\tf("+refvertices[f._v0]+","+refvertices[f._v1]+","+refvertices[f._v2]+","+refuvs[f._uv0]+","+refuvs[f._uv1]+","+refuvs[f._uv2]+");\n"

            source += "\t\t}\n\t}\n}";
            return source;
        }

        public function asXML():XML
        {
            var result:XML = <mesh></mesh>;

            var refvertices:Dictionary = new Dictionary();
            var verticeslist:Array = [];
            var remembervertex:Function = function(vertex:Vertex):void
            {
                if (refvertices[vertex] == null)
                {
                    refvertices[vertex] = verticeslist.length;
                    verticeslist.push(vertex);
                }
            }

            var refuvs:Dictionary = new Dictionary();
            var uvslist:Array = [];
            var rememberuv:Function = function(uv:UV):void
            {
                if (uv == null)
                    return;

                if (refuvs[uv] == null)
                {
                    refuvs[uv] = uvslist.length;
                    uvslist.push(uv);
                }
            }

            for each (var face:Face in _faces)
            {
                remembervertex(face._v0);
                remembervertex(face._v1);
                remembervertex(face._v2);
                rememberuv(face._uv0);
                rememberuv(face._uv1);
                rememberuv(face._uv2);
            }

            var vn:int = 0;
            for each (var v:Vertex in verticeslist)
            {
                result.appendChild(<vertex id={vn} x={v._x} y={v._y} z={v._z}/>);
                vn++;
            }

            var uvn:int = 0;
            for each (var uv:UV in uvslist)
            {
                result.appendChild(<uv id={uvn} u={uv._u} v={uv._v}/>);
                uvn++;
            }

            for each (var f:Face in _faces)
                result.appendChild(<face v0={refvertices[f._v0]} v1={refvertices[f._v1]} v2={refvertices[f._v2]} uv0={refuvs[f._uv0]} uv1={refuvs[f._uv1]} uv2={refuvs[f._uv2]}/>);

            return result;
        }

    }
}
