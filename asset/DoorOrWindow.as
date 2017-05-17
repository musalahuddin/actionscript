import threed.geom.Vertex;
import threed.event.Broadcaster;
import threed.asset.Model;
import threed.utility.Calc;

class threed.asset.DoorOrWindow extends Model{

	/**
	 * @var Vertex
	 */
	public var vertex1:Vertex;

	/**
	 * @var Vertex
	 */
	public var vertex2:Vertex;

	/**
	 * @var Vertex
	 */
	public var vertex3:Vertex;

	/**
	 * @var Vertex
	 */
	public var vertex4:Vertex;


	/**
	 * @var Number
	 */
	public var height:Number;

	/**
	 * @var Number
	 */
	public var vdist:Number;

	/**
	 * @var String
	 */
	public var _type:String; 


	/**
	 * @var Array<Vertex>
	 * wall vertices
	 */
	public var vertices:Array;

	/**
	 * @var Number
	 */
	public var line:Number;

	/**
	 * @var Number
	 */
	public var point:Number;

	/**
	 * @var String
	 */
	public var dir:String;

	/**
	 * @constructor
	 * @param v1        vertex1
	 * @param v2        vertex2
	 * @param v3        vertex3
	 * @param v4        vertex4
	 * @param height    doorOrWindow height
	 * @param vdist     doorOrWindow sill height
	 * @param type      doorOrWindow type ("door","window")
	 */
	function DoorOrWindow(broadcaster:Broadcaster, v1:Vertex, v2:Vertex, v3:Vertex, v4:Vertex, height:Number, vdist:Number, type:String, line:Number, point:Number, dir:String){

		super(broadcaster);
		this.vertex1 = v1; 
		this.vertex2 = v2;
		this.vertex3 = v3; 
		this.vertex4 = v4;
		this.height = height;
		this.vdist = vdist;
		this._type = type;
		this.vertices = generateVertices();
		this.line = line;
		this.point = point;
		this.dir = dir;
		// base class fields
		//this.fileName = new String(this._type+"_"+(Math.round(Math.random()*99999999))+".obj");
		this.fileName = new String(this._type+"_"+Calc.generateRandomString(10)+".obj");
		this.projectId = 35498;
		this.OBJData = generateOBJData(0,0,0);
		this.OBJPath = '../objs/'+fileName;
		this.removeOBJ = true;
	}

	public function generateVertices(){
		/**
		 * @var Array<Vertex>
		 */
		var vertices:Array = new Array();

		vertices[0] = new Vertex(vertex1.x,vertex1.y+vdist,vertex1.z);
		vertices[1] = new Vertex(vertex1.x,vertex1.y+vdist+height,vertex1.z);
		vertices[2] = new Vertex(vertex2.x,vertex2.y+vdist+height,vertex2.z);
		vertices[3] = new Vertex(vertex2.x,vertex2.y+vdist,vertex2.z);

		vertices[4] = new Vertex(vertex3.x,vertex3.y+vdist,vertex3.z);
		vertices[5] = new Vertex(vertex3.x,vertex3.y+vdist+height,vertex3.z);
		vertices[6] = new Vertex(vertex4.x,vertex4.y+vdist+height,vertex4.z);
		vertices[7] = new Vertex(vertex4.x,vertex4.y+vdist,vertex4.z);


		return vertices;
	}

	

