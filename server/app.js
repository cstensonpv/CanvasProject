//Check express.json


var express = require('express')
  , app = express()

// app.set('view engine', 'jade')

// app.use(require('./middlewares/users'))
app.use(require('./controllers'))

app.listen(3000, function() {
  console.log('Listening on port 3000...')
})