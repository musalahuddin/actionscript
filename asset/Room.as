import threed.geom.Vertex;
import threed.asset.Floor;
import threed.asset.Wall;
import threed.asset.DoorOrWindow;
import threed.ThreedInterface;
import threed.event.Broadcaster;
import threed.asset.Model;
import threed.utility.Calc;

class threed.asset.Room extends Model{

	/**
	 * @var Array<Wall>
	 */
	public var threed_walls:Array;

	/**
	 * @var Array<DoorOrWindow>
	 */
	public var threed_doorsOrWindows:Array;

	/**
	 * @var Floor
	 */
	public var threed_floor:Floor;


	/**
	 * constructor
	 * @param broadcaster           Broadcaster
	 * @param threed_walls          Array<Wall>
	 * @param threed_doorsOrWindows Array<DoorOrWindow>
	 * @param threed_floor          Floor
	 */
	function Room(broadcaster:Broadcaster, threed_walls:Array, threed_doorsOrWindows:Array,  threed_floor:Floor){

		super(broadcaster);
		this.threed_walls = threed_walls;
		this.threed_doorsOrWindows = threed_doorsOrWindows;
		this.threed_floor = threed_floor;
		// base class fields
		//this.fileName = new String("room_"+(Math.round(Math.random()*9999999999))+".obj");
		this.fileName = new String("room_"+Calc.generateRandomString(10)+".obj");
		this.projectId = 35498;
		this.OBJData = generateOBJData();
		this.OBJPath = '../objs/'+fileName;
		this.removeOBJ = true;

		
	}

	/**
	 * removeOpeningsAndReturnArray
	 * @param  threed_doorsOrWindows Array<DoorOrWindow>
	 * @return                       Array
	 */
	function removeOpeningsAndReturnArray(in_threed_doorsOrWindows:Array){
		var arr:Array;
		var doorOrWindow:DoorOrWindow;

		for(var i=0; i<in_threed_doorsOrWindows.length; i++){
			doorOrWindow = in_threed_doorsOrWindows[i];
			if(doorOrWindow._type != "opening"){
				arr.push(doorOrWindow);
			}
		}

		return arr;
	}

	/**
	 * [removeOpenings description]
	 * @return [description]
	 */
	function removeOpenings(){
		broadcaster.broadcastMessage("onDebug","debug__removeOpenings");
		var doorOrWindow:DoorOrWindow;

		for(var d = threed_doorsOrWindows.length-1;  d >=0; d--){
			doorOrWindow = threed_doorsOrWindows[d];
			broadcaster.broadcastMessage("onDebug","debug__type: "+doorOrWindow._type);
			if(doorOrWindow._type == "opening"){
				broadcaster.broadcastMessage("onDebug","debug__splicing: "+doorOrWindow._type);
				threed_doorsOrWindows.splice(d,1);
			}
		}
	}

	/**
	 * Generates Obj Data
	 * @return String
	 */
	function generateOBJData():String{

		//debug
		//broadcaster.broadcastMessage("onDebug","floor instanceof Floor: "+ (threed_floor instanceof Floor));

		var wall:Wall;
		var doorOrWindow:DoorOrWindow;
		var floor_vertexCount=0, floor_normalCount=0, floor_textureCount=0;
		var wall_vertexCount=0, wall_normalCount=0, wall_textureCount=0;
		var doorOrWindow_vertexCount=0, doorOrWindow_normalCount=0, doorOrWindow_textureCount=0;
		

		var data:String = '# room data\n'; 

		//floor data
		if(threed_floor instanceof Floor){
			floor_vertexCount = threed_floor.vertices.length;
			floor_textureCount = threed_floor.vertices.length;
			data += '\ng floor'
			data += '\n'+threed_floor.generateOBJData();
		}

		//walls data
		for(var i=0; i<threed_walls.length; i++){
			wall = threed_walls[i];
			//wall_vertexCount = (i*8)+threed_floor.vertices.length;
			wall_vertexCount = (i*8)+floor_vertexCount;  
			wall_normalCount = (i*6);
			if(wall.grouped){
				data += '\n\ng wall_'+(i+1)+'__'+wall.line+'_'+wall.point;
			}
			data += '\n'+wall.generateOBJData(wall_vertexCount, wall_normalCount);
		}

		
		//doorsOrWindows data
		removeOpenings();
		for(var i=0; i<threed_doorsOrWindows.length; i++){
			doorOrWindow = threed_doorsOrWindows[i];
			//wall_vertexCount = (i*8)+threed_floor.vertices.length;
			doorOrWindow_vertexCount = ((i+1)*8)+wall_vertexCount;  
			doorOrWindow_normalCount = ((i+1)*6)+wall_normalCount;
			doorOrWindow_textureCount = (i*8)+floor_textureCount;
			//data += '\n\ng doorOrWindow_'+(i+1);
			data += '\n\ng '+doorOrWindow._type+'_'+(i+1)+'__'+doorOrWindow.line+'_'+doorOrWindow.point;
			data += '\n'+doorOrWindow.generateOBJData(doorOrWindow_vertexCount, doorOrWindow_normalCount, doorOrWindow_textureCount);
		}
		

		return data;
	}


}