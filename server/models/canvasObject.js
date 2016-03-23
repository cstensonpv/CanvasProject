// includes the connection and methods to insert, modify and delete users

var db = require( './db' );
 
CanvasObject = require('./schemas/canvasObjectSchema');
Project = require('./schemas/projectSchema');
// User = require('./schemas/userSchema');

exports.addObject = function(project_id, params, callback) {
	if (params.type = "text"){
		findProject(project_id, function(err, project) { //ensures that project exists
			console.log(project);
			if(project && params.project_id == project._id){
				console.log("sends to add text");
				addText(project, params, callback);
			}else{
				callback(new Error("object and project ide dosent match"))
			}
		})
		
	}else{
		callback(new Error("type not supported"));
	}
	 	
}

exports.updateObject = function(project_id, params, callback) {
	//nnot updating
	var conditions = { 
		project_id: project_id,
		_id : params._id
	}
	, update = params;
	if(params.type == "text") {
		console.log(params._id);
		findObject(params._id, function(err, object) {
			if(object){
				var objectL = object.lean();
				console.log(objectL);

				// for (var k in object) {
				// 	console.log(k+":");
				// 	// console.log(item[k]);
				// }
				// console.log(params.text);
				// console.log(object.style)

				object.text = params.text;
				console.dir(object);
				object.save(function(err, res){
					// console.log("save");
					// console.log(err);
					// console.log(res);
					// console.log(object);
					callback(err, res);

				})
			}else{
				callback(new Error("ObjectID doesn't exists!"))
			}
			
		})
		// CanvasObject.CanvasObject.find( {_id: params._id}, {$set : {"text" : params.text}}, function(err, res) {
		// 	if(!err){
		// 		console.log(res);
		// 		console.log("no error updating");
		// 		findObject(params._id, callback);
		// 	}else{
		// 		callback(err, res);
		// 	}
		// });
	}else if(params.type == "text") {
		console.log("File not iomplemented");
		callback(new Error("type not supported"));
	}else{
		callback(new Error("type not supported"));
	}
	
	// if (params.type = "text"){
	// 	findProject(project_id, function(err, project) { //ensures that project exists
	// 		console.log("sends to add text");
	// 		addText(project, params, callback);
	// 	})
		
	// }else{
	// 	callback(new Error("type not supported"));
	// }
	 	
}

exports.get = function(project_id, object_id, callback){
	findObject(object_id, function(err, object){
		if(!err){
			if (object.project_id == project_id) {
				callback(err, object);
			}else{
				callback(new Error("Object not in project"))
			}
		}
		else{
			callback(new Error("ObjectID doesn't exists!"))
		}
	})
}

exports.getAll = function(project_id, callback){
	CanvasObject.CanvasObject.find({project_id : project_id}, function (err, objects) {
		console.log(objects);
		if(objects){
			callback(err, objects)
		}else{
			callback(new Error("objectsID doesn't exists!"), object);
		}
	});
	// findObject(object_id, function(err, object){
	// 	if(!err){
	// 		if (object.project_id == project_id) {
	// 			callback(err, object);
	// 		}else{
	// 			callback(new Error("Object not in project"))
	// 		}
	// 	}
	// 	else{
	// 		callback(new Error("ObjectID doesn't exists!"))
	// 	}
	// })
} 
function addText(project, params, callback){
	var text = new CanvasObject.TextObject({
		project_id: project
		, position: {
			x: params.position.x
			, y: params.position.y
		}
		, type : "text"
		, text : params.text
		, style : params.style
	})
	// console.log(text);

	text.save(callback);
}

function addFile(project_id, params, callback){
	var text = new CanvasObject.FileObject({
		project_id: project_id
		, position: {
			x: params.position.x
			, y: params.position.y
		}
		, type : "text"
		, text : params.text
	})
	console.log(text);

	text.save(callback);
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

function findObject(object_id, callback) {
	CanvasObject.TextObject.findById(object_id, function (err, object) {
		console.log(object_id)
		if(object){
			callback(err, object)
		}else{
			callback(new Error("ObjectID doesn't exists!"), object);
		}
	});
}
// function findUser(UserName, callback) {
// 	User.find({'UserName' : UserName}, function (err, user) {
// 		if(user.length > 0 ){
// 		 	callback(err, user[0]);
// 		}else{
// 			callback(new Error("User doesn't exists!"), user);
// 		}
// 	})
// }

// function findProject(project_id, callback) {
// 	Project.findById(project_id, function (err, project) {
// 		if(project){
// 			callback(err, project)
// 		}else{
// 			callback(new Error("ProjectID doesn't exists!"), project);
// 		}
// 	});
// }

// exports.createText = function(projectName, creator, callback) {
// 	//find the creator
// 	findUser(creator, function(err, creator){
// 	 	var project = new Project({
// 		   	'name' : projectName
// 		   	, 'creator' : creator
// 		   	, 'colaborators' : [creator]
// 	 	})
// 		project.save(callback);
// 	})  	
// }

// exports.updateName = function(project_id, newName, callback) {
// 	findProject(project_id, function(err, project) {
// 		if(project){
// 			project.name = newName;
// 			project.save(callback);
// 		}else{
// 			callback(err, project);
// 		}
		
// 	})
// }

// exports.addColaborator = function(project_id, userName, callback) {
// 	findUser(userName, function(err, user) {
// 		findProject(project_id, function(err, project) {	
// 			Project.update({_id: project_id}, {$addToSet: {"colaborators" : user}}, function(err, status) {
// 				if(status.nModified > 0){
// 					findProject(project_id, function(err, project) {
// 						callback(err,project);
// 					})
// 				}else{
// 					callback(new Error("user already in project"), project);
// 				}
// 			})	
// 		})
// 	});
// }

// exports.removeColaborator = function(project_id, userName, callback) {
// 	findUser(userName, function(err, user) {
// 		findProject(project_id, function(err, project) {
// 			if(project.colaborators.length > 1){
// 				Project.update({_id: project_id}, {$pull: {"colaborators" : user._id}}, function(err, status) {
// 					if(status.nModified > 0){
// 						console.log(status);
// 						findProject(project_id, function(err, project) {
// 							callback(err,project);
// 						})
// 					}else{
// 						console.log("No change");
// 						callback(new Error("User not in project!"), project);
// 					}
// 				});
// 			}else{
// 				callback(new Error("Your the last user in the project!"), project);
// 			}
// 		})
// 	});
// }

// exports.remove = function(project_id, callback) {
// 	findProject(project_id, function(err, project){
// 		Project.remove(callback(err,project));
// 	})
// }

// exports.get = function(project_id, callback) {
// 	findProject(project_id, function(err, project){
// 		callback(err, project);
// 	})
// }