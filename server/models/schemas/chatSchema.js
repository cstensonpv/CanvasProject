//users.js mongoose schema definintion
var mongoose = require( 'mongoose' ); 

var ChatSchema = new mongoose.Schema(
	{ 
		UserID : {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'users'
        }
        , message : {type: String, required: true}
        , project_id: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Project'
        }
		, posted : { type: Date, default: Date.now } //Timezone is strange
	}
);

var ChatMessage = mongoose.model('Chat', ChatSchema);


module.exports = ChatMessage;

