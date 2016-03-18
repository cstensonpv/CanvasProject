# Test api-server

This server is used only as a proof of concept of how to build our application.
It is using a MongoDB on mLab on url:
```
'mongodb://cstenson:intnet16@ds015939.mlab.com:15939/intnet16'
```

## Installation

type 'npm install' in the testserver folder. All the node modules required for this project will automatically be installed.

## Get started
Start the server by typing 'node main.js' in the server root folder. The server is listening on port 8080.

## Documentation

### Test - Hello World

```
/test
```
returns to recipient

```javascript
Hello World
```
logs in server
```javascript
Hello World requested
```

### Add post to MongoDB

```
POST /add?name=<NAME(STR)>&size=<SIZE(INT)>
```

returns depending on succes

```javascript
Insert accepted!
```
or
```javascript
Error!!!
```
This feature is tested through chomre add-on POSTman.
### GET name

```
GET /get/<NAME>
```
returns an JSONobject with the data of the entry if it exists, otherwise "No such entry in th DB"

returns...

```javascript
{"_id":"56ec66c1dbd527182396be8e","name":"Calle","size":8,"__v":0}
```
or
```javascript
"No such entry in the DB"
```

### get data for a textBox

```
GET /testText/
```
returns a JSONObject of a textbox

#### Returns

```javascript
{
  "id" : "56ec18f4326ee43c15520eb3",
  "type" : "text",
  "position" : {
    "x" : 10,
    "y" : 10
  },
  "text" : "Test textruta",
  "style": "Header"
}

```