	/**
	 * Generates Obj Data
	 * @param  vertexCount [added for grouping in obj]
	 * @param  normalCount [added for grouping in obj]
	 * refer to readMe.txt for computing normals
	 * @return void
	 */
	public function generateOBJData(vertexCount:Number, normalCount:Number, textureCount:Number):String{

		var normal:Vertex;
		var xyzBounds={};
		var vt:Vertex, uMin:Number, vMin:Number, textureWidth:Number, textureHeight:Number, zAxis:Boolean;
		var uMax:Number, vMax:Number;

		//getting angle
		//var angle = Calc.angle(vertices[0].x, vertices[0].z, vertices[3].x, vertices[3].z);

		//useful data collected. It will be useful when computing uvs for walls
		/*
		# door slopeV 113.490507197874 data
		# door slopeV -66.5321011076563 data
		# door slopeH 137.395348806824 data
		# door slopeH -42.5804907833437 data
		# door slopeH 160.657885656729 data
		# door slopeH -19.3493770248569 data
		# door hor 0 data
		# door slopeH -158.198590513648 data
		# door slopeH 21.7396417445269 data
		# door slopeV -134.782146374903 data
		# door slopeV 45.2246881796245 data
		# door slopeV 69.4731649637197 data
		# door hor 180 data
		# door slopeV -110.556045219583 data
		# door slopeV -89.8057777625302 data
		# door slopeV 90.1998681875894 data
		# door slopeV 69.5010578182068 data
		# door slopeV -110.523838489129 data
		# door slopeV 45.2287896890386 data
		# door slopeV -134.754398040366 data
		# door slopeH 21.8014094863518 data
		# door slopeH -158.257415728619 data
		# door hor 180 data
		# door hor 0 data
		# door slopeH -19.3410733059456 data
		# door slopeH 137.442415310657 data
		# door slopeH -42.5795579008091 data
		# door slopeV 113.503437766035 data
		# door slopeV -66.496562233965 data
		*/

		
		//var data:String = '# doorOrWindow data\n\n'; 
		//var data:String = '\n# '+_type+' '+dir+' '+angle+' data\n\n';
		var data:String = '\n# '+_type+' data\n\n';  

		data += 'v '+vertices[0].x+' '+vertices[0].y+' '+vertices[0].z+'\n';
		data += 'v '+vertices[1].x+' '+vertices[1].y+' '+vertices[1].z+'\n';
		data += 'v '+vertices[2].x+' '+vertices[2].y+' '+vertices[2].z+'\n';
		data += 'v '+vertices[3].x+' '+vertices[3].y+' '+vertices[3].z+'\n';
		data += 'v '+vertices[4].x+' '+vertices[4].y+' '+vertices[4].z+'\n';
		data += 'v '+vertices[5].x+' '+vertices[5].y+' '+vertices[5].z+'\n';
		data += 'v '+vertices[6].x+' '+vertices[6].y+' '+vertices[6].z+'\n';
		data += 'v '+vertices[7].x+' '+vertices[7].y+' '+vertices[7].z+'\n';

		data += '\n';

		// f 1 2 3 
		// f 1 3 4
		normal = computeAndReturnNormal(vertices[0], vertices[1], vertices[2]);
		data += 'vn '+normal.x+' '+normal.y+' '+normal.z+'\n';
		// f 5 6 2
		// f 5 2 1
		normal = computeAndReturnNormal(vertices[4], vertices[5], vertices[1]);
		data += 'vn '+normal.x+' '+normal.y+' '+normal.z+'\n';
		// f 3 2 6
		// f 3 6 7 
		normal = computeAndReturnNormal(vertices[2], vertices[1], vertices[5]);
		data += 'vn '+normal.x+' '+normal.y+' '+normal.z+'\n';
		// f 3 7 8
		// f 3 8 4
		normal = computeAndReturnNormal(vertices[2], vertices[6], vertices[7]);
		data += 'vn '+normal.x+' '+normal.y+' '+normal.z+'\n';
		// f 1 4 8
		// f 1 8 5
		normal = computeAndReturnNormal(vertices[0], vertices[3], vertices[7]);
		data += 'vn '+normal.x+' '+normal.y+' '+normal.z+'\n';
		// f 8 7 6
		// f 8 6 5
		normal = computeAndReturnNormal(vertices[7], vertices[6], vertices[5]);
		data += 'vn '+normal.x+' '+normal.y+' '+normal.z+'\n';

		data +='\n';

		//textures
		////////
		xyzBounds = getXZYBounds(0);
		if(dir=='hor' || dir=='slopeH'){
			uMin = xyzBounds.xMin;
			vMin = xyzBounds.yMin;
			uMax = xyzBounds.xMax;
			vMax = xyzBounds.yMax;
		    textureWidth = Math.abs(xyzBounds.xMax - xyzBounds.xMin)/12;
			textureHeight = Math.abs(xyzBounds.yMax - xyzBounds.yMin)/12;
			zAxis = false;
		}
		else{
			uMin = xyzBounds.zMin;
			vMin = xyzBounds.yMin;
			uMax = xyzBounds.zMax;
			vMax = xyzBounds.yMax;
			textureWidth = Math.abs(xyzBounds.zMax - xyzBounds.zMin)/12;
			textureHeight = Math.abs(xyzBounds.yMax - xyzBounds.yMin)/12;
			zAxis = true;
		}
		
		//data +='# uMin: '+uMin+ ' vMin: '+vMin+ '\n';
		//data +='# uMax: '+uMax+ ' vMax: '+vMax+ '\n';
		//data +='# textureWidth: '+textureWidth+ ' textureHeight: '+textureHeight+ '\n';

		vt = Calc.doorsOrWindowsUV(uMin, vMin, textureWidth, textureHeight, vertices[0], zAxis);
		data += 'vt '+vt.x+' '+vt.y+' '+vt.z+'\n';
		vt = Calc.doorsOrWindowsUV(uMin, vMin, textureWidth, textureHeight, vertices[1], zAxis);
		data += 'vt '+vt.x+' '+vt.y+' '+vt.z+'\n';
		vt = Calc.doorsOrWindowsUV(uMin, vMin, textureWidth, textureHeight, vertices[2], zAxis);
		data += 'vt '+vt.x+' '+vt.y+' '+vt.z+'\n';
		vt = Calc.doorsOrWindowsUV(uMin, vMin, textureWidth, textureHeight, vertices[3], zAxis);
		data += 'vt '+vt.x+' '+vt.y+' '+vt.z+'\n';

		xyzBounds = getXZYBounds(4);
		if(dir=='hor' || dir=='slopeH'){
			uMin = xyzBounds.xMin;
			vMin = xyzBounds.yMin;
			uMax = xyzBounds.xMax;
			vMax = xyzBounds.yMax;
		    textureWidth = Math.abs(xyzBounds.xMax - xyzBounds.xMin)/12;
			textureHeight = Math.abs(xyzBounds.yMax - xyzBounds.yMin)/12;
			zAxis = false;
		}
		else{
			uMin = xyzBounds.zMin;
			vMin = xyzBounds.yMin;
			uMax = xyzBounds.zMax;
			vMax = xyzBounds.yMax;
			textureWidth = Math.abs(xyzBounds.zMax - xyzBounds.zMin)/12;
			textureHeight = Math.abs(xyzBounds.yMax - xyzBounds.yMin)/12;
			zAxis = true;
		}

		//data +='# uMin: '+uMin+ ' vMin: '+vMin+ '\n';
		//data +='# uMax: '+uMax+ ' vMax: '+vMax+ '\n';
		//data +='# textureWidth: '+textureWidth+ ' textureHeight: '+textureHeight+ '\n';

		vt = Calc.doorsOrWindowsUV(uMin, vMin, textureWidth, textureHeight, vertices[4], zAxis);
		data += 'vt '+vt.x+' '+vt.y+' '+vt.z+'\n';
		vt = Calc.doorsOrWindowsUV(uMin, vMin, textureWidth, textureHeight, vertices[5], zAxis);
		data += 'vt '+vt.x+' '+vt.y+' '+vt.z+'\n';
		vt = Calc.doorsOrWindowsUV(uMin, vMin, textureWidth, textureHeight, vertices[6], zAxis);
		data += 'vt '+vt.x+' '+vt.y+' '+vt.z+'\n';
		vt = Calc.doorsOrWindowsUV(uMin, vMin, textureWidth, textureHeight, vertices[7], zAxis);
		data += 'vt '+vt.x+' '+vt.y+' '+vt.z+'\n';

		////////
		//textures

		//data += '\nf 1//1 2//1 3//1';
		data += '\nf '+(1+vertexCount)+'/'+(1+textureCount)+'/'+(1+normalCount)+' '+(2+vertexCount)+'/'+(2+textureCount)+'/'+(1+normalCount)+' '+(3+vertexCount)+'/'+(3+textureCount)+'/'+(1+normalCount); 
		//data += '\nf 1//1 3//1 4//1';
		data += '\nf '+(1+vertexCount)+'/'+(1+textureCount)+'/'+(1+normalCount)+' '+(3+vertexCount)+'/'+(3+textureCount)+'/'+(1+normalCount)+' '+(4+vertexCount)+'/'+(4+textureCount)+'/'+(1+normalCount);  
		//data += '\nf 5//2 6//2 2//2';
		data += '\nf '+(5+vertexCount)+'//'+(2+normalCount)+' '+(6+vertexCount)+'//'+(2+normalCount)+' '+(2+vertexCount)+'//'+(2+normalCount);   
		//data += '\nf 5//2 2//2 1//2'; 
		data += '\nf '+(5+vertexCount)+'//'+(2+normalCount)+' '+(2+vertexCount)+'//'+(2+normalCount)+' '+(1+vertexCount)+'//'+(2+normalCount); 
		//data += '\nf 3//3 2//3 6//3';
		data += '\nf '+(3+vertexCount)+'//'+(3+normalCount)+' '+(2+vertexCount)+'//'+(3+normalCount)+' '+(6+vertexCount)+'//'+(3+normalCount);  
		//data += '\nf 3//3 6//3 7//3';
		data += '\nf '+(3+vertexCount)+'//'+(3+normalCount)+' '+(6+vertexCount)+'//'+(3+normalCount)+' '+(7+vertexCount)+'//'+(3+normalCount);  
		//data += '\nf 3//4 7//4 8//4';
		data += '\nf '+(3+vertexCount)+'//'+(4+normalCount)+' '+(7+vertexCount)+'//'+(4+normalCount)+' '+(8+vertexCount)+'//'+(4+normalCount);  
		//data += '\nf 3//4 8//4 4//4';
		data += '\nf '+(3+vertexCount)+'//'+(4+normalCount)+' '+(8+vertexCount)+'//'+(4+normalCount)+' '+(4+vertexCount)+'//'+(4+normalCount);  
		//data += '\nf 1//5 4//5 8//5';
		data += '\nf '+(1+vertexCount)+'//'+(5+normalCount)+' '+(4+vertexCount)+'//'+(5+normalCount)+' '+(8+vertexCount)+'//'+(5+normalCount);  
		//data += '\nf 1//5 8//5 5//5';
		data += '\nf '+(1+vertexCount)+'//'+(5+normalCount)+' '+(8+vertexCount)+'//'+(5+normalCount)+' '+(5+vertexCount)+'//'+(5+normalCount);  
		//data += '\nf 8//6 7//6 6//6';
		data += '\nf '+(8+vertexCount)+'/'+(8+textureCount)+'/'+(6+normalCount)+' '+(7+vertexCount)+'/'+(7+textureCount)+'/'+(6+normalCount)+' '+(6+vertexCount)+'/'+(6+textureCount)+'/'+(6+normalCount);  
		//data += '\nf 8//6 6//6 5//6';
		data += '\nf '+(8+vertexCount)+'/'+(8+textureCount)+'/'+(6+normalCount)+' '+(6+vertexCount)+'/'+(6+textureCount)+'/'+(6+normalCount)+' '+(5+vertexCount)+'/'+(5+textureCount)+'/'+(6+normalCount);  
	
		return data;
	}

