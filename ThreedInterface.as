/**
 * ThreedInterface Class
 * This is the main class that creates 3d assets(walls, floors, doors, windows, and rooms) 
 * on the fly
 */
import threed.geom.Vertex; 
import threed.asset.Floor;
import threed.asset.Wall;
import threed.asset.DoorOrWindow;
import threed.asset.Room;
import threed.asset.FloorObject;
import flash.geom.Point; 
import threed.utility.Calc;
import threed.event.Broadcaster;
import threed.event.Listener;
import flash.external.ExternalInterface;

class threed.ThreedInterface{
	
	/**
	 * @var Floor
	 */
	public var threed_floor:Floor;

	/**
	 * @var Array<Wall>
	 */
	public var threed_walls:Array;

	/**
	 * @var Array<Wall>
	 */
	public var threed_walls_without_doorsOrWindows:Array;


	/**
	 * @var Array<DoorOrWindow>
	 */
	public var threed_doorsOrWindows:Array;

	/**
	 * @var Room
	 */
	public var threed_room:Room;

	/**
	 * @var Array<FloorObject>
	 */
	public var threed_floorObjects:Array;

	/**
	 * @var Broadcaster
	 */
	public var broadcaster:Broadcaster; 

	/**
	 * @var Listener
	 */
	public var listener:Listener;

	/**
	 * @var Array
	 */
	public var threed_assets:Array;

	/**
	 * @var Array
	 */
	public var threed_materials:Array;

	/**
	 * @var Number
	 */
	public var timer:Number;

	/**
	 * @var Number
	 */
	public var upload_timer:Number;


	/**
	 * @constructor
	 */
	function ThreedInterface(){

		this.threed_walls = new Array();
		this.threed_walls_without_doorsOrWindows = new Array();
		this.threed_doorsOrWindows = new Array();
		this.threed_assets = new Array();

		this.initialize();
	}


