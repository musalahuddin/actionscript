import flash.geom.Point;
import threed.geom.Vertex;

class threed.utility.Calc{
	
	/**
	 * computes and return xy intercepts between two lines
	 */
	public static function xy_Intercept(ptA,ptB,ptC,ptD){
		
		var intx:Number;
		var inty:Number;
		var m:Number, m1:Number, m2:Number;
		var b:Number, b1:Number, b2:Number;
		var intercept:Object; 

		if((ptA.x == ptB.x) && (ptC.x == ptD.x))
		{
			intx = ptA.x;
			
			inty = ptA.y;
		}
		else if((ptA.y == ptB.y) && (ptC.y == ptD.y))
		{
			intx = ptA.x;
		
			inty = ptA.y;
		}
		else if((ptA.x == ptB.x)){
		
			intx = ptA.x; 
			
			m = (ptC.y - ptD.y) / (ptC.x - ptD.x );

			b = ptC.y - (m * ptC.x);
			
			inty = (m*intx) + b;
			
		}
		else if ((ptC.x == ptD.x)){
		
			intx = ptC.x; 
			
			m = (ptA.y - ptB.y) / (ptA.x - ptB.x);
			// finding b
			b = ptA.y - (m * ptA.x);
			
			inty = (m*intx) + b;
			
		}
		else{
		
			m1 = (ptA.y - ptB.y) / (ptA.x - ptB.x);
			// finding b
			b1 = ptA.y - (m1 * ptA.x);

			m2 = (ptC.y - ptD.y) / (ptC.x - ptD.x );

			b2 = ptC.y - (m2 * ptC.x);
			
			intx = (b2 - b1)/(m1 - m2); 
			
			inty = (m1*intx) + b1;
		}
		
		intercept = new Object({xIntercept:intx, yIntercept:inty});
		return intercept;
	}

	/**
	 * Converts pixels to inches 
	 * @param  pixels 
	 * @return inches
	 */
	public static function pixelsToInches(pixels){

		var inches = (pixels / (_level0.onefoot*_level0.scalePercentage*_level0.onefootScale)) * 12;

		return inches;
	}


	/**
	 * [directionalVector description]
	 * @param  vertex1 [description]
	 * @param  vertex2 [description]
	 * @return         Vertex
	 */
	public static function directionalVector(vertex1:Vertex, vertex2:Vertex):Vertex{

		var x:Number, y:Number, z:Number;

		x = vertex2.x-vertex1.x;
		y = vertex2.y-vertex1.y;
		z = vertex2.z-vertex1.z;

		return new Vertex(x,y,z);
	}


	public static function crossProduct(d1:Vertex, d2:Vertex):Vertex{
		
		var x:Number, y:Number, z:Number;

		x = (d1.y * d2.z) - (d1.z * d2.y);
		y = (d1.z * d2.x) - (d1.x * d2.z);
		z = (d1.x * d2.y) - (d1.y * d2.x);

		return new Vertex(x,y,z);
	}

	public static function normal(cross:Vertex, dist:Number):Vertex{

		var x:Number, y:Number, z:Number;

		x = cross.x/dist;
		y = cross.y/dist;
		z = cross.z/dist;

		return new Vertex(x,y,z);

	}

	public static function generateRandomString(strlen:Number):String{
		var randomChar:String = "";
		for (var i:Number = 0; i < strlen; i++){
			randomChar += Math.floor(Math.random() * 16).toString(16);
		}
		return randomChar;
	}

	/**
	 * computes uv mapping
	 * @param  uMin       
	 * @param  vMin       
	 * @param  TextureHeight [in feet]
	 * @param  TextureWidth  [in feet]
	 * @param  vertex 
	 * @param  zAxis 		 [flag if set to true use zAxis else use yAxis]
	 * @return Vertex
	 */
	public static function uv(uMin:Number, vMin:Number, textureWidth:Number, textureHeight:Number, vertex:Vertex, zAxis:Boolean):Vertex{

		var u:Number, v:Number, w:Number;

		if(zAxis == true){
		
			u = (Math.abs(uMin-vertex.x)/12)/textureWidth;
			//v = (((vMin-vertex.z)/12)/textureHeight)+textureHeight;
			//v = ((vMin-vertex.z)/12)/textureHeight;
			v = (Math.abs(vMin-vertex.z)/12)/textureHeight;
			w = 0.5;
		}
		else{
			
			u = (Math.abs(uMin-vertex.x)/12)/textureWidth;
			//v = (((vMin-vertex.y)/12)/textureHeight)+textureHeight;
			v = ((vMin-vertex.y)/12)/textureHeight;
			w = 0.5;

		}

		return new Vertex(u,v,w);

	}

	/**
	 * computes uv mapping
	 * @param  uMin       
	 * @param  vMin       
	 * @param  TextureHeight [in feet]
	 * @param  TextureWidth  [in feet]
	 * @param  vertex 
	 * @param  zAxis 		 [flag if set to true use zAxis else use yAxis]
	 * @return Vertex
	 */
	public static function doorsOrWindowsUV(uMin:Number, vMin:Number, textureWidth:Number, textureHeight:Number, vertex:Vertex, zAxis:Boolean):Vertex{

		var u:Number, v:Number, w:Number;

		if(zAxis == true){
		
			u = (Math.abs(uMin-vertex.z)/12)/textureWidth;
			//v = (((vMin-vertex.z)/12)/textureHeight)+textureHeight;
			//v = ((vMin-vertex.z)/12)/textureHeight;
			v = (Math.abs(vMin-vertex.y)/12)/textureHeight;
			w = 0.5;
		}
		else{
			
			u = (Math.abs(uMin-vertex.x)/12)/textureWidth;
			//v = (((vMin-vertex.z)/12)/textureHeight)+textureHeight;
			//v = ((vMin-vertex.z)/12)/textureHeight;
			v = (Math.abs(vMin-vertex.y)/12)/textureHeight;
			w = 0.5;

		}

		return new Vertex(u,v,w);

	}

	public static function angle(x1:Number, y1:Number, x2:Number, y2:Number):Number
	{
	    var dx:Number = x2 - x1;
	    var dy:Number = y2 - y1;
	    return Math.atan2(dy,dx)*(180/Math.PI);
	}

	public static function distance(point1:Point, point2:Point):Number{

		var xDist:Number = point2.x-point1.x;
		var yDist:Number = point2.y-point1.y;

		return Math.sqrt((xDist*xDist)+(yDist*yDist));

	}

}