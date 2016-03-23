//test the canvas Object model

canvasObject = require('../../models/canvasObject')
console.log('Tries to insert text object in db')
var position = {"x":5 ,"y":5};
console.log(canvasObject.addObject(position, "text", {"text": "hello world"}, function(err, object) {
	console.log(err);
	console.log(object);
}
));
