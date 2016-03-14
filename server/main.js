// var http = require('http');
var express = require('express');
//var httprequest = require('./httprequest');
var app = express();


// ];
app.get('/test', function(req, res) {
	res.send("Hello World");
});

var server = app.listen(3000);
console.log("Server is now listening on port 3000");