	/**
	 * Creates 3d walls 
	 */
	public function createWalls(){

		/**
		 * @var Array<Object-{ptA,ptB,ptC,ptD}> 
		 */
		var wallPoints:Array;
		var vertex1:Vertex;
		var vertex2:Vertex;
		var vertex3:Vertex;
		var vertex4:Vertex;
		var type:String;
		var hasDoorsOrWindowsAttached:Boolean;
		var wall:Wall;

		wallPoints = computeAndReturnWallPoints();

		for(var i=0 ; i<wallPoints.length; i++){
			broadcaster.broadcastMessage("onDebug","wall direction: "+_level225.wallsDirection[wallPoints[i].line]);
			//if(_level225.wallsDirection[wallPoints[i].line] == 'counter-clockwise'){
				vertex1 = new Vertex(Calc.pixelsToInches(wallPoints[i].ptA.x),0,Calc.pixelsToInches(wallPoints[i].ptA.y));
				vertex2 = new Vertex(Calc.pixelsToInches(wallPoints[i].ptB.x),0,Calc.pixelsToInches(wallPoints[i].ptB.y));
				vertex3 = new Vertex(Calc.pixelsToInches(wallPoints[i].ptD.x),0,Calc.pixelsToInches(wallPoints[i].ptD.y));
				vertex4 = new Vertex(Calc.pixelsToInches(wallPoints[i].ptC.x),0,Calc.pixelsToInches(wallPoints[i].ptC.y));
			//}
			//else{
			//	vertex1 = new Vertex(Calc.pixelsToInches(wallPoints[i].ptC.x),0,Calc.pixelsToInches(wallPoints[i].ptC.y));
			//	vertex2 = new Vertex(Calc.pixelsToInches(wallPoints[i].ptD.x),0,Calc.pixelsToInches(wallPoints[i].ptD.y));
			//	vertex3 = new Vertex(Calc.pixelsToInches(wallPoints[i].ptB.x),0,Calc.pixelsToInches(wallPoints[i].ptB.y));
			//	vertex4 = new Vertex(Calc.pixelsToInches(wallPoints[i].ptA.x),0,Calc.pixelsToInches(wallPoints[i].ptA.y));
			//}

			if(wallPoints[i].line == 1){
				type = 'exterior';
			}
			else{
				type = 'interior';
			}

			
			if(isDoorOrWindowAttached(wallPoints[i].line, wallPoints[i].point)){

				var tempArr = [];
				// fetch all doors and windows attached with this wall
				for(var j=0; j<threed_doorsOrWindows.length; j++){
					if(threed_doorsOrWindows[j].line == wallPoints[i].line && threed_doorsOrWindows[j].point == wallPoints[i].point){
						var dist = getShortestDistance(vertex1, threed_doorsOrWindows[j].vertex1, threed_doorsOrWindows[j].vertex2);
						tempArr.push({dist: dist, threed_doorOrWindow: threed_doorsOrWindows[j]});
					}
				}

				tempArr.sortOn("dist",Array.NUMERIC);

				//broadcaster.broadcastMessage("onDebug","tempArr size: "+tempArr.length);
				
				// makes a wall from the first end of the wall to the nearest door or window 
				// since sorting was based off of vertex1 of the current wall, tempArr[0] is used  as the nearest door/window from vertex1 of the current wall
				var obj1 = getNearestDoorOrWindowVertex1(vertex1, tempArr[0].threed_doorOrWindow);
				wall = new Wall(broadcaster, vertex1, obj1.v1, vertex3, obj1.v2, 5, (_level0.hei*12), type, _level225.wallsDirection[1], wallPoints[i].line, wallPoints[i].point); 
				threed_walls.push(wall);
			
				// makes a wall from the second end of the wall to the nearest door or window 
				// since sorting was based off of vertex1 of the current wall, tempArr[tempArr.length-1] is used  as the nearest door/window from vertex2 of the current wall
				var obj2 = getNearestDoorOrWindowVertex2(vertex2, tempArr[tempArr.length-1].threed_doorOrWindow);
				wall = new Wall(broadcaster, obj2.v1, vertex2, obj2.v2, vertex4, 5, (_level0.hei*12), type, _level225.wallsDirection[1], wallPoints[i].line, wallPoints[i].point);
				wall.grouped = false;
				threed_walls.push(wall);
				
				//if(_level0.client_id == 2){
				
					// makes above/below partial walls per door/window
					for(var j=0; j<tempArr.length; j++){

						var aboveHeight = (_level0.hei*12)-(tempArr[j].threed_doorOrWindow.vdist+tempArr[j].threed_doorOrWindow.height);
						var belowHeight = tempArr[j].threed_doorOrWindow.vdist;
						var aboveVdist = tempArr[j].threed_doorOrWindow.vdist+tempArr[j].threed_doorOrWindow.height;
						var belowVdist = 0;
						
						//above
						if(aboveHeight > 0){
							wall = new Wall(broadcaster, tempArr[j].threed_doorOrWindow.vertex1, tempArr[j].threed_doorOrWindow.vertex2, tempArr[j].threed_doorOrWindow.vertex3, tempArr[j].threed_doorOrWindow.vertex4, 5, aboveHeight, type, _level225.wallsDirection[1], wallPoints[i].line, wallPoints[i].point, aboveVdist);
							wall.grouped = false;
							threed_walls.push(wall);
						}

						//below
						if(belowHeight > 0){
							wall = new Wall(broadcaster, tempArr[j].threed_doorOrWindow.vertex1, tempArr[j].threed_doorOrWindow.vertex2, tempArr[j].threed_doorOrWindow.vertex3, tempArr[j].threed_doorOrWindow.vertex4, 5, belowHeight, type, _level225.wallsDirection[1], wallPoints[i].line, wallPoints[i].point, belowVdist);
							wall.grouped = false;
							threed_walls.push(wall);
						}	
					}
				
				
					// makes a wall between two doors/windows. 
					for(var j=0; j<tempArr.length-1; j++){
						var dist=-1, dist1=0, dist2=0, dist3=0, dist4=0;
						var obj={};
						var k = j+1;
						//for(var k=j+1; k<tempArr.length; k++){
							broadcaster.broadcastMessage("onDebug","I AM HERE");
							dist1 = Calc.distance(new Point(tempArr[j].threed_doorOrWindow.vertex1.x,tempArr[j].threed_doorOrWindow.vertex1.z), new Point(tempArr[k].threed_doorOrWindow.vertex1.x,tempArr[k].threed_doorOrWindow.vertex1.z));
							if(dist1 < dist || dist == -1){
								broadcaster.broadcastMessage("onDebug","DIST1 < DIST");
								dist = dist1;
								
								obj = {vertex1:tempArr[j].threed_doorOrWindow.vertex3, vertex2:tempArr[k].threed_doorOrWindow.vertex1, vertex3:tempArr[j].threed_doorOrWindow.vertex1, vertex4:tempArr[k].threed_doorOrWindow.vertex3};
							}
							dist2 = Calc.distance(new Point(tempArr[j].threed_doorOrWindow.vertex1.x,tempArr[j].threed_doorOrWindow.vertex1.z), new Point(tempArr[k].threed_doorOrWindow.vertex2.x,tempArr[k].threed_doorOrWindow.vertex2.z));
							if(dist2 < dist || dist == -1){
								broadcaster.broadcastMessage("onDebug","DIST2 < DIST");
								dist = dist2;
								
								obj = {vertex1:tempArr[j].threed_doorOrWindow.vertex3, vertex2:tempArr[k].threed_doorOrWindow.vertex4, vertex3:tempArr[j].threed_doorOrWindow.vertex1, vertex4:tempArr[k].threed_doorOrWindow.vertex2};
							}
							dist3 = Calc.distance(new Point(tempArr[j].threed_doorOrWindow.vertex2.x,tempArr[j].threed_doorOrWindow.vertex2.z), new Point(tempArr[k].threed_doorOrWindow.vertex1.x,tempArr[k].threed_doorOrWindow.vertex1.z));
							if(dist3 < dist || dist == -1){
								broadcaster.broadcastMessage("onDebug","DIST3 < DIST");
								dist = dist3;
								obj = {vertex1:tempArr[j].threed_doorOrWindow.vertex2, vertex2:tempArr[k].threed_doorOrWindow.vertex1, vertex3:tempArr[j].threed_doorOrWindow.vertex4, vertex4:tempArr[k].threed_doorOrWindow.vertex3};
							}
							dist4 = Calc.distance(new Point(tempArr[j].threed_doorOrWindow.vertex2.x,tempArr[j].threed_doorOrWindow.vertex2.z), new Point(tempArr[k].threed_doorOrWindow.vertex2.x,tempArr[k].threed_doorOrWindow.vertex2.z));
							if(dist4 < dist || dist == -1){
								broadcaster.broadcastMessage("onDebug","DIST4 < DIST");
								dist = dist4;
			
								obj = {vertex1:tempArr[j].threed_doorOrWindow.vertex2, vertex2:tempArr[k].threed_doorOrWindow.vertex4, vertex3:tempArr[j].threed_doorOrWindow.vertex4, vertex4:tempArr[k].threed_doorOrWindow.vertex2};
							}
						//}

						wall = new Wall(broadcaster, obj.vertex1, obj.vertex2, obj.vertex3, obj.vertex4, 5, (_level0.hei*12), type, _level225.wallsDirection[1], wallPoints[i].line, wallPoints[i].point);
						wall.grouped = false;
						threed_walls.push(wall);

					}
				//}
			}
			else{
				threed_walls.push(new Wall(broadcaster, vertex1, vertex2, vertex3, vertex4, 5, (_level0.hei*12), type, _level225.wallsDirection[1], wallPoints[i].line, wallPoints[i].point));
			}
			
			// must delete this line
			//threed_walls.push(new Wall(broadcaster, vertex1, vertex2, vertex3, vertex4, 5, (_level0.hei*12), type, _level225.wallsDirection[1], wallPoints[i].line, wallPoints[i].point));
			// this is used for floor
			threed_walls_without_doorsOrWindows.push(new Wall(broadcaster, vertex1, vertex2, vertex3, vertex4, 5, (_level0.hei*12), type, _level225.wallsDirection[1], wallPoints[i].line, wallPoints[i].point));
		}

		/*
		_level0.obtest = "wallPoints: "+ wallPoints.length;
		_level0.obtest += "<br/>3d-Length: "+ threed_walls.length;
		_level0.debug();
		*/
	}

