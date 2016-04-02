var express = require('express'),
	router = express.Router(),
	server = require('http').createServer(express()),
	io = require('socket.io')(server);

exports.PROJECT_UPDATE_MESSAGE = "projectUpdate";
exports.PROJECTS_UPDATE_MESSAGE = "projectsUpdate";
exports.CANVAS_OBJECT_UPDATE_MESSAGE = "canvasObjectUpdate";

server.listen(8081);

io.on('connection', function(client) {
	console.log('Client connected via socket');
	  
	client.on('subscribeToProject', function(projectID) {
		console.log("Client subscribed to project " + projectID);
		client.join(projectID)
	});

	client.on('subscribeToProjects', function() {
		console.log("Client subscribed to projects list updates etc");
		client.join('projects');
	});
});

exports.notifyProjectSubscribers = function(projectID, message) {
	console.log("Notifying subscribers to " + projectID + ": " + message);
	io.to(projectID).emit(message);
}

exports.notifyAllSubscribers = function(message) {
	console.log("Notifying all subscribers: " + message);
	io.emit(message);
}