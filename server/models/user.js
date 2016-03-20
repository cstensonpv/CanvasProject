// includes the connection and methods to insert, modify and delete users

var db = require( './db' );
 
User = require('./schemas/userSchema');

exports.create = function(userName,callback) {
  	var user = new User({
    	'UserName' : userName
    	// ,'registred': '2015-02-16'
  	})
  	var err;
 	user.save(callback);
}

exports.update = function(id, userName, callback) {
	User.findById(id, function (err, user) {
		if(user){
			user.UserName = userName;
			user.save(callback);
		}else{
			callback(new Error("UserID doesn't exists!"),user);
		}
	});
}

exports.remove = function(userName, callback) {
	console.log(id);
	console.log(userName);
	User.find({'UserName' : userName}, function (err, user) {
		console.log(user)
		user.save(callback);
	});
}