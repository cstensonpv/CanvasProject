//middlewares for user
//NOT USED! added in the actual schema instead!
// Users = require('./../models/schemas/userSchema').User
// UserSchema = require('./../models/schemas/userSchema').UserSchema
// // console.log(User);
// // console.log(UserSchema);

// module.exports = function(req, res, next) {
// 	UserSchema.pre('save', function (next) {
// 	    var self = this;
// 	    Users.find({UserName : self.UserName}, function (err, docs) {
// 	        if (!docs.length){
// 	            next();
// 	        }else{                
// 	            next(new Error("User exists!"));
// 	        }
// 	    });
// 	}) ;
// 	next();
// }