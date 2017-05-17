import threed.geom.Vertex;
import threed.event.Broadcaster;
import threed.asset.Model;
import threed.utility.Calc;

class threed.asset.Wall extends Model{
	

	/**
	 * @var Vertex
	 */
	public var insideVertexStart:Vertex;

	/**
	 * @var Vertex
	 */
	public var insideVertexEnd:Vertex;

	/**
	 * @var Vertex
	 */
	public var outsideVertexStart:Vertex;

	/**
	 * @var Vertex
	 */
	public var outsideVertexEnd:Vertex;

	/**
	 * @var Number
	 */
	public var thickness:Number;

	/**
	 * @var Number
	 */
	public var height:Number;

	/**
	 * @var String
	 */
	public var type:String; 

	/**
	 * @var String
	 */
	public var direction:String;

	/**
	 * @var Number
	 */
	public var line:Number;

	/**
	 * @var Number
	 */
	public var point:Number; 


	/**
	 * @var Array<Vertex>
	 * wall vertices
	 */
	public var vertices:Array;

	/**
	 * @var Number
	 */
	public var vdist:Number;

	/**
	 * @var Number
	 */
	public var grouped:Boolean;


	/**
	 * @constructor
	 * @param v1        insideStart
	 * @param v2        insideEnd
	 * @param v3        outsideStart
	 * @param v4        outsideEnd
	 * @param thickness wall thickness
	 * @param height    wall height
	 * @param type      wall type ("exterior","interior")
	 * @param direction wall direction ("clockwise","counter-clockwise")
	 */
	function Wall(broadcaster:Broadcaster, v1:Vertex, v2:Vertex, v3:Vertex, v4:Vertex, thickness:Number, height:Number, type:String, direction:String, line:Number, point:Number, vdist:Number){

		super(broadcaster);
		//vdist = 0;
		this.vdist = vdist || 0;
		this.grouped = true;
		this.insideVertexStart = v1; 
		this.insideVertexEnd = v2;
		this.outsideVertexStart = v3; 
		this.outsideVertexEnd = v4; 
		this.thickness = thickness;
		this.height = height;
		this.type = type;
		this.direction = direction;
		this.vertices = generateVertices();
		this.line = line;
		this.point = point;
		// base class fields
		//this.fileName = new String("wall_"+(Math.round(Math.random()*99999999))+".obj");
		this.fileName = new String("wall_"+Calc.generateRandomString(10)+".obj");
		this.projectId = 35498;
		this.OBJData = generateOBJData(0,0);
		this.OBJPath = '../objs/'+fileName;
		this.removeOBJ = true;
	}

	public function generateVertices(){

		broadcaster.broadcastMessage("onDebug","**VDIST IS **"+vdist);
		/**
		 * @var Array<Vertex>
		 */
		var vertices:Array = new Array();

		vertices[0] = new Vertex(insideVertexStart.x,insideVertexStart.y+vdist,insideVertexStart.z);
		vertices[1] = new Vertex(insideVertexStart.x,insideVertexStart.y+vdist+height,insideVertexStart.z);
		vertices[2] = new Vertex(insideVertexEnd.x,insideVertexEnd.y+vdist+height,insideVertexEnd.z);
		vertices[3] = new Vertex(insideVertexEnd.x,insideVertexEnd.y+vdist,insideVertexEnd.z);

		vertices[4] = new Vertex(outsideVertexStart.x,outsideVertexStart.y+vdist,outsideVertexStart.z);
		vertices[5] = new Vertex(outsideVertexStart.x,outsideVertexStart.y+vdist+height,outsideVertexStart.z);
		vertices[6] = new Vertex(outsideVertexEnd.x,outsideVertexEnd.y+vdist+height,outsideVertexEnd.z);
		vertices[7] = new Vertex(outsideVertexEnd.x,outsideVertexEnd.y+vdist,outsideVertexEnd.z);


		return vertices;
	}

