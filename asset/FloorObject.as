import threed.event.Broadcaster;
import threed.asset.Model;
import threed.utility.Calc;

class threed.asset.FloorObject extends Model{

	/**
	 * @constructor
	 */
	function FloorObject(broadcaster:Broadcaster, objPath:String){

		super(broadcaster);
		// base class fields
		//this.fileName = new String("floorObject_"+(Math.round(Math.random()*9999999999))+".obj");
		this.fileName = new String("floorObject_"+Calc.generateRandomString(10)+".obj");
		this.projectId = 35498;
		this.OBJPath = '../../'+ objPath;
		this.removeOBJ = false;
	}
}