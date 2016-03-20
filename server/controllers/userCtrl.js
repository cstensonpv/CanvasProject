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
	console.log("Request add user : " + req.params.UserName);
	userModel.create(req.params.UserName, function (err, user) {
		if(err){
			res.send("userName taken!");
		}else{
    		res.send(user);
		}
  	});
})
module.exports = router;