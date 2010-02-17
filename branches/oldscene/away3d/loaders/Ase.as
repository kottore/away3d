package away3d.loaders
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;

    import flash.display.BitmapData;

    /** Ase file format loader */
    public class Ase
    {
        private var mesh:Mesh3D;
        private var scaling:Number;

        public function Ase(data:String, material:IMaterial, init:Object = null)
        {
            init = Init.parse(init);

            scaling = init.getNumber("scaling", 1) * 100;

            mesh = new Mesh3D(material, init);

            parseAse(data);
        }

        public static function parse(data:*, material:* = null, init:Object = null):Mesh3D
        {
            var ase:Ase = new Ase(Cast.string(data), Cast.material(material), init);
            return ase.mesh;
        }
    
        private function parseAse(data:String):void
        {
            var lines:Array = data.split('\r\n');
            var uvs:Array = [];
    
            while (lines.length > 0)
            {
                var line:String = lines.shift();
                
                line = line.substr(line.indexOf('*') + 1);
    
                if (line.indexOf('}') >= 0)
                    continue;
    
                var chunk:String = line.substr(0, line.indexOf(' '));
    
                switch (chunk)
                {
                    case 'MESH_VERTEX_LIST':
                        while (true)
                        {
                            var vertexline:String = lines.shift();
                            
                            if (vertexline.indexOf('}') >= 0)
                                break;
                                
                            vertexline = vertexline.substr(vertexline.indexOf('*') + 1);
    
                            var mvl:Array = vertexline.split('\t');
    
                            // Swapped Y and Z
                            var x:Number = parseFloat(mvl[1]) * scaling;
                            var z:Number = parseFloat(mvl[2]) * scaling; 
                            var y:Number = parseFloat(mvl[3]) * scaling;
    
                            mesh.vertices.push(new Vertex3D(x, y, z));
                        }
                        break;
                    case 'MESH_FACE_LIST':
                        while (true)
                        {
                            var faceline:String = lines.shift();
                            
                            if (faceline.indexOf('}') >= 0)
                                break;
                                
                            faceline = faceline.substr(faceline.indexOf('*') + 1);
    
                            var mfl:String = faceline.split('\t')[0]; // ignore: [MESH_SMOOTHING,MESH_MTLID]
                            var drc:Array = mfl.split( ':' ); // separate here
    
                            var con:String;
                            con = drc[2]
                            var a:Vertex3D = mesh.vertices[parseInt(con.substr(0, con.lastIndexOf(' ')))];
    
                            con = drc[3];
                            var b:Vertex3D = mesh.vertices[parseInt(con.substr(0, con.lastIndexOf(' ')))];
    
                            con = drc[4];
                            var c:Vertex3D = mesh.vertices[parseInt(con.substr(0, con.lastIndexOf(' ')))];
    
                            mesh.addFace3D(new Face3D(a, b, c));
                        }
                        break;
    
                    case 'MESH_TVERTLIST':
                        while (true)
                        {
                            var textureline:String = lines.shift();
                            
                            if (textureline.indexOf('}') >= 0)
                                break;

                            textureline = textureline.substr(textureline.indexOf('*') + 1);

                            var mtvl:Array = textureline.split('\t');
                            uvs.push(new NumberUV(parseFloat(mtvl[1]), parseFloat(mtvl[2])));
                        }
                        break;
                    case 'MESH_TFACELIST':
                        var num: int = 0;
    
                        while (true)
                        {
                            var mapline:String = lines.shift();
                            
                            if (mapline.indexOf('}') >= 0)
                                break;

                            mapline = mapline.substr(mapline.indexOf('*') + 1);

                            var mtfl:Array = mapline.split('\t');
    
                            var face:Face3D = mesh.faces[num];
                            face.uv0 = uvs[parseInt(mtfl[1])];
                            face.uv1 = uvs[parseInt(mtfl[2])];
                            face.uv2 = uvs[parseInt(mtfl[3])];
                            num++;
    
                        }
                        break;
                }
            }
        }
    }
}