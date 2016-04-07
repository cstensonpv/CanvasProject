// includes the connection and methods to insert, modify and delete users

var db = require( './db' );
 
ChatMessage = require('./schemas/chatSchema');
Project = require('./schemas/projectSchema');


exports.create = function(project_id, body, callback) {
	findProject(project_id, function(err, project) {
		if(project) {
		  	var chatMessage = new ChatMessage({
		    	'UserID' : body.UserID,
		    	'message' : body.message,
		    	'project_id' : project_id
		    	// ,'registred': '2015-02-16'
		  	})
		 	chatMessage.save(callback);
		} else {
			callback(err, project);
		}
	})
}


exports.get = function(project_id, callback) {
	var err;
	findProject(project_id, function(err, project) { //checks so project is valid

		if(project){
			ChatMessage.find({'project_id' : project_id} , function (err, messages) {
				if(messages.length > 0){
					callback(err, {"chatMessages": messages });
				}else{
					callback(new Error("Project doesn't have any messages!"),messages);
				}
			}).sort({posted: 'ascending'}); //sorted in ascending. so newest message comes last

		} else {
			callback(err, project);
		}
	})
}

function findProject(project_id, callback) {
	Project.findById(project_id, function (err, project) {
		if(project){
			callback(err, project)
		}else{
			callback(new Error("ProjectID doesn't exists!"), project);
		}
	});
}
