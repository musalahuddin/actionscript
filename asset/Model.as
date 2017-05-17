import threed.event.Broadcaster;

class threed.asset.Model{

	/**
	 * @var Broadcaster
	 */
	public var broadcaster:Broadcaster;

	/**
	 * @var String
	 * name of the obj file on the server
	 */
	public var fileName:String;

	/**
	 * @var Boolean
	 * flag 
	 */
	public var fileUploaded:Boolean = false;
	
	/**
	 * @var String
	 * this is where the obj files are created at on the server
	 */
	public var directory:String = 'objs';


	/**
	 * @var String
	 * obj data string
	 */
	public var OBJData:String;


	/**
	 * @var Boolean
	 * flag to remove objs from objs/ folder
	 */
	public var removeOBJ:Boolean;


	/**
	 * @var String
	 * OBJ path from the AV server
	 */
	public var OBJPath:String;

	/**
	 * @var Number
	 * folder id where objs go on LAGOA server
	 */
	public var projectId:Number;

	/**
	 * @constructor
	 * @param vertices [description]
	 */
	function Model(broadcaster:Broadcaster){

		this.broadcaster = broadcaster;

	}

	/**
	 * export floor to Obj
	 * @return void
	 */
	public function exportToOBJ():Void{

		var recVars:LoadVars = new LoadVars();
		recVars.context = this;
		recVars.onLoad = function(success:Boolean) {
			this.context.broadcaster.broadcastMessage("onExport",this.context);
			this.context.uploadOBJ();
		};
		
		var my_date:Date = new Date();
		var url = _level0.urlBoom+'url.php?action=gen&timeX='+my_date.getTime();
		var sendVars:LoadVars = new LoadVars();
		sendVars.file_body = OBJData;
		sendVars.file_name = 'threeD/'+directory+'/'+fileName;
		sendVars.sendAndLoad(url, recVars, "POST");

		// uncomment to debug
		//////////////////////////////
		//sendVars.send(url, "_blank", "POST");
		//////////////////////////////
	}

	/**
	 * upload obj to Lagoa Server
	 * @return void
	 */
	public function uploadOBJ():Void{

		broadcaster.broadcastMessage("onDebug",'uploading '+fileName+' .....');

		var recVars:LoadVars = new LoadVars();
		recVars.context = this;
		recVars.onLoad = function(success:Boolean) {
			this.context.fileUploaded=true;
			this.context.broadcaster.broadcastMessage("onUpload",this.context);
			if(this.context.removeOBJ == true){
				this.context.deleteOBJ();
			}
		};
		
		var my_date:Date = new Date();
		var url = _level0.urlBoom+'threeD/model_upload/url.php?timeX='+my_date.getTime();
		var sendVars:LoadVars = new LoadVars();
		sendVars.file_name = fileName;
		sendVars.file_path = OBJPath;
		sendVars.project_id = projectId;
		sendVars.sendAndLoad(url, recVars, "POST");
		
		// uncomment to debug
		//////////////////////////////
		//sendVars.send(url, "_blank", "POST");
		//////////////////////////////
	}


	/**
	 * Deletes file from the server
	 */
	public function deleteOBJ(){
		//return;
		var recVars:LoadVars = new LoadVars();
		recVars.context = this;
		recVars.onLoad = function(success:Boolean) {
			//file deleted
			//you can also broadcast del msg here.
			this.context.broadcaster.broadcastMessage("onDelete",this.context);
		};
		
		var my_date:Date = new Date();
		var url = _level0.urlBoom+'url.php?action=del&timeX='+my_date.getTime();
		var sendVars:LoadVars = new LoadVars();
		sendVars.file_name = 'threeD/'+directory+'/'+fileName;
		sendVars.sendAndLoad(url, recVars, "POST");

		// uncomment to debug
		//////////////////////////////
		//sendVars.send(url, "_blank", "POST");
		//////////////////////////////

	}
	
}