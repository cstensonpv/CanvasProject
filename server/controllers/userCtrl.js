//user controller

var express = require('express')
  , router = express.Router()
  // , Comment = require('../models/comment')

router.get('/test', function(req, res) {
	res.send("Hello World");
	// console.log(req);
	console.log("Hello World requested");
});

module.exports = router;