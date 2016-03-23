//test the canvas Object model



canvasObject = require('../../models/canvasObject')
// console.log('Tries to insert text object in db')
// var position = {"x":5 ,"y":5};
// console.log(canvasObject.addObject(position, "text", {"text": "hello world"}, function(err, object) {
// 	console.log(err);
// 	console.log(object);
// }
// ));
var http = require('http')
var options = {
	host : "localhost",
	path : "canvasObject/text",
	port : "8080",
	method : "POST"
}

callback = function(response) {
  var str = ''
  response.on('data', function (chunk) {
    str += chunk;
  });

  response.on('end', function () {
    console.log(str);
  });
}

var req = http.request(options, callback);
req.write("hello world");
req.end();



var text = {
	"id" : "56ec18f4326ee43c15520eb3",
	"type" : "text",
	"position" : {
		"x" : 10,
		"y" : 10
	},
	"text" : "Test textruta",
	"style": "Header"
}
