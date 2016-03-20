//user controller

var express = require('express')
  	, router = express.Router()
  	, userModel = require('../models/user')

// router.get('/test', function(req, res) {
// 	res.send("Hello World");
// 	// console.log(req);
// 	console.log("Hello World requested");
// });

router.post('/:UserName', function(req, res) {
	console.log(req.params);
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
	userModel.update(req.headers._i, req.headers.username, function (err, user) {
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
	console.log(req.params);
	// userModel.remove(UserName, function(err) {
	// 	if(err){
	// 		res.send("failure")
	// 	}else{
	// 		res.send("success");
	// 	}
	// })
})

module.exports = router;