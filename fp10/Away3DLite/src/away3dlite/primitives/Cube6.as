﻿package away3dlite.primitives{	import away3dlite.arcane;	import away3dlite.materials.*;    	use namespace arcane;	    /**    * Creates a 3d Cube primitive.    */     public class Cube6 extends AbstractPrimitive    {	    	private var _width:Number = 100;    	private var _height:Number = 100;    	private var _depth:Number = 100;    	private var _segmentsW:int = 1;    	private var _segmentsH:int = 1;    	private var _segmentsD:int = 1;    	private var _pixelBorder:int = 1;				/**		 * @inheritDoc		 */    	protected override function buildPrimitive():void    	{    		super.buildPrimitive();    		    		var i:int;            var j:int;                        var udelta:Number = _pixelBorder/600;            var vdelta:Number = _pixelBorder/400;                        var a:int;            var b:int;            var c:int;            var d:int;			var inc:int = 0;			            if (material is BitmapMaterial) {                var bMaterial:BitmapMaterial = material as BitmapMaterial;                udelta = _pixelBorder/bMaterial.width;                vdelta = _pixelBorder/bMaterial.height;            }                    		for (i = 0; i <= _segmentsW; i++) {    			for (j = 0; j <= _segmentsH; j++) {    				    				//create front/back		    		_vertices.push(_width/2 - i*_width/_segmentsW, _height/2 - j*_height/_segmentsH, -_depth/2);		            _vertices.push(_width/2 - i*_width/_segmentsW, _height/2 - j*_height/_segmentsH, _depth/2);		        						_uvtData.push(1/3 - udelta - i*(1 - 6*udelta)/(3*_segmentsW), 1 - vdelta - j*(1 - 4*vdelta)/(2*_segmentsH), 1);					_uvtData.push(1/3 + udelta + i*(1 - 6*udelta)/(3*_segmentsW), 1/2 - vdelta - j*(1 - 4*vdelta)/(2*_segmentsH), 1);										if (i && j) {						a = 2*((_segmentsW + 1)*j + i);	                    b = 2*((_segmentsW + 1)*j + i - 1);	                    c = 2*((_segmentsW + 1)*(j - 1) + i - 1);	                    d = 2*((_segmentsW + 1)*(j - 1) + i);	                    	                    _indices.push(c,d,b);	                    _indices.push(d,a,b);	                    _indices.push(c+1,b+1,d+1);	                    _indices.push(d+1,b+1,a+1);					}    			}    		}    		    		inc += 2*(_segmentsW + 1)*(_segmentsH + 1);    		    		for (i = 0; i <= _segmentsW; i++) {    			for (j = 0; j <= _segmentsD; j++) {    				    				//create top/bottom		    		_vertices.push(_width/2 - i*_width/_segmentsW, _height/2, -_depth/2 + j*_depth/_segmentsD);		            _vertices.push(_width/2 - i*_width/_segmentsW, -_height/2, -_depth/2 + j*_depth/_segmentsD);		                				_uvtData.push(2/3 + udelta + j*(1 - 6*udelta)/(3*_segmentsW), 1/2 + vdelta + i*(1 - 4*vdelta)/(2*_segmentsD), 1);    				_uvtData.push(1/3 + udelta + j*(1 - 6*udelta)/(3*_segmentsW), 1 - vdelta - i*(1 - 4*vdelta)/(2*_segmentsD), 1);    				    				if (i && j) {						a = inc + 2*((_segmentsW + 1)*j + i);	                    b = inc + 2*((_segmentsW + 1)*j + i - 1);	                    c = inc + 2*((_segmentsW + 1)*(j - 1) + i - 1);	                    d = inc + 2*((_segmentsW + 1)*(j - 1) + i);	                    	                    _indices.push(c,b,d);	                    _indices.push(b,a,d);	                    _indices.push(c+1,d+1,b+1);	                    _indices.push(b+1,d+1,a+1);					}    			}    		}    		    		inc += 2*(_segmentsW + 1)*(_segmentsD + 1);    		    		for (i = 0; i <= _segmentsH; i++) {    			for (j = 0; j <= _segmentsD; j++) {    				    				//create left/right    				_vertices.push(_width/2, _height/2 - i*_height/_segmentsH, -_depth/2 + j*_depth/_segmentsD);		            _vertices.push(-_width/2, _height/2 - i*_height/_segmentsH, -_depth/2 + j*_depth/_segmentsD);		                				_uvtData.push(udelta + j*(1 - 6*udelta)/(3*_segmentsH), 1/2 - vdelta - i*(1 - 4*vdelta)/(2*_segmentsD), 1);    				_uvtData.push(1 - udelta - j*(1 - 6*udelta)/(3*_segmentsH), 1/2 - vdelta - i*(1 - 4*vdelta)/(2*_segmentsD), 1);    				    				if (i && j) {						a = inc + 2*((_segmentsH + 1)*j + i);	                    b = inc + 2*((_segmentsH + 1)*j + i - 1);	                    c = inc + 2*((_segmentsH + 1)*(j - 1) + i - 1);	                    d = inc + 2*((_segmentsH + 1)*(j - 1) + i);	                    	                    _indices.push(c,d,b);	                    _indices.push(d,a,b);	                    _indices.push(c+1,b+1,d+1);	                    _indices.push(d+1,b+1,a+1);					}    			}    		}    	}    	    	/**    	 * Defines the width of the cube. Defaults to 100.    	 */    	public override function get width():Number    	{    		return _width;    	}    	    	public override function set width(val:Number):void    	{    		if (_width == val)    			return;    		    		_width = val;    		_primitiveDirty = true;    	}    	    	/**    	 * Defines the height of the cube. Defaults to 100.    	 */    	public override function get height():Number    	{    		return _height;    	}    	    	public override function set height(val:Number):void    	{    		if (_height == val)    			return;    		    		_height = val;    		_primitiveDirty = true;    	}    	    	/**    	 * Defines the depth of the cube. Defaults to 100.    	 */    	public function get depth():Number    	{    		return _depth;    	}    	    	public function set depth(val:Number):void    	{    		if (_depth == val)    			return;    		    		_depth = val;    		_primitiveDirty = true;    	}    	    	/**    	 * Defines the number of horizontal segments that make up the cube. Defaults to 1.    	 */    	public function get segmentsW():Number    	{    		return _segmentsW;    	}    	    	public function set segmentsW(val:Number):void    	{    		if (_segmentsW == val)    			return;    		    		_segmentsW = val;    		_primitiveDirty = true;    	}    	    	/**    	 * Defines the number of vertical segments that make up the cube. Defaults to 1.    	 */    	public function get segmentsH():Number    	{    		return _segmentsH;    	}    	    	public function set segmentsH(val:Number):void    	{    		if (_segmentsH == val)    			return;    		    		_segmentsH = val;    		_primitiveDirty = true;    	}    	    	/**    	 * Defines the number of depth segments that make up the cube. Defaults to 1.    	 */    	public function get segmentsD():Number    	{    		return _segmentsD;    	}    	    	public function set segmentsD(val:Number):void    	{    		if (_segmentsD == val)    			return;    		    		_segmentsD = val;    		_primitiveDirty = true;    	}    	    	/**    	 * Defines the texture mapping border in pixels used around each face of the cube. Defaults to 1    	 */    	public function get pixelBorder():int    	{    		return _pixelBorder;    	}    	    	public function set pixelBorder(val:int):void    	{    		if (_pixelBorder == val)    			return;    		    		_pixelBorder = val;    		_primitiveDirty = true;    	}    			/**		 * Creates a new <code>Cube</code> object.		 * 		 * @param	width		Defines the width of the cube.		 * @param	height		Defines the height of the cube.		 * @param	depth		Defines the depth of the cube.		 * @param	segmentsW	Defines the number of horizontal segments that make up the cube.		 * @param	segmentsH	Defines the number of vertical segments that make up the cube.		 * @param	segmentsD	Defines the number of depth segments that make up the cube.		 * @param	pixelBorder	Defines the texture mapping border in pixels used around each face of the cube.		 */        public function Cube6(width:Number = 100, height:Number = 100, depth:Number = 100, segmentsW:int = 1, segmentsH:int = 1, segmentsD:int = 1, pixelBorder:int = 1)        {            super();						_width = width;			_height = height;			_depth = depth;			_segmentsW = segmentsW;			_segmentsH = segmentsH;			_segmentsD = segmentsD;			_pixelBorder = pixelBorder;						type = "Cube";			url = "primitive";        }    } }