


//Check express.json should be included in controllers


var express = require('express')
  , app = express()
var server_port = 8080;
var server_ip_address = '127.0.0.1';


// app.set('view engine', 'jade')

app.use(require('./controllers'))

app.listen(server_port, function() {
  console.log('Listening on port ' + server_port + '...')
})