	/**
	 * [computeAndReturnNormal description]
	 * @param  v1 [description]
	 * @param  v2 [description]
	 * @param  v3 [description]
	 * @return    [description]
	 */
	public function computeAndReturnNormal(v1:Vertex , v2:Vertex , v3:Vertex):Vertex{

		var d1:Vertex, d2:Vertex, cross:Vertex, normal:Vertex, dist:Number;

		d1 = Calc.directionalVector(v1, v2);
		d2 = Calc.directionalVector(v2, v3);
		cross = Calc.crossProduct(d1, d2);
		dist = Math.sqrt((cross.x*cross.x)+(cross.y*cross.y)+(cross.z*cross.z));
		normal = Calc.normal(cross, dist);

		return normal;
	}

	/**
	 * get xyz Bounds
	 * @param  startIndex [description]
	 * @return void
	 */
	public function getXZYBounds(startIndex:Number){
		var xMin=vertices[startIndex].x, yMin=vertices[startIndex].y, zMin=vertices[startIndex].z;
		var xMax=vertices[startIndex].x, yMax=vertices[startIndex].y, zMax=vertices[startIndex].z;

		for(var i=startIndex; i<startIndex+4; i++){
			//getting min
			if(vertices[i].x < xMin){
				xMin = vertices[i].x;
			}
			if(vertices[i].y < yMin){
				yMin = vertices[i].y;
			}
			if(vertices[i].z < zMin){
				zMin = vertices[i].z;
			}

			//getting max
			if(vertices[i].x > xMax){
				xMax = vertices[i].x;
			}
			if(vertices[i].y > yMax){
				yMax = vertices[i].y;
			}
			if(vertices[i].z > zMax){
				zMax = vertices[i].z;
			}
		}

		return {xMin:xMin,xMax:xMax,yMin:yMin,yMax:yMax,zMin:zMin,zMax:zMax};
	}
	
}