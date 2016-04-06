//user controller

var express = require('express'), 
	router = express.Router(), 
	userModel = require('../models/user');

var bodyParser = require('body-parser');
router.use(bodyParser.json());       // to support JSON-encoded bodies
router.use(bodyParser.urlencoded({     // to support URL-encoded bodies
  extended: true
})); 

function errorJSON(errorString) {
	var errorJSON = {
		error: errorString
	};

	return errorJSON;
}

// Get user into based on user ID
router.get('/:user_id', function(req, res) {
	var user_id = req.params.user_id;
	console.log("Request get user : " + user_id);
	userModel.get(user_id , function (err, user) {
		if(err && err.message == "User doesn't exists!"){
			res.send("'User does not exists'");
		}else{
			res.send(user);
		}
	});
});

// Get user info based on username
router.get('/name/:username', function(req, res) {
	var username = req.params.username;
	console.log("Request get user with username: " + username);
	userModel.getFromUsername(username, function(err, user) {
		if (err || user.length == 0) {
			res.send("User doesn't exist");
		} else {
			res.send(user)
		}
	});
});

// Add user
router.post('/', function(req, res) {
	var username = req.body.username;
	console.log("Request add user: " + username);
	userModel.create(username, function (err, user) {
		if(err){
			console.log("Username taken");
			res.send(errorJSON("Username taken"));
		}else{
			res.send(user);
		}
	});
});

// Update user using information in body
router.put('/', function(req, res) {
	console.log("Request update of user : " + req.headers.username);
	userModel.update(req.headers._id, req.headers.username, function (err, user) {
		if(err){
			if(err.message == "User exists!") {
				res.send("Username taken!")
			}else if(err.message == "UserID doesn't exists!") {
				res.send("UserID doesn't exists!")
			}else {
				res.send("Something went wrong!")
			} 
		}else{
			res.send(user);
		}

	});
});

// Delete user with specified username
router.delete('/:UserName', function(req, res) {
	console.log("Request delete of user : " + req.params.UserName);
	var UserName = req.params.UserName;
	userModel.remove(UserName, function(err) {
		if(err){
			res.send("failure")
		}else{
			res.send("success");
		}
	});
});

module.exports = router;