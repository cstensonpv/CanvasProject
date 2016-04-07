//users.js mongoose schema definintion
var mongoose = require( 'mongoose' ); 

var ProjectSchema = new mongoose.Schema(
	{ 
		name : {type: String, required: true}
		, creator : {
			type: mongoose.Schema.Types.ObjectId,
        	ref: 'User' 
        }
		, registered : { type: Date, default: Date.now } //Timezone is strange
		, collaborators : {
			type :[{
				type: mongoose.Schema.Types.ObjectId,
        		ref: 'User', unique: true
        	}]
    	}
    	, driveFolderID : {type: String}
	}
);



var Project = mongoose.model('Project', ProjectSchema);

module.exports = Project;