	public function getShortestDistance(fromVertex:Vertex, vertex1:Vertex, vertex2:Vertex):Number{
		var dist1 = Calc.distance(new Point(fromVertex.x, fromVertex.z), new Point(vertex1.x,vertex1.z));
		var dist2 = Calc.distance(new Point(fromVertex.x, fromVertex.z), new Point(vertex2.x,vertex2.z));

		if(dist1 < dist2)
		return dist1;
		else
		return dist2;

	}

	public function getNearestDoorOrWindowVertex1(fromVertex:Vertex, threed_doorOrWindow:DoorOrWindow):Object{
		var obj={};
		
		var dist1 = Calc.distance(new Point(fromVertex.x, fromVertex.z), new Point(threed_doorOrWindow.vertex1.x,threed_doorOrWindow.vertex1.z));
		var dist2 = Calc.distance(new Point(fromVertex.x, fromVertex.z), new Point(threed_doorOrWindow.vertex2.x,threed_doorOrWindow.vertex2.z));
		
		if(dist1 < dist2){
			broadcaster.broadcastMessage("onDebug","dwdist1");
			obj = {v1:threed_doorOrWindow.vertex1, v2: threed_doorOrWindow.vertex3}
		}
		else {
			broadcaster.broadcastMessage("onDebug","dwdist2");
			obj = {v1:threed_doorOrWindow.vertex4, v2: threed_doorOrWindow.vertex2}
		}


		return obj;
	}

	public function getNearestDoorOrWindowVertex2(fromVertex:Vertex, threed_doorOrWindow:DoorOrWindow):Object{
		var obj={};
		
		var dist1 = Calc.distance(new Point(fromVertex.x, fromVertex.z), new Point(threed_doorOrWindow.vertex1.x,threed_doorOrWindow.vertex1.z));
		var dist2 = Calc.distance(new Point(fromVertex.x, fromVertex.z), new Point(threed_doorOrWindow.vertex2.x,threed_doorOrWindow.vertex2.z));
		
		if(dist1 < dist2){
			broadcaster.broadcastMessage("onDebug","dwdist1");
			obj = {v1:threed_doorOrWindow.vertex3, v2: threed_doorOrWindow.vertex1}
		}
		else {
			broadcaster.broadcastMessage("onDebug","dwdist2");
			obj = {v1:threed_doorOrWindow.vertex2, v2: threed_doorOrWindow.vertex4}
		}


		return obj;
	}

	public function isDoorOrWindowAttached(line:Number, point:Number){
		for(var i=0; i<threed_doorsOrWindows.length; i++){
			if(threed_doorsOrWindows[i].line == line && threed_doorsOrWindows[i].point == point){
				return true;
			}
		}
		return false;
	}


	/**
	 * Creates 3d doors or windows 
	 */
	public function createDoorsOrWindows(){


		var doorOrWindowPoints:Array;
		var vertex1:Vertex;
		var vertex2:Vertex;
		var vertex3:Vertex;
		var vertex4:Vertex;
		var type:String;

		doorOrWindowPoints = computeAndReturnDoorOrWindowPoints();

		for(var i=0 ; i<doorOrWindowPoints.length; i++){

			vertex1 = new Vertex(Calc.pixelsToInches(doorOrWindowPoints[i].ptA.x),0,Calc.pixelsToInches(doorOrWindowPoints[i].ptA.y));
			vertex2 = new Vertex(Calc.pixelsToInches(doorOrWindowPoints[i].ptB.x),0,Calc.pixelsToInches(doorOrWindowPoints[i].ptB.y));
			vertex3 = new Vertex(Calc.pixelsToInches(doorOrWindowPoints[i].ptD.x),0,Calc.pixelsToInches(doorOrWindowPoints[i].ptD.y));
			vertex4 = new Vertex(Calc.pixelsToInches(doorOrWindowPoints[i].ptC.x),0,Calc.pixelsToInches(doorOrWindowPoints[i].ptC.y));

			threed_doorsOrWindows.push(new DoorOrWindow(broadcaster, vertex1, vertex2, vertex3, vertex4, doorOrWindowPoints[i].height, doorOrWindowPoints[i].vdist, doorOrWindowPoints[i].type, doorOrWindowPoints[i].line, doorOrWindowPoints[i].point, doorOrWindowPoints[i].dir));
		}
	}

	/**
	 * Creates 3d floor
	 * @return void
	 */
	public function createFloor(){

		/**
		 * @var Array<Vertex>
		 */
		var vertices:Array = new Array();

		for(var i=0; i<threed_walls_without_doorsOrWindows.length; i++){
			if(threed_walls_without_doorsOrWindows[i].type == 'exterior'){
				// switch between insideVertexStart and outsideVertexEnd depanding on the direction of wall drawn
				if(_level225.wallsDirection[1] == 'counter-clockwise'){
					vertices.push(threed_walls_without_doorsOrWindows[i].insideVertexStart);
				}
				else{
					vertices.push(threed_walls_without_doorsOrWindows[i].outsideVertexEnd);
				}

			}
		}

		// this should move to Floor.as
		if(_level225.wallsDirection[1] == 'clockwise'){
			vertices.reverse();
		}
		

		threed_floor = new Floor(broadcaster, vertices);
	}


	/**
	 * Creates 3d Room (i.e. walls, windows, doors, and floor)
	 * @return void
	 */
	public function createRoom(){

		createDoorsOrWindows();
		createWalls();
		createFloor();
		
		threed_room = new Room(broadcaster, threed_walls, threed_doorsOrWindows,  threed_floor);
	}



