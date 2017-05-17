import threed.geom.Vertex;
import threed.ThreedInterface;
import threed.event.Broadcaster;
import threed.asset.Model;
import threed.utility.Calc;

class threed.asset.Floor extends Model{
	


	/**
	 * @var Array<Vertex>
	 * floor vertices
	 */
	public var vertices:Array;

	/**
	 * @var Boolean
	 * flag that determines whether to use the size of the grid or the floor when computing uvw for the floor
	 */
	public var useGridSize:Boolean=true;

	
	/**
	 * @constructor
	 * @param vertices [description]
	 */
	function Floor(broadcaster:Broadcaster, vertices:Array){

		super(broadcaster);
		this.vertices = vertices;
		// base class fields
		//this.fileName = new String("floor_"+(Math.round(Math.random()*99999999))+".obj");
		this.fileName = new String("floor_"+Calc.generateRandomString(10)+".obj");
		this.projectId = 35498;
		this.OBJData = generateOBJData();
		this.OBJPath = '../objs/'+fileName;
		this.removeOBJ = true;
	}

	
	/**
	 * Generates Obj Data
	 * @return String
	 */
	public function generateOBJData():String{

		var vertex:Vertex;
		var xMin=vertices[0].x, yMin=vertices[0].y, zMin=vertices[0].y;



		var data:String = '# floor data\n\n'; 

		for(var i=0; i<vertices.length; i++){

			vertex = vertices[i];
			data += 'v '+vertex.x+' '+vertex.y+' '+vertex.z+'\n';

			
			if(vertex.x < xMin){
				xMin = vertex.x;
			}
			if(vertex.y < yMin){
				yMin = vertex.y;
			}
			if(vertex.z < zMin){
				zMin = vertex.z;
			}
			

		}

		if(useGridSize == true){
			xMin = ((_level0.wid*12)/2)*-1;
			zMin = ((_level0.len*12)/2)*-1;
		}

		data +='\n';

		for(var i=0; i<vertices.length; i++){

			//vertex = Calc.uv(xMin, zMin, 1, 1, vertices[i], true);
			vertex = Calc.uv(xMin, zMin, _level0.floor_uv_width, _level0.floor_uv_depth, vertices[i], true);

			data += 'vt '+vertex.x+' '+vertex.y+' '+vertex.z+'\n';
		}
		
		data +='\nf ';

		for(var i=0; i<vertices.length; i++){

			data += ' '+(i+1)+'/'+(i+1);
			//data += ' '+(i+1);

		}

		return data;
	}

	
}