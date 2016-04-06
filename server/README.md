# INteractive canvas api-server

This server is used in the interactiveCanvas project. A project wiuthin the scope of the course DD2390 at the Rotyal Institute of Technology.

It is using a MongoDB on mLab on url:
```
'mongodb://cstenson:intnet16@ds015939.mlab.com:15939/intnet16'
```

## Installation

type 'npm install' in the server folder. All the node modules required for this project will automatically be installed.

## Get started
Start the server by typing 'npm start' in the server root folder which start the app.js file. The server is listening on port 8080.

# Documentation

This documentation is used of me when implementing the back-end. I will try to go from the top down and mark which features that are implemented.



## Users

### JSON structure

```
{
  "_id": "56ee9cac4eb7f89c051cc950",
  "UserName": "UserName22",
  "__v": 0,
  "registred": "2016-03-20T12:50:52.632Z"
}
```
### Get user
```
GET /user/name/<USERNAME>
```
returns 
```javascript
{
  "__v": 0,
  "UserName": "UserName",
  "_id": "56ee9cac4eb7f89c051cc950",
  "registred": "2016-03-20T12:50:52.632Z"
}
```

### Add user
(No authentication added)

```
POST /user
```
Parameters
```javascript
{
  "username": <username>
}
```
returns Generated UserID if username isn't already taken

#####Example 

```
POST /user
```
returns
```javascript
{
  "__v": 0,
  "UserName": "UserName",
  "_id": "56ee9cac4eb7f89c051cc950",
  "registred": "2016-03-20T12:50:52.632Z"
}
```
Then if we try to do it again
```
POST /user/userName
```
returns
```javascript
{
  "error": "Username taken"
}
``` 

### Update user
```
PUT /user?param=value(&param2=value2)>
```
(the params are the serialization of the JSON Object from swift. 

Hopefully I can get how this one looks when you try to send it.)

#####Example
Update username "UserName" to "UserName22"
id from UserName, and UserName is the new UserName.
```
PUT /user?_id=56ee9cac4eb7f89c051cc950&username=UserName22
```
returns new User objecty (if UserName22 is not already taken)
```javascript
{
  "_id": "56ee9cac4eb7f89c051cc950",
  "UserName": "UserName22",
  "__v": 0,
  "registred": "2016-03-20T12:50:52.632Z"
}
```
returns (if UserName22 is already taken)
```javascript
Username taken!
```
returns (if unvalid _id is submitted)
```javascript
UserID doesn't exists!
```


###Delete user
```
DELETE /user/<UserName>
```
returns:
```javascript
'succes'
or
'failure'
```
### Get user
```
GET /user/<USERID>
```
returns if user exists
```javascript
{
    "_id": "56eee1825c517ac01ff3f33c",
    "UserName": "userName",
    "__v": 0,
    "registred": "2016-03-20T17:44:34.044Z"
}
```
or if no user with the userName exists
```
'User does not exists'
```

##Project
#### JSON Structure
```javascript
{
  "_id": "56efb7772ae164b8261aa26f",
  "name": "test",
  "creator": "Calle",
  "__v": 0,
  "colaborators": [
    "56ef023e1c37e4a80538f828"
  ],
  "registred": "2016-03-21T08:57:27.757Z"
}
```
### Add new Project
More than one project can have the same name. key är _id.
Creator is checked that it is a user in the system. saved as the reference to the user of the creator.
```
POST /project?name=<NAME>&creator=<USERNAME>
```
(vi bör kunna identifiera creator på vem som skickade requesten från början??)
returns
```javascript
{
  "__v": 0,
  "name": "test2",
  "creator": {
    "_id": "56efbffde10fad5411928ab7",
    "UserName": "Rasmus",
    "__v": 0,
    "registred": "2016-03-21T09:33:49.982Z"
  },
  "_id": "56efeb5d02141fb418181bfe",
  "colaborators": [
    {
      "_id": "56efbffde10fad5411928ab7",
      "UserName": "Rasmus",
      "__v": 0,
      "registred": "2016-03-21T09:33:49.982Z"
    }
  ],
  "registred": "2016-03-21T12:38:53.082Z"
}
```
### GET All projects
Called to get all information on all projects
```
GET /project/all
```
Return if projects are found
```javascript
[
	{
	"_id": ObjectId("56f29db6451cba0416cf06ee"),
	"name": "test project",
	"creator": ObjectId("56ef023e1c37e4a80538f828"),
	"collaborators": [
	ObjectId("56ef023e1c37e4a80538f828"),
	ObjectId("56efbffde10fad5411928ab7")
	],
	"registered": new Date(1458740662204),
	"__v": 0,
	"driveFolderID": "0B2pgS6-ccOOGQ29CLUNSRW9mYnc"
	},
	{
	...
	},
	...
]

```
Return if projects couldn't be found
```
'Couldn't return all projects'
```
### GET Project
Shoule be called every time a user access a project and should add the user to notifyObserver. Is done throug an middleware "userBelongsToProject". wich checks if the user is a collaborator to the project.???
```
GET /project/<ID>
```
return if project exists
```javascript
{
  "_id": "56efb7772ae164b8261aa26f",
  "name": "test",
  "creator": "Calle",
  "__v": 0,
  "colaborators": [
    "56ef023e1c37e4a80538f828"
  ],
  "registred": "2016-03-21T08:57:27.757Z"
}
```
return if project dosen't exist
```
'Project dosen't exist'
```
### UPDATE Project Name
```
PUT /project/<ID>?name=<NAME>
```
returns new project object
```javascript
{
  "_id": "56efeb5d02141fb418181bfe",
  "name": "test3",
  "creator": "56efbffde10fad5411928ab7",
  "__v": 0,
  "colaborators": [
    "56efbffde10fad5411928ab7"
  ],
  "registred": "2016-03-21T12:38:53.082Z"
}
```
if project dosen't exist
```javascript
"Wrong project_id!"
```
### Delete Project
```
DELETE /project/<ID>
```
returns if successful
```javascript
succes
```
if not succesfull
```javascript
failure
```
### Add collaborator
```
PUT /project/<ID>/<UserName>
```
returns if successful
```javascript
Project object
```
if not succesfull
```javascript
'user dosen't exist'
```
or
```javascript
'user is already a colaborator'
```
### Remove collaborator
```
DELETE /project/<ID>/<UserName>
```
Can't remove if it is the last user in colaborators
returns if successful
updated project obj
```javascript
{
  "_id": "56efed49de4e9df42329f9b7",
  "name": "test3",
  "creator": "56ef023e1c37e4a80538f828",
  "__v": 0,
  "colaborators": [
    "56ef023e1c37e4a80538f828"
  ],
  "registred": "2016-03-21T12:47:05.313Z"
}
```
if not succesfull
```javascript
'Something went wrong'
'User not in project'

```
#Implemented to here