	/**
	 * exports floor to obj
	 * @return void
	 */
	public function exportFloorToOBJ(){

		threed_floor.exportToOBJ();
	}

	/**
	 * exports walls to obj
	 * @return void
	 */
	public function exportWallsToOBJ(){

		var wall:Wall;

		for(var i=0; i<threed_walls.length; i++){
			wall = threed_walls[i];
			wall.exportToOBJ();
		}

	}

	/**
	 * exports doors or windows to obj
	 * @return void
	 */
	public function exportDoorsOrWindowsToOBJ(){


		var doorOrWindow:DoorOrWindow;

		for(var i=0; i<threed_doorsOrWindows.length; i++){
			doorOrWindow = threed_doorsOrWindows[i];
			doorOrWindow.exportToOBJ();
		}

	}

	/**
	 * export room to obj
	 * @return void
	 */
	public function exportRoomToOBJ(){

		threed_room.exportToOBJ();
	}


	/**
	 * registers broadcaster and listener
	 * @return Void
	 */
	public function initialize(){
		broadcaster = new Broadcaster();
		listener = new Listener();

		broadcaster.addListener(listener.listener);
	}

	/**
	 * creates and upload room obj
	 * @return Void
	 */
	public function createAndUploadRoomOBJ(){
		
		createRoom();
		exportRoomToOBJ();
	}

	/**
	 * creates and upload walls objs
	 * @return Void
	 */
	public function createAndUploadWallsOBJs(){
		
		createWalls();
		exportWallsToOBJ();
	}

	/**
	 * creates and upload floor objs
	 * @return Void
	 */
	public function createAndUploadFloorOBJ(){
		
		createWalls();
		createFloor();
		exportFloorToOBJ();
	}

	/**
	 * creates and upload doorsOrWindows objs
	 * @return Void
	 */
	public function createAndUploadDoorsOrWindowsOBJs(){
		
		createDoorsOrWindows();
		exportDoorsOrWindowsToOBJ();
	}

	/**
	 * upload floor objects
	 * @return Void
	 */
	public function uploadFloorObjectsOBJs(context){

		if(threed_room instanceof Room){
			if(threed_room.fileUploaded != true){
				return;
			}
		}

		clearInterval(context.upload_timer);

		var floorObject:FloorObject; 
		
		for(var i=0 ; i<threed_floorObjects.length; i++){

			floorObject = threed_floorObjects[i];
			floorObject.uploadOBJ();
		}

	}

	/**
	 * checks to see if room OBJ has been uploaded before uploading the floor assets
	 * @return Void
	 */
	public function checkAndUploadFloorObjectsOBJs(){

		upload_timer = setInterval(this,"uploadFloorObjectsOBJs", 500, this);

	}

