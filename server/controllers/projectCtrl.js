//user controller

var express = require('express'),
	router = express.Router(),
	projectModel = require('../models/project'),
	socketCtrl = require('./socketCtrl');

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
	}else {
		return "Something went wrong";
	}
}

// Get specified project data
router.get('/:project_id', function(req, res) {
	var project_id = req.params.project_id;
	console.log("Request get project : " + project_id);
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
	var name = req.headers.name;
	var creator = req.headers.creator;
	console.log("Request add project : " + name + " creator :" + name);
	projectModel.create(name, creator ,function (err, project) {
		// console.log(err);
		if(err){
			res.send(errHandling(err));
		}else{
    		res.send(project);
		}
  	});
});

// Change name for specified project
router.put('/:project_id', function(req, res) {
	var name = req.headers.name;
	var id = req.params.project_id;
	console.log("Request update of projectName : " + name + " id: " + id );
	projectModel.updateName( id, name, function (err, project) {
		if(err){
			res.send(errHandling(err));
		}else{
			res.send(project);
			socketCtrl.notifyProjectSubscribers(id, socketCtrl.PROJECT_UPDATE_MESSAGE);
		}

	});
});

// Add new collaborator to specified project
router.put('/:project_id/:newCollaborator', function(req, res) {
	var userName = req.params.newCollaborator;
	var id = req.params.project_id;
	console.log("Request add user to project : " + userName + " project id: " + id );
	projectModel.addCollaborator( id, userName, function (err, project) {
		if(err){
			errHandling(err);
		}else{
			res.send(project);
			socketCtrl.notifyProjectSubscribers(id, socketCtrl.PROJECT_UPDATE_MESSAGE);
		}
	});
});

// Delete specified collaborator from specified project
router.delete('/:project_id/:newCollaborator', function(req, res) {
	var userName = req.params.newCollaborator;
	var id = req.params.project_id;
	console.log("Request delete user from project : " + userName + " project id: " + id );
	projectModel.removeCollaborator( id, userName, function (err, project) {
		if(err){
			errHandling(err);
		}else{
			res.send(project);
			socketCtrl.notifyProjectSubscribers(id, socketCtrl.PROJECT_UPDATE_MESSAGE);
		}
	});
});

// Delete specified project
router.delete('/:project_id', function(req, res) {
	var project_id = req.params.project_id;
	console.log("Request delete of project : " + project_id);
	projectModel.remove(project_id, function(err) {
		if(err){
			res.send("failure")
		}else{
			res.send("success");
		}
	});
});

module.exports = router;