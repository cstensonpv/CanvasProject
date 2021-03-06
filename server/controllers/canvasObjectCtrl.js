//canvasObject controller

var express = require('express'),
	router = express.Router(),
	canvasObjectModel = require('../models/canvasObject'),
	socketCtrl = require('./socketCtrl');

var bodyParser = require('body-parser');

var bodyParser = require('body-parser');
router.use( bodyParser.json() );       // to support JSON-encoded bodies
router.use(bodyParser.urlencoded({     // to support URL-encoded bodies
  extended: true
})); 

function callback(err, result) {
	if(err){
		errorHandling(err);
	}else{
		res.send(result);
	}
}

function errorHandling(err) {
	var msg = err.message;
	if(msg == "type not supported"){
		return("Type not supported");
	}else{
		return(msg);
	}
}

// Post attached canvas object to specified project
router.post('/:project_id', function(req, res) {
	var body = req.body;
	var project_id = req.params.project_id;
	console.log("request to add canvasObj with params : "+ body);
	canvasObjectModel.addObject(project_id, body, function(err, result) {
		if(err){
			res.send(errorHandling(err));
		}else{
			res.send(result);
			socketCtrl.notifyProjectSubscribers(project_id, socketCtrl.CANVAS_OBJECT_UPDATE_MESSAGE);
		}
	});
});

// Update attached canvas object, finding the project ID and object ID in the object's data
router.put('/', function(req, res) {
	var params = req.body;
	var project_id = req.body.project_id;
	console.log("request to add canvasObj with params : "+ params);
	canvasObjectModel.updateObject(project_id, req.body, function(err, result) {
		if(err){
			res.send(errorHandling(err));
		}else{
			res.send(result);
			socketCtrl.notifyProjectSubscribers(project_id, socketCtrl.CANVAS_OBJECT_UPDATE_MESSAGE);
		}
	});
});

// Get specific canvas object in specified project
router.get('/:project_id/:object_id', function(req, res) {
	var object_id = req.params.object_id;
	var project_id = req.params.project_id;
	console.log("request to get canvasObj with id : "+ object_id);
	canvasObjectModel.get(project_id, object_id, function(err, result) {
		if(err){
			res.send(errorHandling(err));
		}else{
			res.send(result);
		}
	});
});

// Get all canvas object in specified project
router.get('/:project_id', function(req, res) {
	var project_id = req.params.project_id;
	console.log("request to get canvasObj with project_id : "+ project_id);
	canvasObjectModel.getAll(project_id, function(err, result) {
		if(err){
			res.send(errorHandling(err));
		}else{
			res.send(result);
		}
	});
});

// Delete specific object in specieied project
router.delete('/:project_id/:object_id', function(req, res) {
	var object_id = req.params.object_id;
	var project_id = req.params.project_id;
	console.log("request to delete canvasObj with object_id : "+ object_id);
	canvasObjectModel.delete(project_id, object_id, function(err, result) {
		if(err){
			res.send(errorHandling(err));
		}else{
			res.send(result);
			socketCtrl.notifyProjectSubscribers(project_id, socketCtrl.CANVAS_OBJECT_UPDATE_MESSAGE);
		}
	});
});

module.exports = router;