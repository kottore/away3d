﻿package away3d.core.material{	import flash.display.BitmapData;	import flash.display.IBitmapDrawable;	import flash.geom.Rectangle;	import flash.geom.Point;	import flash.geom.Matrix;	import flash.geom.ColorTransform;	//	public class BitmapGraphics  	//implements IGraphics	{		protected static var _rect:Rectangle = new Rectangle(0,0,0,1);		protected static var o:Object= new Object();		protected static var pt:Point= new Point(0,0);		protected static var scratch_bmd:BitmapData = new BitmapData(2798, 2798, false, 0x00FFFFFF);  		//public function BitmapGraphics()		//{ 		 		//} 		public static function renderFilledTriangle(dest_bmd:BitmapData,x0:int,y0:int,x1:int,y1:int,x2:int,y2:int,color:Number = 0xFFCCCCCC):void		{ 			o.col=color;			o.rct=_rect;						o.dest_bmd = dest_bmd;			o.b=false; 			if (x0<=0) {				x0 = 1;			}			if (x1<=0) {				x1 = 1;			}			if (x2<=0) {				x2 = 1;			}			 			scanL(o,x0,y0,x1,y1);			scanL(o,x1,y1,x2,y2);			scanL(o,x2,y2,x0,y0);		}				public static function renderBitmapTriangle(dest_bmd:BitmapData,source_bmd:BitmapData,x0:int,y0:int,x1:int,y1:int,x2:int,y2:int,mat:Matrix,ct:ColorTransform=null, tmprect:Rectangle = null):void		{			pt.x = tmprect.x;			pt.y = tmprect.y;			scratch_bmd.draw(source_bmd, mat, ct ,"normal", tmprect, false);			var o:Object= new Object();			o.colortransform = ct;			o.dest_bmd = dest_bmd;			o.source_bmd = source_bmd;			o.ct = ct;			o.mat = mat;			o.tmprect = tmprect;			o.rct = _rect;			o.b=true;						if (x0<=0) {				x0 = 1;			}			if (x1<=0) {				x1 = 1;			}			if (x2<=0) {				x2 = 1;			}			 			scanL(o, x0, y0, x1, y1);			scanL(o, x1, y1, x2, y2);			scanL(o, x2, y2, x0, y0);			 		 }				public static function traceLine(o:Object,  x:int,y:int):void {			if (o[y]) {				if (o[y] > x) {					o.rct.width = o[y] - x;					o.rct.x= x;					o.rct.y= y;					pt.x = o.rct.x;					pt.y = o.rct.y;					if(o.b){						o.dest_bmd.copyPixels(scratch_bmd, o.rct, pt);					} else {						o.dest_bmd.fillRect(o.rct,o.col);					}				} else {					o.rct.width = x - o[y];					o.rct.x= o[y];					o.rct.y= y;					pt.x = o[y];					pt.y = y;					if(o.b){						o.dest_bmd.copyPixels(scratch_bmd, o.rct, pt); 					} else {						o.dest_bmd.fillRect(o.rct,o.col);					}				}			} else {				o[y]=x;			}		}						 public static function scanL(o:Object, x0:int,y0:int,x1:int,y1:int):void		 {				var steep:Boolean= (y1-y0)*(y1-y0) > (x1-x0)*(x1-x0);								if (steep){					var swap:int=x0; 					x0=y0; 					y0=swap;					swap=x1;					x1=y1;					y1=swap;				}				if (x0>x1){					x0^=x1; x1^=x0; x0^=x1;					y0^=y1; y1^=y0; y0^=y1;				}				var deltax:int = x1 - x0;				var deltay:int = Math.abs(y1 - y0);				var error:int = 0;				var y:int = y0;							var ystep:int = y0<y1 ? 1 : -1;				var x:int=x0;				var xend:int=x1-(deltax>>1);				var fx:int=x1;				var fy:int=y1; 				var px:int=0;				o.rct.x = 0;				o.rct.y = 0;				o.rct.width = 0;										while (x++<=xend){					if (steep){						traceLine(o, y,x );												if (fx!=x1 && fx!=xend){							traceLine(o,fy,fx+1 );						}					}					error += deltay;					if ((error<<1) >= deltax){						if (!steep) {							traceLine(o,x-px+1,y );							if (fx!=xend) {								traceLine(o,fx+1,fy );							}						}						px=0;						y+=ystep;						fy-=ystep;						error -= deltax; 					}					px++;					fx--;				}				if (!steep){					traceLine(o, x-px+1,y );				}								}		public static function drawLine(dest_bmd:BitmapData,x1:int,y1:int,x2:int,y2:int,color:Number=0x00):void		{			var error:Number;			var dx:Number;			var dy:Number;			if (x1 > x2) {				var tmp:Number = x1;				x1 = x2;				x2 = tmp;				tmp = y1;				y1 = y2;				y2 = tmp;			}			dx = x2 - x1;			dy = y2 - y1;			var yi:Number = 1;			if (dx < dy) {				x1 ^= x2;				x2 ^= x1;				x1 ^= x2;				y1 ^= y2;				y2 ^= y1;				y1 ^= y2;			}			if (dy < 0) {				dy = -dy;				yi = -yi;			}			if (dy > dx) {				error = -(dy >> 1);				for (; y2 < y1; y2++) {				dest_bmd.setPixel32(x2, y2, color);					error += dx;					if (error > 0) {						x2 += yi;						error -= dy;					}				}			} else {				error = -(dx >> 1);				for (; x1 < x2; x1++) {					dest_bmd.setPixel32(x1, y1, color);					error += dy;				if (error > 0) {					y1 += yi;						error -= dx;					}				}			}		}	}}