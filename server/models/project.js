// includes the connection and methods to insert, modify and delete users

var db = require( './db' );
 
Project = require('./schemas/projectSchema');
User = require('./schemas/userSchema');


function findUser(UserName, callback) {
	User.find({'UserName' : UserName}, function (err, user) {
		if(user.length > 0 ){
		 	callback(err, user[0]);
		}else{
			callback(new Error("User doesn't exists!"), user);
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

exports.create = function(projectName, creator, callback) {
	//find the creator
	findUser(creator, function(err, creator){
	 	var project = new Project({
		   	'name' : projectName
		   	, 'creator' : creator
		   	, 'collaborators' : [creator]
	 	})
		project.save(callback);
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
							callback(err,project);
						})
					}else{
						console.log("No change");
						callback(new Error("User not in project!"), project);
					}
				});
			}else{
				callback(new Error("Your the last user in the project!"), project);
			}
		})
	});
}

exports.remove = function(project_id, callback) {
	findProject(project_id, function(err, project){
		Project.remove(callback(err,project));
	})
}

exports.get = function(project_id, callback) {
	findProject(project_id, function(err, project){
		callback(err, project);
	})
}