// var http = require('http');
var express = require('express');
var port = 3000;

// var https = require('https');
// var privateKey  = fs.readFileSync('sslcert/server.key', 'utf8');
// var certificate = fs.readFileSync('sslcert/server.crt', 'utf8');

// var credentials = {key: privateKey, cert: certificate};
//var httprequest = require('./httprequest');
var app = express();

var mongoose = require('mongoose');

var db = mongoose.connection;

db.on('error', console.error);
db.once('open', function() {
  // Create your schemas and models here.
 	

  // Compile a 'Movie' model using the movieSchema as the structure.
  // Mongoose also creates a MongoDB collection called 'Movies' for these documents.
});

var schema = new mongoose.Schema({ name: 'string', size: 'number' });
var Tank = mongoose.model('Tank', schema);

mongoose.connect('mongodb://localhost/test');


// ];
app.get('/test', function(req, res) {
	res.send("Hello World");
	console.log("Hello World requested");
});

app.get('/add', function(req, res) {
	//res.send("Add Page");
	// console.log(req.query.hej);

	var thor = new Tank({
	  name: req.query.name,
	  size: req.query.size
	});
	console.log(thor);

	thor.save(function(err, thor) {
	  if (err){
	  	res.send("Error!!!")
	  	return console.error(err);
	  } else{
	  	res.send("Inserted accepted");
	  }
	  //console.dir(thor);
	});
});

app.get('/get/:name', function(req, res){
	console.log(req.params.name);
	Tank.findOne({ name: req.params.name }, function(err, result) {
	  if (err) return console.error(err);
	  console.log("result");
	  console.dir(result);
	  res.send(result);

	});
	
})

var server = app.listen(port);
console.log("Server is now listening on port " + port);