// includes the connection and methods to insert, modify and delete users

var db = require( './db' );
 
CanvasObject = require('./schemas/canvasObjectSchema');
Project = require('./schemas/projectSchema');
// User = require('./schemas/userSchema');

exports.addObject = function(project_id, params, callback) {
	if (params.type = "text"){
		findProject(project_id, function(err, project) { //ensures that project exists
			if(project && params.project_id == project._id){
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
	findObject(params._id, params, function(err, object) {
		if(object){
			for (var k in object) {
				if(params[k]){
					object[k] = params[k];
				}
			}
			object.save(function(err, res){
				callback(err, res);
			})
		}else{
			callback(new Error("ObjectID doesn't exists!"))
		}	
	})	
}

exports.get = function(project_id, object_id, callback){
	var params = {};
	findObject(object_id, params, function(err, object){
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

exports.delete = function(project_id, object_id, callback){
	var params = {}; //dirty code
	findObject(object_id, params, function(err, object){
		if(!err){
			if (object.project_id == project_id) {
				object.remove(function(err, res) {
					callback(err, "succes");
				})
			}else{
				callback(new Error("Object not in project"))
			}
		}
		else{
			callback(err, object)
		}
	})
}

exports.getAll = function(project_id, callback){
	var objects ={};

	findObjects(project_id, callback);

	// CanvasObject.TextObject.find({project_id : project_id}, function (err, objects) {
	// 	if(objects){
	// 		callback(err, objects)
	// 	}else{
	// 		callback(new Error("objectsID doesn't exists!"), object);
	// 	}
	// });
} 

function addText(project, params, callback){
	var text = new CanvasObject.TextObject({
		project_id: project
		, position: {
			x: params.position.x
			, y: params.position.y
		}
		, dimensions: {
			width: params.dimensions.width
			, height: params.dimensions.height
		}
		, type : "text"
		, text : params.text
		, style : params.style
	})
	text.save(callback);
}

function addFile(project_id, params, callback){
	var file = new CanvasObject.FileObject({
		project_id: project_id
		, position: {
			x: params.position.x
			, y: params.position.y
		}
		, type : "file"
		, fileURI : params.fileURI
		, imageURI : params.imageURI
	})

	file.save(callback);
}

function findProject(project_id, callback) {
	Project.findById(project_id, function (err, project) {
		if(project){
			console.log("Found project: " + project.name)
			callback(err, project)
		}else{
			callback(new Error("ProjectID doesn't exists!"), project);
		}
	});
}

function findObject(object_id, params, callback) {
	CanvasObject.TextObject.findById(object_id, function (err, object) {
		if(object){
			callback(err, object)
		}else{
			callback(new Error("ObjectID doesn't exists!"), object);
		}
	});
}

function findObjects(project_id, callback) {
	var objects =[];
	CanvasObject.FileObject.find({project_id : project_id}, function (err, object) {
		objects.push.apply(objects, object);
		CanvasObject.TextObject.find({project_id : project_id}, function (err, object2) {
			if(object){
				objects.push.apply(objects, object2);
			}
			if(objects.length > 0){
				callback(err, objects)
			}else{
				callback(new Error("Project doesn't have any objects!"), objects);
			}
		});
		
	});
}
