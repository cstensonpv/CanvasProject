# Test api-server

This server is used in the interactiveCanvas project. A project wiuthin the scope of the course DD2390 at the Rotyal Institute of Technology.

It is using a MongoDB on mLab on url:
```
'mongodb://cstenson:intnet16@ds015939.mlab.com:15939/intnet16'
```

## Installation

type 'npm install' in the testserver folder. All the node modules required for this project will automatically be installed.

## Get started
Start the server by typing 'node app.js' in the server root folder. The server is listening on port 8080.

# Documentation

This documentation is used of me when implementing the back-end. I will try to go from the top down and mark which features that are implemented.

#Implemented till here!

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

### Add user
(No authentication added)

```
POST /user/<USERNAME>
```
returns Generated UserID if username isn't already taken

#####Example 

```
POST /user/userName
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
"userName taken"
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
GET /user/<USERNAME>
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
#Implemented to here

##Projects
#### JSON Structure
```javascript
```
### Add new Project
More than one project can have the same name. key är _id.
```
POST /project?name=<NAME>&creator=<USERNAME>
```
returns
```javascript
Object
```
### GET Project
Shoule be called every time a user access a project and should add the user to notifyObserver. Is done throug an middleware "userBelongsToProject". wich checks if the user is a collaborator to the project.
```
GET /project/:id
```
return if project exists
```javascript
Object
```
return if project dosen't exist
```
'Project dosen't exist'
```
### UPDATE Project Name
```
PUT /project/:<ID>?name=<NAME>
```
returns new project object
```javascript
Object
```
if project dosen't exist
```javascript
"Project dosen't exist"
```
### Delete Project
```
DELETE /project/<ID>
```
returns if successful
```javascript
succesful delete
```
if not succesfull
```javascript
'Something went wrong'
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
'user is already a collaborator'
```
### Remove collaborator
```
DELETE /project/<ID>/<UserName>
```
returns if successful
```javascript
Project object
```
if not succesfull
```javascript
'Something went wrong'
```

##CanvasObject
to be written

Add - POST  /canvasobject/:projectID/:type?param=xx&param=xx - returns Generated objectID if succesfull otherwise returns false
get one object - GET /canvasObject/:projectID/:objectID returns a single object
get all objects from project - GET /canvasObject/:projectID/ retruns all objects in the project
update - PUT /canvasObject/:projectID/:objectID?parameter=change(&paraeter=change) - (returns success??)
delete - DELETE /canvasObject/:projectID/:objectID - (returns succes??)