##CanvasObject
The actual objects that are added to the canvas

###Add object
```
POST  /canvasobject/<PROJECTID>?param=xx&param=xx
```
send the JSON object in the body of the request

returns if succesful
```javascript
{
  "__v": 0,
  "project_id": {
    "_id": "56f0f535d027bbb8081db536",
    "name": "test4",
    "creator": "56ef023e1c37e4a80538f828",
    "colaborators": [
      "56ef023e1c37e4a80538f828"
    ],
    "__v": 0,
    "collaborators": [],
    "registred": "2016-03-22T07:33:09.972Z"
  },
  "position": {
    "y": 100,
    "x": 10
  },
  "dimensions": {
    "height": 10,
    "width": 100
  },
  "type": "text",
  "style": "Header",
  "text": "Ny text222!!!",
  "_id": "56f27e0957b131e818fe92ea",
  "registered": "2016-03-23T11:29:13.366Z"
}
```
if error
```javascript
Specified error
```
###GET a canvasObject
```
GET /canvasObject/<PROJECTID>/<OBJECTID>
```
returns if object exists
```javascript
{
  "_id": "56f1984bfd1d65bc208ff685",
  "project_id": "56f0f535d027bbb8081db536",
  "position": {
    "x": 10,
    "y": 10
  },
  "type": "text",
  "registred": "2016-03-22T19:08:59.045Z",
  "__v": 0,
  "style": "Header",
  "text": "Test textruta333",
  "registered": "2016-03-23T11:30:28.113Z"
}
```
else
```javascript
error msg
```

### GET all canvasObject within a project
```
GET /canvasObject/<PROJECTID>/
```
returns
```javascript
[
  {
    "_id": "56f1984bfd1d65bc208ff685",
    "project_id": "56f0f535d027bbb8081db536",
    "position": {
      "x": 10,
      "y": 10
    },
    "type": "text",
    "registred": "2016-03-22T19:08:59.045Z",
    "__v": 0,
    "style": "Header",
    "text": "Test textruta333",
    "registered": "2016-03-23T11:31:01.823Z"
  },
  {
    "_id": "56f1998c6b05643423834b0c",
    "project_id": "56f0f535d027bbb8081db536",
    "position": {
      "x": 10,
      "y": 10
    },
    "type": "text",
    "registred": "2016-03-22T19:14:20.434Z",
    "__v": 0,
    "style": "Header",
    "text": "Test 33",
    "registered": "2016-03-23T11:31:01.823Z"
  },
  ...
 
]
```
### UPDATE canvas object
```
PUT /canvasObject/?parameter=change(&parameter=change)
```
parameters are included in the body where you add the modified JSON object, or only the fields you want to update;
returns new object if succesfull
```javascript
{
  "dimensions": {
    "height": 10,
    "width": 100
  },
  "_id": "56f1984bfd1d65bc208ff685",
  "project_id": "56f0f535d027bbb8081db536",
  "position": {
    "x": 1000,
    "y": 1000
  },
  "type": "text",
  "registred": "2016-03-22T19:08:59.045Z",
  "__v": 0,
  "style": "Header",
  "text": "Ny tehadshkfjsdkjfkjxt222!!!",
  "registered": "2016-03-23T11:34:08.204Z"
}
```
if not succesfull it returns the old object, without the change or an error.
```javascript
canvasObject
```
###DELETE canvas object
```
DELETE /canvasObject/<PROJECTID>/<OBJECTID>
```
returns
```javascript
succes
```
or
```
error msg
```