import threed.asset.Model;
import threed.asset.Wall;
import threed.asset.Floor;
import threed.asset.Room;
import flash.external.ExternalInterface;

class threed.event.Listener{
	
	public var listener:Object;

	function Listener(){
		initListener();
	}

	public function initListener(){
		listener = new Object();

                // onExport
                listener.onExport = function(model:Model){
                        // add message here
                        var msg = 'exported '+model.fileName; 
                        ExternalInterface.call("consoleLog", msg);
                };

                // onUpload
                listener.onUpload = function(model:Model){
                        // add message here
                        var msg = 'uploaded '+model.fileName; 
                        ExternalInterface.call("consoleLog", msg);
                };

                // onUpload
                listener.onDelete = function(model:Model){
                        // add message here
                        var msg = 'deleted '+model.fileName; 
                        ExternalInterface.call("consoleLog", msg);
                };


                // onWallExport
                listener.onWallExport = function(wall:Wall){
                        // add message here
                        var msg = 'exported '+wall.fileName; 
                        ExternalInterface.call("consoleLog", msg);
                };

                // onWallUpload
                listener.onWallUpload = function(wall:Wall){
                        // add message here
                        var msg = 'uploaded '+wall.fileName; 
                        ExternalInterface.call("consoleLog", msg);
                };

		// onFloorExport
                listener.onFloorExport = function(floor:Floor){
                	// add message here
                	var msg = 'exported '+floor.fileName; 
                	ExternalInterface.call("consoleLog", msg);
                };

                // onFloorUpload
                listener.onFloorUpload = function(floor:Floor){
                	// add message here
                	var msg = 'uploaded '+floor.fileName; 
                	ExternalInterface.call("consoleLog", msg);
                };


                // onRoomExport
                listener.onRoomExport = function(room:Room){
                        // add message here
                        var msg = 'exported '+room.fileName; 
                        ExternalInterface.call("consoleLog", msg);
                };

                // onRoomUpload
                listener.onRoomUpload = function(room:Room){
                        // add message here
                        var msg = 'uploaded '+room.fileName; 
                        ExternalInterface.call("consoleLog", msg);
                };

                // onDebug
                listener.onDebug = function(msg:String){
                        ExternalInterface.call("consoleLog", msg);
                };

	}
}