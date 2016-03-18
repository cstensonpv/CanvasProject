//index.js initial setup, loads controllers and define paths without common prefixs

var express = require('express'),
	router = express.Router();

router.use('/user', require('./userCtrl'))
//router.use('/project', require('./projectCtrl'))
// router.use('/canvasObject', require('./canvasObjectCtrl'))


module.exports = router;