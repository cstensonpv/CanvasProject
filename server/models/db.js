// Bring Mongoose into the app 
var mongoose = require( 'mongoose' ); 

// Build the connection string
var dbuser = "cstenson";
var dbpassword = "intnet16";

var dbURI = 'mongodb://' + dbuser + ':' + dbpassword + '@ds015939.mlab.com:15939/intnet16'; 


// Create the database connection 
mongoose.connect(dbURI); 

// CONNECTION EVENTS
// When successfully connected
mongoose.connection.on('connected', function () {  
  console.log('Mongoose default connection open to ' + dbURI);
}); 

// If the connection throws an error
mongoose.connection.on('error',function (err) {  
  console.log('Mongoose default connection error: ' + err);
}); 

// When the connection is disconnected
mongoose.connection.on('disconnected', function () {  
  console.log('Mongoose default connection disconnected'); 
});

// If the Node process ends, close the Mongoose connection 
process.on('SIGINT', function() {  
  mongoose.connection.close(function () { 
    console.log('Mongoose default connection disconnected through app termination'); 
    process.exit(0); 
  }); 
}); 

// BRING IN SCHEMAS & MODELS 

// console.log(User);