	/**
	 * adds asset objects into threed_assets[] array
	 * @return [description]
	 */
	public function populateAssetsArray(){

		broadcaster.broadcastMessage("onDebug","room: "+threed_room.fileName);
		//return;
		
		threed_assets = new Array();

		threed_floorObjects = new Array();

		var floorObject:FloorObject;

		var floorObjectMap={};
		
		// add room asset
		if(threed_room instanceof Room){
			threed_assets.push({
				name:threed_room.fileName.toString()
				, rotation:0
				, x:0
				, y:0
				, z:0
				, project_id:35498
				, system_id:0
				, sku_id:0
				, arrIndex:-1
			});
		}

		//threed_assets.push({name:'room_56965218.obj', rotation:0, x:0, y:0, z:0, project_id:35498});
		
		// add floor assets from the planner
		for (var i=0; i<_level0.officePlannerArray.length; i++) {

			if (_level0.officePlannerArray[i].name == undefined){
				continue;
			}
			
			if(_level0.officePlannerArray[i].skuSelectorFlag == 1){
				continue;
			}
			/*
			if (_level0.officePlannerArray[i].ShownInSectionID != '1'){
				continue;
			}
			*/
			// allowed typical parts and reference in 3D on 08-15-16 M.S.
			if (_level0.officePlannerArray[i].ShownInSectionID != '1' && _level0.officePlannerArray[i].ShownInSectionID != '4' && _level0.officePlannerArray[i].ShownInSectionID != '5'){
				continue;
			}

			if(!_level0.officePlannerArray[i].attributes.FilePath3DModel._value){
				continue;
			}

			var floorObj = eval("_level200.officeplanner."+_level0.officePlannerArray[i].name);

			if(_level0.isElevPlanner == 1){
				var elevScalePercentage = _level0.officePlannerArray[i].scalePercentage;
				broadcaster.broadcastMessage("onDebug","***(elevScalePercentage): "+elevScalePercentage);
				if(elevScalePercentage == undefined || elevScalePercentage == "undefined"){
					elevScalePercentage = _level0.scalePercentage;
				}
				
				var elevHeightIn = _level0.hei*12;
				var floorObjHeightIn = _level0.officePlannerArray[i].product_height;
				var floorObjYCoordIn = (_level0.officePlannerArray[i].ypos/ (_level0.onefoot*elevScalePercentage*_level0.onefootScale)) * 12;

				broadcaster.broadcastMessage("onDebug","threed_floorObjHeightIn: "+floorObjHeightIn);
				broadcaster.broadcastMessage("onDebug","threed_floorObjYCoordIn: "+floorObjYCoordIn);
				
				var rotation = floorObj._rotation;
				
				broadcaster.broadcastMessage("onDebug","rotation is: "+rotation);
				
				var planObj_x = floorObj._x;
				var planObj_y = floorObj._y;
				
				//bug fix where cabinet backs disappeared when the wall had openings. 
				//solution: move the cabinet few pixels away from the wall to fix this issue. 
				if(rotation == 0){
					planObj_y += 2;
				}
				else if(rotation == 180){
					planObj_y -= 2;
				}
				else if(rotation == -90){
					planObj_x += 2;
				}
				else if(rotation == 90){
					planObj_x -= 2;
				} 
				
				// converting coordinates from pixels to inches for lagoa 3d scene 
				// NOTE: 1ft = 12 in = 30.48 cm
				//var xCoord = (floorObj._x / (_level0.onefoot*_level0.scalePercentage*_level0.onefootScale)) * 12; //30.48; 
				var xCoord = (planObj_x / (_level0.onefoot*_level0.scalePercentage*_level0.onefootScale)) * 12; //30.48; 
				var yCoord = (elevHeightIn/2)-(floorObjYCoordIn+(floorObjHeightIn/2));
				//var zCoord = (floorObj._y / (_level0.onefoot*_level0.scalePercentage*_level0.onefootScale)) * 12; //30.48;
				var zCoord = (planObj_y / (_level0.onefoot*_level0.scalePercentage*_level0.onefootScale)) * 12; //30.48;
				
				if(rotation == -90){
					rotation = 90;
				}
				else if(rotation == 90){
					rotation = -90;
				}

			}
			else{

				// converting coordinates from pixels to inches for lagoa 3d scene 
				// NOTE: 1ft = 12 in = 30.48 cm
				var xCoord = (floorObj._x / (_level0.onefoot*_level0.scalePercentage*_level0.onefootScale)) * 12; //30.48; 
				//var yCoord = 0;
				var yCoord = _level0.officePlannerArray[i].threed_yCoord || 0;
				var zCoord = (floorObj._y / (_level0.onefoot*_level0.scalePercentage*_level0.onefootScale)) * 12; //30.48;

				var rotation = floorObj._rotation*-1;

			}


			// this exception was added to avoid uploading the same asset multiple times.
			if(floorObjectMap[_level0.officePlannerArray[i].attributes.SkuId._value]){
				floorObject = floorObjectMap[_level0.officePlannerArray[i].attributes.SkuId._value];
			}
			else{
				floorObject = new FloorObject(broadcaster, _level0.officePlannerArray[i].attributes.FilePath3DModel._value);
				threed_floorObjects.push(floorObject);
				floorObjectMap[_level0.officePlannerArray[i].attributes.SkuId._value]=floorObject;
			}
			
			// add floor assets
			threed_assets.push({
				name:floorObject.fileName.toString()
				, rotation:rotation
				, x:xCoord
				, y:yCoord
				, z:zCoord
				, project_id:35498
				, system_id:_level0.officePlannerArray[i].attributes.SystemId._value
				, sku_id:_level0.officePlannerArray[i].attributes.SkuId._value
				, arrIndex:i
				, heightAdj:_level0.officePlannerArray[i].attributes.HeightAdj._value
			});
			
			// config items
			if(_level0.isElevPlanner !== 1){
				for(var j=0; j<_level0.officePlannerArray[i].below.length; j++){
					//_level0.consoleLog("*{*BELOW*}*");
					
					if(_level0.officePlannerArray[i].below[j].name == undefined){
						continue;
					}
					
					if(!_level0.officePlannerArray[i].below[j].attributes.FilePath3DModel._value){
						continue;
					}
				
					//_level0.consoleLog("below ypos: "+_level0.officePlannerArray[i].below[j].ypos);
					
					var belowXpos = new Number(_level0.officePlannerArray[i].below[j].xposft)*(_level0.onefoot*_level0.scalePercentage);
					var belowYpos = new Number(_level0.officePlannerArray[i].below[j].yposft)*(_level0.onefoot*_level0.scalePercentage);
					
					// computes the angle for an object below  in radians 
					var belowRad = Math.atan2(belowXpos, belowYpos);
					
					// comverting  degrees into radians for parent object
					var parentDeg = Number(_level0.officePlannerArray[i].rotate*90);
					var parentRad = (parentDeg) * Math.PI/180;
					
					// computes the distance / hypotenuse of an object below from the center ot the parent object
					var dist = Math.sqrt(( belowXpos*belowXpos )+( belowYpos*belowYpos ));
					
					// computes new x and y cordinates of an object below based on the angle of a parent object
					var newXpos = Math.sin(belowRad-parentRad)*dist;
					var newYpos = Math.cos(belowRad-parentRad)*dist;
					
					// converting coordinates from pixels to cm for lagoa 3d scene 
					var xCoord = ((_level0.officePlannerArray[i].xpos+newXpos) / (_level0.onefoot*_level0.scalePercentage*_level0.onefootScale)) * 12;
					var yCoord = 0;
					var zCoord = ((_level0.officePlannerArray[i].ypos+newYpos) / (_level0.onefoot*_level0.scalePercentage*_level0.onefootScale)) * 12;
					var rotation = Number(_level0.officePlannerArray[i].rotate*90) + Number(_level0.officePlannerArray[i].below[j].rotate*90);  // fixed on 01-29-16 M.S
					
					// this exception was added to avoid uploading the same asset multiple times.
					if(floorObjectMap[_level0.officePlannerArray[i].below[j].attributes.SkuId._value]){
						floorObject = floorObjectMap[_level0.officePlannerArray[i].below[j].attributes.SkuId._value];
					}
					else{
						floorObject = new FloorObject(broadcaster, _level0.officePlannerArray[i].below[j].attributes.FilePath3DModel._value);
						threed_floorObjects.push(floorObject);
						floorObjectMap[_level0.officePlannerArray[i].below[j].attributes.SkuId._value]=floorObject;
					}
					
					//_level0.consoleLog("*{*i AM HERE*}*");
					
					// add floor assets
					threed_assets.push({
						name:floorObject.fileName.toString()
						, rotation:rotation*-1
						, x:xCoord
						, y:yCoord
						, z:zCoord
						, project_id:35498
						, system_id:_level0.officePlannerArray[i].below[j].attributes.SystemId._value
						, sku_id:_level0.officePlannerArray[i].below[j].attributes.SkuId._value
						, arrIndex:i
						, below_arrIndex:j
						, heightAdj:_level0.officePlannerArray[i].below[j].attributes.HeightAdj._value
					});
					
				}
			}
		}
	}

