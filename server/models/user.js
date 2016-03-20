// includes the connection and methods to insert, modify and delete users

var db = require( './db' );
 
User = require('./schemas/userSchema');

exports.create = function(userName,callback) {
  	var user = new User({
    	'UserName' : userName
    	// ,'registred': '2015-02-16'
  	})
  	var err;
 	user.save( user,callback);
}