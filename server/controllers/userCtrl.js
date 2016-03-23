//user controller

var express = require('express')
  	, router = express.Router()
  	, userModel = require('../models/user')


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
})

router.post('/:UserName', function(req, res) {
	console.log("Request add user : " + req.params.UserName);
	userModel.create(req.params.UserName, function (err, user) {
		if(err){
			res.send("userName taken!");
		}else{
    		res.send(user);
		}
  	});
})

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

	})
})

router.delete('/:UserName', function(req, res) {
	console.log("Request delete of user : " + req.params.UserName);
	var UserName = req.params.UserName;
	userModel.remove(UserName, function(err) {
		if(err){
			res.send("failure")
		}else{
			res.send("success");
		}
	})
})

module.exports = router;