//user controller

var express = require('express'), 
	router = express.Router(), 
	chatModel = require('../models/chat'),
	socketCtrl = require('./socketCtrl');

var bodyParser = require('body-parser');
router.use( bodyParser.json() );       // to support JSON-encoded bodies
router.use(bodyParser.urlencoded({     // to support URL-encoded bodies
  extended: true
})); 


router.get('/:project_id', function(req, res) {
	var project_id = req.params.project_id;
	console.log("Request get chat for project_id : " + project_id);
	//add projects
	chatModel.get(project_id, function (err, messages) {
		if(err){
			res.send(err.message);
		}else{
			res.send(messages);
		}
	});
});

router.post('/:project_id', function(req, res) {
	var project_id = req.params.project_id;
	var body = req.body;
	console.log("Request add chat message to project_id : " + project_id );
	chatModel.create(project_id, body, function (err, message) {
		if(err){
			res.send(err.message);
		}else{
			res.send(message);
			socketCtrl.notifyProjectSubscribers(project_id, socketCtrl.CHAT_UPDATE_MESSAGE);
		}
	});
})

module.exports = router;