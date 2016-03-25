//index.js initial setup, loads controllers and define paths without common prefixs

var express = require('express'),
	router = express.Router(),
	drive = require('../helpers/googleDrive'),
	http = require('http').Server(express),
	io = require('socket.io')(http);

router.use('/user', require('./userCtrl'))
router.use('/project', require('./projectCtrl'))
router.use('/canvasObject', require('./canvasObjectCtrl'))

router.get('/files/:folder_id', function(req, res){
	var folder_id = req.params.folder_id;
	console.log("request files");
	drive.authorize(folder_id, function(err, files){
		if(!err){
			res.send(files)
		}else{
			res.send(err)
		}
	})

})

io.on('connection', function(socket){
  console.log('a user connected');
});


module.exports = router;