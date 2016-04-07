// includes the connection and methods to insert, modify and delete users

var db = require( './db' );
 
Project = require('./schemas/projectSchema');
User = require('./schemas/userSchema');

var userModel = require('../models/user');


function findUser(userID, callback) {
	console.log("Finding user ID: " + userID);
	userModel.get(userID, function(err, user) {
		console.log("Search result: ");
		if (user) {
			callback(err, user);
		} else {
			callback(new Error("User doesn't exists!"), user);
		}
	});
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

function findAllProjects(callback) {
	Project.find({}, function(err, projects) {
		if (projects) {
			callback(err, projects)
		} else {
			callback(new Error("Couldn't return all projects"), projects)
		}
	});
}

function findProjectsForUser(userID, callback) {
	Project.find({'collaborators': userID}, function(err, projects) {
		if (projects) {
			callback(err, projects)
		} else {
			callback(new Error("Couldn't return all projects"), projects)
		}
	});
}

exports.create = function(projectName, creatorID, callback) {
	//find the creator
	console.log("Creator ID is: " + creatorID);
	findUser(creatorID, function(err, creator) {
		if (err) {
			callback(err, null)
		} else {
			console.log(creatorID)
			var project = new Project({
				'name': projectName, 
				'creator': creatorID, 
				'collaborators': [creatorID]
			});

			console.log(project);
			project.save(callback);
		}
		
	})  	
}

exports.updateName = function(project_id, newName, callback) {
	findProject(project_id, function(err, project) {
		if(project){
			project.name = newName;
			project.save(callback);
		}else{
			callback(err, project);
		}
		
	})
}

// exports.updateFolder = function(project_id, folderName, callback) {
// 	findProject(project_id, function(err, project) {
// 		if(project){
// 			project.name = newName;
// 			project.save(callback);
// 		}else{
// 			callback(err, project);
// 		}
		
// 	})
// }

//UpdateDriveFolder

exports.addCollaborator = function(project_id, userName, callback) {
	findUser(userName, function(err, user) {
		findProject(project_id, function(err, project) {	
			Project.update({_id: project_id}, {$addToSet: {"collaborators" : user}}, function(err, status) {
				if(status.nModified > 0){
					findProject(project_id, function(err, project) {
						callback(err,project);
					})
				}else{
					callback(new Error("user already in project"), project);
				}
			})	
		})
	});
}

exports.removeCollaborator = function(project_id, userName, callback) {
	findUser(userName, function(err, user) {
		findProject(project_id, function(err, project) {
			if(project.collaborators.length > 1){
				Project.update({_id: project_id}, {$pull: {"collaborators" : user._id}}, function(err, status) {
					if(status.nModified > 0){
						console.log(status);
						findProject(project_id, function(err, project) {
							callback(err, project, user._id);
						})
					}else{
						console.log("No change");
						callback(new Error("User not in project!"), project, null);
					}
				});
			}else{
				callback(new Error("Your the last user in the project!"), project, null);
			}
		})
	});
}

exports.remove = function(project_id, callback) {
	findProject(project_id, function(err, project){
		project.remove(callback);
	});
}

exports.get = function(project_id, callback) {
	findProject(project_id, function(err, project){
		callback(err, project);
	})
}

exports.getAll = function(callback) {
	findAllProjects(function(err, projects) {
		callback(err, projects);
	});
}

exports.getForUser = function(userID, callback) {
	findProjectsForUser(userID, function(err, projects) {
		callback(err, projects);
	});
}