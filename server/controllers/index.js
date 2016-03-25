//index.js initial setup, loads controllers and define paths without common prefixs

var express = require('express'),
	router = express.Router(),
	drive = require('../helpers/googleDrive')

router.use('/user', require('./userCtrl'))
router.use('/project', require('./projectCtrl'))
router.use('/canvasObject', require('./canvasObjectCtrl'))

router.get('/files/:folder_name', function(req, res){
	var folder_name = req.params.folder_name;
	console.log("request files");
	drive.authorize(folder_name, function(err, files){
		if(!err){
			res.send(files)
		}else{
			res.send(err)
		}
	})

})


module.exports = router;