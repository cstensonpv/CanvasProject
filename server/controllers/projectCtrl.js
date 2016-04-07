//user controller

var express = require('express'),
	router = express.Router(),
	projectModel = require('../models/project'),
	userModel = require('../models/user'),
	socketCtrl = require('./socketCtrl');

var bodyParser = require('body-parser');
router.use(bodyParser.json());       // to support JSON-encoded bodies
router.use(bodyParser.urlencoded({     // to support URL-encoded bodies
  extended: true
})); 

function errHandling(err){
	var msg = err.message;
	if(msg == "ProjectID doesn't exists!") {
		return "ProjectID doesn't exists!";
	}else if (msg == "ProjectID doesn't exists!") {
		return "ProjectID doesn't exists!";
	}else if (msg == "User doesn't exists!") {
		return "User doesn't exists!";
	}else if (msg == "user already in project") {
		return "user already in project";
	}else if (msg == "User not in project!") {
		return "User not in project!";
	}else if(msg == "Your the last user in the project!") {
		return "Your the last user in the project!";
	}else if(msg == "Couldn't return all projects") {
		return "Couldn't return all projects";
	}else {
		return "Something went wrong";
	}
}

// Get all projects
router.get('/all', function(req, res) {
	console.log("Request get all projects");
	projectModel.getAll(function(err, projects) {
		if (err) {
			res.send(errHandling(err));
		} else {
			res.send(projects);
		}
	});
});

// Get projects where the specified user is a collaborator
router.get('/forUser/:userID', function(req, res) {
	var userID = req.params.userID;
	console.log("Request projects for user ID: " + userID);
	projectModel.getForUser(userID, function(err, projects) {
		if (err) {
			res.send(errHandling(err));
		} else {
			res.send(projects);
		}
	});
});

// Get specified project data
router.get('/:project_id', function(req, res) {
	var project_id = req.params.project_id;
	console.log("Request get project: " + project_id);
	projectModel.get(project_id, function (err, project) {
		// console.log(project);
		if(err){
			res.send(errHandling(err));
			// console.log(err);
		}else{
			res.send(project);
		}
	});
});

// Post new project
router.post('/', function(req, res) {
	var name = req.body.name;
	var creator = req.body.creator;
	console.log("Request add project with name: " + name + " creator:" + creator);
	projectModel.create(name, creator, function(err, project) {
		// console.log(err);
		if(err){
			console.log("Error adding project: " + err);
			res.send({"error": errHandling(err)});
		}else{
			res.send(project);
			socketCtrl.notifyUsers(project.collaborators, socketCtrl.PROJECTS_UPDATE_MESSAGE);
		}
	});
});

// Change name for specified project
router.put('/:project_id', function(req, res) {
	var name = req.headers.name;
	var id = req.params.project_id;
	console.log("Request update of projectName: " + name + " id: " + id );
	projectModel.updateName( id, name, function (err, project) {
		if(err){
			res.send(errHandling(err));
		}else{
			res.send(project);
			socketCtrl.notifyUsers(project.collaborators, socketCtrl.PROJECTS_UPDATE_MESSAGE);
			socketCtrl.notifyProjectSubscribers(project._id, socketCtrl.PROJECT_UPDATE_MESSAGE);
		}

	});
});

// Add new collaborator to specified project
router.put('/:project_id/:newCollaborator', function(req, res) {
	var userName = req.params.newCollaborator;
	var id = req.params.project_id;
	console.log("Request add user to project: " + userName + " project id: " + id );
	projectModel.addCollaborator( id, userName, function (err, project) {
		if(err){
			errHandling(err);
		}else{
			res.send(project);
			socketCtrl.notifyUsers(project.collaborators, socketCtrl.PROJECTS_UPDATE_MESSAGE);
			socketCtrl.notifyProjectSubscribers(project._id, socketCtrl.PROJECT_UPDATE_MESSAGE);
		}
	});
});

// Delete specified collaborator from specified project
router.delete('/:project_id/:username', function(req, res) {
	var userName = req.params.username;
	var project_id = req.params.project_id;
	console.log("Request delete user from project: " + userName + " project id: " + project_id );
	projectModel.removeCollaborator(project_id, userName, function(err, project, removedUserID) {
		if (err) {
			errHandling(err);
		} else {
			res.send(project);
			socketCtrl.notifyUsers(project.collaborators, socketCtrl.PROJECTS_UPDATE_MESSAGE);
			socketCtrl.notifyUsers([removedUserID], socketCtrl.PROJECTS_UPDATE_MESSAGE);
			socketCtrl.notifyProjectSubscribers(project._id, socketCtrl.PROJECT_UPDATE_MESSAGE);
		}
	});
});

// Delete specified project
router.delete('/:project_id', function(req, res) {
	var project_id = req.params.project_id;
	console.log("Request delete of project : " + project_id);
	projectModel.get(project_id, function(err, project) { // First, find the project, in order to get its collaborators
		if (err) {
			res.send("Project deletetion failed"); // if it wasn't found, return error
		} else { 
			projectModel.remove(project_id, function(err) { // if it was found, try to delete it
				if(err){
					res.send("Project deletetion failed")
				}else{
					res.send("Project deleted"); 
					// Notify the previous collaborators and current subscribers of update
					socketCtrl.notifyUsers(project.collaborators, socketCtrl.PROJECTS_UPDATE_MESSAGE);
					socketCtrl.notifyProjectSubscribers(project_id, socketCtrl.PROJECT_UPDATE_MESSAGE);
				}
			});
		}
	});
});

module.exports = router;