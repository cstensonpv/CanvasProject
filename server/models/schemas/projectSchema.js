//users.js mongoose schema definintion
var mongoose = require( 'mongoose' ); 

function arrayLimit(val) {
  return val.length > 0;
}

var ProjectSchema = new mongoose.Schema(
	{ 
		name : {type: String, required: true}
		, creator : {
			type: mongoose.Schema.Types.ObjectId,
        	ref: 'User' 
        }
		, registred : { type: Date, default: Date.now } //Timezone is strange
		, collaborators : {
			type :[{
				type: mongoose.Schema.Types.ObjectId,
        		ref: 'User', unique: true
        	}]
    	}
	}
);



var Project = mongoose.model('Project', ProjectSchema);

module.exports = Project;