	/**
	 * adds material objects into threed_materials[] array
	 * @return [description]
	 */
	public function populateMaterialsArray(){
		var o={};
		this.threed_materials = [];
		for(var i=0, l=this.threed_assets.length; i<l; i++){
			var system_id = this.threed_assets[i].system_id;
			if(!system_id || o[system_id]==1) continue;
			this.threed_materials.push(_level0._level0.systemMaterialMap[system_id]);
			o[system_id]=1;
		}
	}

	/**
	 * populate meshMaterialMap map object
	 * @return [description]
	 */
	public function populateMeshMaterialMapObject(){
		var o={}, s={}, sku_str="", system_str="";
		
		for(var i=0, l=this.threed_assets.length; i<l; i++){
			var system_id = this.threed_assets[i].system_id;
			var sku_id = this.threed_assets[i].sku_id;
			
			if(system_id && o[system_id] != 1)
			system_str += ","+system_id;

			if(sku_id && s[sku_id] != 1)
			sku_str += ","+sku_id;
			
			o[system_id]=1;
			s[sku_id]=1;
		}

		sku_str = sku_str.substr(1);
		system_str = system_str.substr(1);

		broadcaster.broadcastMessage("onDebug","System str: "+system_str);
		broadcaster.broadcastMessage("onDebug","Sku str: "+sku_str);

		ExternalInterface.call("AVThreed.getMeshMaterialMapData", system_str, sku_str);
	}


	/**
	 * launches threed scene
	 * @return [description]
	 */
	public function launchThreed(){
		broadcaster.broadcastMessage("onDebug","grid WIDTH: "+_level0.wid);
		broadcaster.broadcastMessage("onDebug","grid LEN: "+_level0.len);
		//ExternalInterface.call("AVThreed.buildThreed", threed_assets, _level0.wid, _level0.len);
		ExternalInterface.call("AVThreed.buildThreed", {floorArray:threed_assets, materialArray:threed_materials, wid:_level0.wid, len:_level0.len});
	}


	/**
	 * launches threed scene
	 * @return [description]
	 */
	public function launchThreed_notUsed(context){
		context.broadcaster.broadcastMessage("onDebug","launchthreed");
		if(context.threed_room.fileUploaded === true){
			context.broadcaster.broadcastMessage("onDebug","--FILE UPLOADED--");
			clearInterval(context.timer);
			ExternalInterface.call("AVThreed.buildThreed", context.threed_assets, _level0.wid, _level0.len);
		}

		
	}

	public function initLaunch_notUsed(){
		timer = setInterval(this,"launchThreed", 500, this);
	}

	/**
	 * using wall thickness, computes and returns 4 points (x,y) for each door/window from 2d view
	 * @return Array<Object-{ptA,ptB,ptC,ptD}> 
	 */
	public function computeAndReturnDoorOrWindowPoints(){
		
		var doorOrWindowPoints:Array = new Array();

		var debugStr:String;
		var _type:String;

		for (var i = 0; i < _level0.roomObjects.length; i++){

			if(_level0.roomObjects[i].name == undefined){
				continue;
			}

			_type=_level0.roomObjects[i].type;

			if(_level0.roomObjects[i].subType=="opening"){
				_type="opening";
			}

			var line = Number(_level0.roomObjects[i].Obj)+1;
			var lineBorder1:Array = new Array();
			var lineBorder2:Array = new Array();
			// window or door should be 1 or 2 inches thicker than the wall they are attached to.
			var calcWallThickness = line == 1 ? _level200.pixelConversion(6 / 12) : _level200.pixelConversion((_level225.linesArray[line][0][1]+1) / 12); // added 09/30/08 CW
			var w:Number = Math.round(Number(calcWallThickness.x));

			debugStr = 
					i+')data'
					+'\nname: ' +_level0.roomObjects[i].name
			 		+'\nline: ' +line
					+'\ntype: ' +_level0.roomObjects[i].type
					+'\nheight: ' +_level0.roomObjects[i].hei
					+'\nvdist: ' +_level0.roomObjects[i].vdist
					+'\nthickness: ' + w
					+'\ndir: ' + _level0.roomObjects[i].dir;

			broadcaster.broadcastMessage("onDebug",debugStr);


			var ang = Math.atan2(_level0.roomObjects[i].pt2Y-_level0.roomObjects[i].pt1Y,_level0.roomObjects[i].pt2X-_level0.roomObjects[i].pt1X);
			var ptA:Point = new Point( (_level0.roomObjects[i].pt1X + Math.cos(ang-Math.PI/2)*(w/2)), _level0.roomObjects[i].pt1Y + Math.sin(ang-Math.PI/2)*(w/2));
			var ptB:Point = new Point( (_level0.roomObjects[i].pt1X + Math.cos(ang+Math.PI/2)*(w/2)), _level0.roomObjects[i].pt1Y + Math.sin(ang+Math.PI/2)*(w/2));
			var ptC:Point = new Point( (_level0.roomObjects[i].pt2X + Math.cos(ang+Math.PI/2)*(w/2)), _level0.roomObjects[i].pt2Y + Math.sin(ang+Math.PI/2)*(w/2));
			var ptD:Point = new Point( (_level0.roomObjects[i].pt2X + Math.cos(ang-Math.PI/2)*(w/2)), _level0.roomObjects[i].pt2Y + Math.sin(ang-Math.PI/2)*(w/2));

			lineBorder1.push({pt1:ptA, pt2:ptD});
			lineBorder2.push({pt1:ptB, pt2:ptC});


			doorOrWindowPoints.push({
				line:line
				, point: Number(_level0.roomObjects[i].linePoint)+1
				, type:_type
				, height:Number(_level0.roomObjects[i].hei*12)
				, vdist:Number(_level0.roomObjects[i].vdist*12)
				, dir:_level0.roomObjects[i].dir
				, ptA:lineBorder1[0].pt1
				, ptB:lineBorder1[0].pt2
				, ptC:lineBorder2[0].pt2
				, ptD:lineBorder2[0].pt1
				
			});

		}

		return doorOrWindowPoints;
	}

