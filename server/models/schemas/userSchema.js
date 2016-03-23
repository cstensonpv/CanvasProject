//users.js mongoose schema definintion
var mongoose = require( 'mongoose' ); 

var UserSchema = new mongoose.Schema(
	{ 
		UserName : {type: String, required: true, unique: true},
		registered : { type: Date, default: Date.now } //Timezone is strange
	}
);

var User = mongoose.model('User', UserSchema);


//checks so username doesn't exists before save.
UserSchema.pre('save', function (next) {
    var self = this;
    User.find({UserName : self.UserName}, function (err, docs) {
        if (!docs.length){
            next();
        }else{                
            next(new Error("User exists!"));
        }
    });
}) ;

module.exports = User;