	/**
	 * Generates Obj Data
	 * @param  vertexCounter [added for grouping in obj]
	 * @param  normalCounter [added for grouping in obj]
	 * refer to readMe.txt for computing normals.
	 * @return void
	 */
	public function generateOBJData(vertexCounter:Number, normalCounter:Number):String{

		var normal:Vertex;
		var data:String = '# wall data\n\n'; 

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

		//data += '\nf 1//1 2//1 3//1';
		data += '\nf '+(1+vertexCounter)+'//'+(1+normalCounter)+' '+(2+vertexCounter)+'//'+(1+normalCounter)+' '+(3+vertexCounter)+'//'+(1+normalCounter); 
		//data += '\nf 1//1 3//1 4//1';
		data += '\nf '+(1+vertexCounter)+'//'+(1+normalCounter)+' '+(3+vertexCounter)+'//'+(1+normalCounter)+' '+(4+vertexCounter)+'//'+(1+normalCounter);  
		//data += '\nf 5//2 6//2 2//2';
		data += '\nf '+(5+vertexCounter)+'//'+(2+normalCounter)+' '+(6+vertexCounter)+'//'+(2+normalCounter)+' '+(2+vertexCounter)+'//'+(2+normalCounter);   
		//data += '\nf 5//2 2//2 1//2'; 
		data += '\nf '+(5+vertexCounter)+'//'+(2+normalCounter)+' '+(2+vertexCounter)+'//'+(2+normalCounter)+' '+(1+vertexCounter)+'//'+(2+normalCounter); 
		//data += '\nf 3//3 2//3 6//3';
		data += '\nf '+(3+vertexCounter)+'//'+(3+normalCounter)+' '+(2+vertexCounter)+'//'+(3+normalCounter)+' '+(6+vertexCounter)+'//'+(3+normalCounter);  
		//data += '\nf 3//3 6//3 7//3';
		data += '\nf '+(3+vertexCounter)+'//'+(3+normalCounter)+' '+(6+vertexCounter)+'//'+(3+normalCounter)+' '+(7+vertexCounter)+'//'+(3+normalCounter);  
		//data += '\nf 3//4 7//4 8//4';
		data += '\nf '+(3+vertexCounter)+'//'+(4+normalCounter)+' '+(7+vertexCounter)+'//'+(4+normalCounter)+' '+(8+vertexCounter)+'//'+(4+normalCounter);  
		//data += '\nf 3//4 8//4 4//4';
		data += '\nf '+(3+vertexCounter)+'//'+(4+normalCounter)+' '+(8+vertexCounter)+'//'+(4+normalCounter)+' '+(4+vertexCounter)+'//'+(4+normalCounter);  
		//data += '\nf 1//5 4//5 8//5';
		data += '\nf '+(1+vertexCounter)+'//'+(5+normalCounter)+' '+(4+vertexCounter)+'//'+(5+normalCounter)+' '+(8+vertexCounter)+'//'+(5+normalCounter);  
		//data += '\nf 1//5 8//5 5//5';
		data += '\nf '+(1+vertexCounter)+'//'+(5+normalCounter)+' '+(8+vertexCounter)+'//'+(5+normalCounter)+' '+(5+vertexCounter)+'//'+(5+normalCounter);  
		//data += '\nf 8//6 7//6 6//6';
		data += '\nf '+(8+vertexCounter)+'//'+(6+normalCounter)+' '+(7+vertexCounter)+'//'+(6+normalCounter)+' '+(6+vertexCounter)+'//'+(6+normalCounter);  
		//data += '\nf 8//6 6//6 5//6';
		data += '\nf '+(8+vertexCounter)+'//'+(6+normalCounter)+' '+(6+vertexCounter)+'//'+(6+normalCounter)+' '+(5+vertexCounter)+'//'+(6+normalCounter);  
	
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
	 * Generates Obj Data
	 * @param  counter [added for grouping in obj]
	 * @return void
	 */
	function generateOBJData_bk(counter:Number):String{

		var data:String = '# wall data\n\n'; 


		data += 'v '+insideVertexStart.x+' '+insideVertexStart.y+' '+insideVertexStart.z+'\n';
		data += 'v '+insideVertexStart.x+' '+(insideVertexStart.y + height)+' '+insideVertexStart.z+'\n';
		data += 'v '+insideVertexEnd.x+' '+(insideVertexEnd.y + height)+' '+insideVertexEnd.z+'\n';
		data += 'v '+insideVertexEnd.x+' '+insideVertexEnd.y+' '+insideVertexEnd.z+'\n';

		data += 'v '+outsideVertexStart.x+' '+outsideVertexStart.y+' '+outsideVertexStart.z+'\n';
		data += 'v '+outsideVertexStart.x+' '+(outsideVertexStart.y + height)+' '+outsideVertexStart.z+'\n';
		data += 'v '+outsideVertexEnd.x+' '+(outsideVertexEnd.y + height)+' '+outsideVertexEnd.z+'\n';
		data += 'v '+outsideVertexEnd.x+' '+outsideVertexEnd.y+' '+outsideVertexEnd.z+'\n';

		/*
		data +='\nf 1 2 3 4';
		data +='\nf 5 6 2 1';
		data +='\nf 3 2 6 7';
		data +='\nf 3 7 8 4';
		data +='\nf 1 4 8 5';
		data +='\nf 8 7 6 5';
		*/

		data +='\nf '+(1+counter)+' '+(2+counter)+' '+(3+counter)+' '+(4+counter);
		data +='\nf '+(5+counter)+' '+(6+counter)+' '+(2+counter)+' '+(1+counter);
		data +='\nf '+(3+counter)+' '+(2+counter)+' '+(6+counter)+' '+(7+counter);
		data +='\nf '+(3+counter)+' '+(7+counter)+' '+(8+counter)+' '+(4+counter);
		data +='\nf '+(1+counter)+' '+(4+counter)+' '+(8+counter)+' '+(5+counter);
		data +='\nf '+(8+counter)+' '+(7+counter)+' '+(6+counter)+' '+(5+counter);

		return data;
	}

	/**
	 * Generates Obj Data
	 * @param  counter [added for grouping in obj]
	 * @return void
	 */
	function generateOBJData_good(counter:Number):String{

		var data:String = '# wall data\n\n'; 


		data += 'v '+insideVertexStart.x+' '+insideVertexStart.y+' '+insideVertexStart.z+'\n';
		data += 'v '+insideVertexStart.x+' '+(insideVertexStart.y + height)+' '+insideVertexStart.z+'\n';
		data += 'v '+insideVertexEnd.x+' '+(insideVertexEnd.y + height)+' '+insideVertexEnd.z+'\n';
		data += 'v '+insideVertexEnd.x+' '+insideVertexEnd.y+' '+insideVertexEnd.z+'\n';

		data += 'v '+outsideVertexStart.x+' '+outsideVertexStart.y+' '+outsideVertexStart.z+'\n';
		data += 'v '+outsideVertexStart.x+' '+(outsideVertexStart.y + height)+' '+outsideVertexStart.z+'\n';
		data += 'v '+outsideVertexEnd.x+' '+(outsideVertexEnd.y + height)+' '+outsideVertexEnd.z+'\n';
		data += 'v '+outsideVertexEnd.x+' '+outsideVertexEnd.y+' '+outsideVertexEnd.z+'\n';

		
		//data +='\nf 1 2 3 4';
		//data +='\nf 5 6 2 1';
		//data +='\nf 3 2 6 7';
		//data +='\nf 3 7 8 4';
		//data +='\nf 1 4 8 5';
		//data +='\nf 8 7 6 5';

		//data +='\nf 1 2 4';
		data +='\nf '+(1+counter)+' '+(2+counter)+' '+(4+counter);
		//data +='\nf 2 3 4';
		data +='\nf '+(2+counter)+' '+(3+counter)+' '+(4+counter);
		//data +='\nf 5 6 1';
		data +='\nf '+(5+counter)+' '+(6+counter)+' '+(1+counter);
		//data +='\nf 6 2 1';
		data +='\nf '+(6+counter)+' '+(2+counter)+' '+(1+counter);
		//data +='\nf 3 2 7';
		data +='\nf '+(3+counter)+' '+(2+counter)+' '+(7+counter);
		//data +='\nf 2 6 7';
		data +='\nf '+(2+counter)+' '+(6+counter)+' '+(7+counter);
		//data +='\nf 3 7 4';
		data +='\nf '+(3+counter)+' '+(7+counter)+' '+(4+counter);
		//data +='\nf 7 8 4';
		data +='\nf '+(7+counter)+' '+(8+counter)+' '+(4+counter);
		//data +='\nf 1 4 5';
		data +='\nf '+(1+counter)+' '+(4+counter)+' '+(5+counter);
		//data +='\nf 4 8 5';
		data +='\nf '+(4+counter)+' '+(8+counter)+' '+(5+counter);
		//data +='\nf 8 7 5';
		data +='\nf '+(8+counter)+' '+(7+counter)+' '+(5+counter);
		//data +='\nf 7 6 5';
		data +='\nf '+(7+counter)+' '+(6+counter)+' '+(5+counter);
	
		return data;
	}
}