	/**
	 * using wall thickness, computes and returns 4 points (x,y) for each wall from 2d view
	 * @return Array<Object-{ptA,ptB,ptC,ptD}> 
	 */
	public function computeAndReturnWallPoints(){

		var wallPoints:Array = new Array();

		for(var line = 1 ; line < _level225.linesArray.length; line++){
		//for(var line = 1 ; line < 2; line++){
			var lineBorder1:Array = new Array();
			var lineBorder2:Array = new Array();
			var calcWallThickness = line == 1 ? _level200.pixelConversion(5 / 12) : _level200.pixelConversion(_level225.linesArray[line][0][1] / 12); // added 09/30/08 CW
			var w:Number = Math.round(Number(calcWallThickness.x));

			for(var pt = 1; pt<_level225.linesArray[line].length; pt++){
				if(pt != _level225.linesArray[line].length-1){
				
					var ang = Math.atan2(_level225.linesArray[line][pt+1][1]-_level225.linesArray[line][pt][1],_level225.linesArray[line][pt+1][0]-_level225.linesArray[line][pt][0]);
					var ptA:Point = new Point( (_level225.linesArray[line][pt][0] + Math.cos(ang-Math.PI/2)*(w/2)), _level225.linesArray[line][pt][1] + Math.sin(ang-Math.PI/2)*(w/2));
					var ptB:Point = new Point( (_level225.linesArray[line][pt][0] + Math.cos(ang+Math.PI/2)*(w/2)), _level225.linesArray[line][pt][1] + Math.sin(ang+Math.PI/2)*(w/2));
					var ptC:Point = new Point( (_level225.linesArray[line][pt+1][0] + Math.cos(ang+Math.PI/2)*(w/2)), _level225.linesArray[line][pt+1][1] + Math.sin(ang+Math.PI/2)*(w/2));
					var ptD:Point = new Point( (_level225.linesArray[line][pt+1][0] + Math.cos(ang-Math.PI/2)*(w/2)), _level225.linesArray[line][pt+1][1] + Math.sin(ang-Math.PI/2)*(w/2));
					
					lineBorder1.push({pt:pt, pt1:ptA, pt2:ptD});
					lineBorder2.push({pt:pt, pt1:ptB, pt2:ptC});
					
				}
				else{
					if(_level225.linesArray[line][0][0]== "closed"){

						var ang = Math.atan2(_level225.linesArray[line][1][1]-_level225.linesArray[line][pt][1],_level225.linesArray[line][1][0]-_level225.linesArray[line][pt][0]);
						var ptA:Point = new Point( (_level225.linesArray[line][pt][0] + Math.cos(ang-Math.PI/2)*(w/2)), _level225.linesArray[line][pt][1] + Math.sin(ang-Math.PI/2)*(w/2));
						var ptB:Point = new Point( (_level225.linesArray[line][pt][0] + Math.cos(ang+Math.PI/2)*(w/2)), _level225.linesArray[line][pt][1] + Math.sin(ang+Math.PI/2)*(w/2));
						var ptC:Point = new Point( (_level225.linesArray[line][1][0] + Math.cos(ang+Math.PI/2)*(w/2)), _level225.linesArray[line][1][1] + Math.sin(ang+Math.PI/2)*(w/2));
						var ptD:Point = new Point( (_level225.linesArray[line][1][0] + Math.cos(ang-Math.PI/2)*(w/2)), _level225.linesArray[line][1][1] + Math.sin(ang-Math.PI/2)*(w/2));
						
						lineBorder1.push({pt:pt, pt1:ptA, pt2:ptD});
						lineBorder2.push({pt:pt, pt1:ptB, pt2:ptC});	
					}
				}	
			}

			var intersectPntCur1:Point; 
			var intersectPntPre1:Point; 
			
			var intersectPntCur2:Point; 
			var intersectPntPre2:Point; 
			
			var intersectPnt1:Point; 
			var intersectPnt2:Point;

			var intercept:Object;

			if(lineBorder2.length == 1){ // if one line segment
				//wallPoints.push({line:line, ptA:lineBorder2[0].pt1, ptB:lineBorder2[0].pt2, ptC:lineBorder1[0].pt2, ptD:lineBorder1[0].pt1});
				wallPoints.push({line:line, point:lineBorder2[0].pt,  ptA:lineBorder1[0].pt1, ptB:lineBorder1[0].pt2, ptC:lineBorder2[0].pt2, ptD:lineBorder2[0].pt1});
			}
			else{
				for(var i = 0 ; i< lineBorder2.length; i++){
					if(i == 0 ){
						if(_level225.linesArray[line][0][0] == "closed"){

							intercept = Calc.xy_Intercept(lineBorder2[i].pt1,lineBorder2[i].pt2,lineBorder2[lineBorder2.length-1].pt1,lineBorder2[lineBorder2.length-1].pt2);//(b2 - b1)/(m1 - m2); 
							
							intersectPnt2 =  new Point(intercept.xIntercept, intercept.yIntercept); 
							
							intercept = Calc.xy_Intercept(lineBorder2[i].pt1,lineBorder2[i].pt2,lineBorder2[i+1].pt1,lineBorder2[i+1].pt2);//(b2 - b1)/(m1 - m2); 
					
							intersectPntCur2 =  new Point(intercept.xIntercept, intercept.yIntercept);

							intercept = Calc.xy_Intercept(lineBorder1[i].pt1,lineBorder1[i].pt2,lineBorder1[lineBorder1.length-1].pt1,lineBorder1[lineBorder1.length-1].pt2);//(b2 - b1)/(m1 - m2);  

							intersectPnt1 =  new Point(intercept.xIntercept, intercept.yIntercept); 
							
							intercept = Calc.xy_Intercept(lineBorder1[i].pt1,lineBorder1[i].pt2,lineBorder1[i+1].pt1,lineBorder1[i+1].pt2);//(b2 - b1)/(m1 - m2);  
							
							intersectPntCur1 =  new Point(intercept.xIntercept, intercept.yIntercept); 
							
							wallPoints.push({line:line, point:lineBorder2[i].pt, ptA:intersectPnt1, ptB:intersectPntCur1, ptC:intersectPntCur2, ptD:intersectPnt2});
						}
						else{

							intercept = Calc.xy_Intercept(lineBorder2[i].pt1,lineBorder2[i].pt2,lineBorder2[i+1].pt1,lineBorder2[i+1].pt2);//(b2 - b1)/(m1 - m2);  
							
							intersectPntCur2 =  new Point(intercept.xIntercept, intercept.yIntercept); 

							intercept = Calc.xy_Intercept(lineBorder1[i].pt1,lineBorder1[i].pt2,lineBorder1[i+1].pt1,lineBorder1[i+1].pt2);//(b2 - b1)/(m1 - m2);  
							 
							intersectPntCur1 =  new Point(intercept.xIntercept, intercept.yIntercept); 
							
							//wallPoints.push({line:line, ptA:lineBorder1[i].pt1, ptB:lineBorder2[i].pt1, ptC:intersectPntCur2, ptD:intersectPntCur1});

							wallPoints.push({line:line, point:lineBorder2[i].pt, ptA:intersectPntCur1, ptB:intersectPntCur2, ptC:lineBorder2[i].pt1, ptD:lineBorder1[i].pt1});

							broadcaster.broadcastMessage("onDebug","debug1: "+line);
						}
					}
					else if( (i == lineBorder2.length-2 && _level225.linesArray[line][0][0] == "closed") || (i == lineBorder2.length-1 && _level225.linesArray[line][0][0] != "closed")){
						if (i == lineBorder2.length-2 && _level225.linesArray[line][0][0] == "closed"){

							intersectPntPre2 = intersectPntCur2; 

							intercept = Calc.xy_Intercept(lineBorder2[i].pt1,lineBorder2[i].pt2,lineBorder2[lineBorder2.length-1].pt1,lineBorder2[lineBorder2.length-1].pt2);//(b2 - b1)/(m1 - m2);

							intersectPntCur2 =  new Point(intercept.xIntercept, intercept.yIntercept);

							intersectPntPre1= intersectPntCur1; 

							intercept = Calc.xy_Intercept(lineBorder1[i].pt1,lineBorder1[i].pt2,lineBorder1[lineBorder2.length-1].pt1,lineBorder1[lineBorder2.length-1].pt2);//(b2 - b1)/(m1 - m2);  
							 
							intersectPntCur1 =  new Point(intercept.xIntercept, intercept.yIntercept); 

							wallPoints.push({line:line, point:lineBorder2[i].pt, ptA:intersectPntPre1, ptB:intersectPntCur1, ptC:intersectPntCur2, ptD:intersectPntPre2});

						}
						else{

							wallPoints.push({line:line, point:lineBorder2[i].pt, ptA:intersectPntCur1, ptB:lineBorder1[i].pt2, ptC:lineBorder2[i].pt2, ptD:intersectPntCur2});

							//wallPoints.push({line:line, ptA:intersectPntCur2, ptB:lineBorder2[i].pt2, ptC:lineBorder1[i].pt2, ptD:intersectPntCur1});
							
							broadcaster.broadcastMessage("onDebug","debug2: "+line);
						}
					}
					else if(i == lineBorder2.length-1 && _level225.linesArray[line][0][0] == "closed"){

						intersectPntPre2 = intersectPntCur2; 

						intercept = Calc.xy_Intercept(lineBorder2[i].pt1,lineBorder2[i].pt2,lineBorder2[0].pt1,lineBorder2[0].pt2);//(b2 - b1)/(m1 - m2);  
						
						intersectPntCur2 =  new Point(intercept.xIntercept, intercept.yIntercept); 

						intersectPntPre1 = intersectPntCur1; 
						
						intercept = Calc.xy_Intercept(lineBorder1[i].pt1,lineBorder1[i].pt2,lineBorder1[0].pt1,lineBorder1[0].pt2);//(b2 - b1)/(m1 - m2);  
					
						intersectPntCur1 =  new Point(intercept.xIntercept, intercept.yIntercept); 

						wallPoints.push({line:line, point:lineBorder2[i].pt, ptA:intersectPntPre1, ptB:intersectPntCur1, ptC:intersectPntCur2, ptD:intersectPntPre2});

						broadcaster.broadcastMessage("onDebug","debug3: "+line);
					}
					else if((i != 0) && (i != lineBorder2.length-1)) {

						intersectPntPre2 = intersectPntCur2; 

						intercept = Calc.xy_Intercept(lineBorder2[i].pt1,lineBorder2[i].pt2,lineBorder2[i+1].pt1,lineBorder2[i+1].pt2);//(b2 - b1)/(m1 - m2);  
					
						intersectPntCur2 =  new Point(intercept.xIntercept, intercept.yIntercept);

						intersectPntPre1 = intersectPntCur1; 

						intercept = Calc.xy_Intercept(lineBorder1[i].pt1,lineBorder1[i].pt2,lineBorder1[i+1].pt1,lineBorder1[i+1].pt2);//(b2 - b1)/(m1 - m2);  

						intersectPntCur1 =  new Point(intercept.xIntercept, intercept.yIntercept); 
							
						wallPoints.push({line:line, point:lineBorder2[i].pt, ptA:intersectPntPre1, ptB:intersectPntCur1, ptC:intersectPntCur2, ptD:intersectPntPre2}); 
					
						broadcaster.broadcastMessage("onDebug","debug4: "+line);
					}

				}
			}
		}
		
		return wallPoints;
	}
}