//
//  model.swift
//  CanvasProject
//
//  Created by Rasmus Berggrén on 2016-03-14.
//  Copyright © 2016 KTH. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

import SwiftyJSON
import SocketIOClientSwift

class CanvasProjectModel {
	let notificationCenter = NSNotificationCenter.defaultCenter()
	var testValue: String = ""
	var loggedInUser: JSON?
    var userID: String?
    var userNames = [String: String]()
	var userInfo = [JSON]()
	var allProjects = [JSON]()
	var currentProject: Project?
	var userSocket: SocketIOClient?
	var projectSocket: SocketIOClient?

	let serverAddress: String = "192.168.0.10"
	let serverHTTPPort: String = "8080"
	let serverSocketPort: String = "8081"
	let serverURI: String
	let serverSocketURI: String
	
	init() {
		serverURI = "http://" + serverAddress + ":" + serverHTTPPort
		serverSocketURI = "http://" + serverAddress + ":" + serverSocketPort
	}
	
	enum CanvasObjectType {
		case TextBox
		case Rectangle
        case File
	}
	
	enum APIErrorMessage: String {
		case Unknown = "Unknown API error"
		case UnknownProjectError = "Something went wrong"
		case UserNameTaken = "Username taken"
	}

	func test() {
		print("test")
	}
	
	func setTestValue(text: String) {
		testValue = text
		notificationCenter.postNotificationName("ReceivedData", object: nil)
	}
	
	func testStringGet() {
		Alamofire.request(.GET, serverURI + "/test")
			.responseString { response in
				print(response.request)
				print(response.response)
				print(response.data)
				print(response.result)
				
				if let resStr = response.result.value {
					self.setTestValue(resStr)
				}
			}
	}
	
//	func testJSONGet() {
//		Alamofire.request(.GET, serverURI + "/get/test")
//			.responseJSON { response in
//					print(response.response)
//				
//					if let JSON = response.result.value {
//						print(JSON)
//					}
//			}
//	}
//	
	func testJSONPost() {
		let parameters = [
			"foo": [1,2,3],
			"bar": [
				"baz": "qux"
			]
		]
		
		Alamofire.request(.POST, serverURI + "/post", parameters: parameters, encoding: .JSON)
			.responseString { response in
				if let str = response.result.value {
					self.setTestValue(str)
				}
			}
	}
	
	func setupUserSocket() {
		userSocket = SocketIOClient(socketURL: NSURL(string: serverSocketURI)!)
		userSocket?.on("connect") { data, ack in
			print("User socket connected")
			self.userSocket?.emit("subscribeToProjects")
		}
		
		userSocket?.on("projectsUpdate") { data, ack in
			self.requestProjectsForLoggedInUser()
		}
		
		userSocket?.on("projectUpdate") { data, ack in
			if let currentProject = self.currentProject {
				self.openProject(id: currentProject.id)
			}
		}
		
		userSocket?.connect()
	}
	
	func setupProjectSocket() {
		if let project = currentProject {
			projectSocket = SocketIOClient(socketURL: NSURL(string: serverSocketURI)!)
			projectSocket?.on("connect") { data, ack in
				print("Project socket connected")
				self.projectSocket!.emit("subscribeToProject", project.id)
			}
			
			projectSocket?.on("canvasObjectUpdate") { data, ack in
				print("canvas object update")
				if self.currentProject != nil {
					self.requestCanvasObjects()
				}
			}
            projectSocket?.on("chatUpdate") { data, ack in
                print("chat update")
                if (self.currentProject != nil) {
                    self.requestChatMessages()
                }
            }
			
			projectSocket?.connect()
			
		}
	}
	
	func login(username: String, callback: (userFound: Bool) -> Void) {
		checkUserName(username, callback: { response in
			switch response.result {
			case .Success:
				if let responseValue = response.result.value {
					let userInfo = JSON(responseValue)[0]
					self.loggedInUser = userInfo
					self.userID = userInfo["_id"].stringValue
					print("Logging in. Setting userID = \(self.userID)")
					self.setupUserSocket()
					callback(userFound: true)
				} else {
					self.logout()
					callback(userFound: false)
				}
			case .Failure:
				self.logout()
				callback(userFound: false)
			}
		})
	}
	
	func logout() {
        print("logout!!!")
		loggedInUser = nil
		userID = nil
		userSocket?.disconnect()
	}
	
	func closeProject() {
		print("Close project")
		currentProject = nil
		projectSocket?.disconnect()
	}
	
	func requestProjectsForLoggedInUser() {
		if let userID = self.userID {
			requestProjects(forUserID: userID)
		} else {
			print("No user logged in. Can't request projects for logged in user")
		}
	}
	
	
	// API request functions
	
	func requestProjects(forUserID userID: String) {
		print("Requesting projects for user ID: \(userID)")
		Alamofire.request(.GET, serverURI + "/project/forUser/" + userID).responseJSON {
			response in self.receiveProjects(response)
		}
	}
	
	func requestAllProjects() {
		Alamofire.request(.GET, serverURI + "/project/all/").responseJSON {
			response in self.receiveProjects(response)
		}
	}
	
	func openProject(id id: String) {
		print("Switch project")
		Alamofire.request(.GET, serverURI + "/project/" + id).responseJSON {
			response in self.receiveProject(response)
		}
	}
	
	func requestCanvasObjects() {
		if let project = currentProject {
			Alamofire.request(.GET, serverURI + "/canvasObject/" + project.id).responseJSON {
				response in self.receiveCanvasObjects(response)
			}
		}
	}
	
	func checkUserName(username: String, callback: Response<AnyObject, NSError> -> Void) {
		let userInfo = ["username": username]
		print(userInfo)
		Alamofire.request(.POST, serverURI + "/user/userNameQuery/", parameters: userInfo, encoding: .JSON).responseJSON(completionHandler: callback)
	}
	
	func requestProjectUserInfo() {
		if let project = currentProject {
			userInfo.removeAll()
			userNames.removeAll()
			
			requestUserInfo(project.creator)
			
			for collaborator in project.collaborators {
				requestUserInfo(collaborator)
			}
		}
	}
	
	func requestUserInfo(userID: String) {
		Alamofire.request(.GET, serverURI + "/user/" + userID).responseJSON {
			response in self.receiveUserInfo(response)
		}
	}
	
	func requestFolderImages() {
		if let project = currentProject {
			for file in project.getFiles() {
				requestThumbnail(file["thumbnailLink"].stringValue, forFileID: file["id"].stringValue)
			}
		}
	}
	
	func requestThumbnail(imageURL: String, forFileID fileID: String) {
		Alamofire.request(.GET, imageURL).responseImage { response in
				switch response.result {
				case .Success: self.receiveImage(response, forFileID: fileID)
				case .Failure: self.requestIcon(forFileID: fileID)
			}
		}
	}
	
	func requestIcon(forFileID fileID: String) {
		if let file = currentProject?.getFile(fileID) {
			Alamofire.request(.GET, file["iconLink"].stringValue).responseImage {
				response in self.receiveImage(response, forFileID: fileID)
			}
		}
	}
	
	func requestDriveFolder() {
		if let project = currentProject {
			if let folderID = project.driveFolderID {
				Alamofire.request(.GET, serverURI + "/files/" + folderID).responseJSON {
					response in self.receiveDriveFolder(response)
				}
			}
		}
	}
	
    func requestChatMessages() {
        if let project = currentProject {
            Alamofire.request(.GET, serverURI + "/chat/" + project.id).responseJSON {
                response in self.receiveChatMessages(response)
            }
            
        }
    }
	
	// API upload functions

	func registerUser(username: String, callback: (response: String) -> Void) {
		let userInfo = ["username": username]
		print(userInfo)
		
		Alamofire.request(.POST, serverURI + "/user/", parameters: userInfo, encoding: .JSON)
			.responseJSON(completionHandler: { response in
				if let responseValue = response.result.value {
					let newUser = JSON(responseValue)
					if newUser["error"].stringValue == APIErrorMessage.UserNameTaken.rawValue {
						callback(response: APIErrorMessage.UserNameTaken.rawValue)
					} else {
						callback(response: newUser["UserName"].stringValue)
					}
				} else {
					callback(response: APIErrorMessage.Unknown.rawValue)
				}
			}
		)
	}
	
	func addProject(withName projectName: String, callback: (response: String) -> Void) {
		let parameters = [
			"name": projectName,
			"creator": userID!
		]
		
		Alamofire.request(.POST, serverURI + "/project/", parameters: parameters, encoding: .JSON).responseJSON { response in
			if let responseValue = response.result.value {
				let newProject = JSON(responseValue)
				
				if newProject["error"].stringValue == APIErrorMessage.UnknownProjectError.rawValue {
					callback(response: APIErrorMessage.UnknownProjectError.rawValue)
				} else {
					callback(response: newProject["_id"].stringValue)
				}
			} else {
				callback(response: APIErrorMessage.Unknown.rawValue)
			}
		}
	}
 
	func addCanvasObject(type: CanvasObjectType, data: JSON? = nil) {
		if let project = currentProject {
			var newCanvasObject: JSON?
			
			switch type {
			case .TextBox:
				newCanvasObject = CanvasObjectPrototypes.textBox(project.id)
			case .Rectangle:
				newCanvasObject = CanvasObjectPrototypes.rectangle(project.id)
            case .File:
                if let data = data {
                    newCanvasObject = CanvasObjectPrototypes.file(project.id, data: data)
                    
                }
			}
            
            if let newCanvasObject = newCanvasObject {
                Alamofire.request(.POST, serverURI + "/canvasobject/" + project.id, parameters: newCanvasObject.dictionaryObject, encoding: .JSON)
            }
		}
	}
    
    func addChatMessage(newMessage: String){
        var newChatMessage: JSON?
        
        /*let userName = loggedInUser!["Username"]
        
        print(userName)*/
        print("username of loggedinuser")
        print(self.loggedInUser)
        print(self.userNames)
        
        
        
        if let project = currentProject {
            print("i project")
            print(loggedInUser);
            
            newChatMessage = ChatMessagePrototype.chatMessage(self.loggedInUser!["_id"].stringValue, message: newMessage)
            Alamofire.request(.POST, serverURI + "/chat/" + project.id, parameters: newChatMessage!.dictionaryObject, encoding: .JSON)
            
        }else {
            print("no project")
        }
        
        
        
    }
	
	func updateCanvasObject(objectData: JSON) {
		Alamofire.request(.PUT, serverURI + "/canvasObject/", parameters: objectData.dictionaryObject, encoding: .JSON)
	}
	
	func deleteCanvasObject(id: String) {
		if let project = currentProject {
			print("Delete canvas object \(id)")
			Alamofire.request(.DELETE, serverURI + "/canvasObject/\(project.id)/\(id)").responseString { response in
				if let responseValue = response.result.value {
					if responseValue != "success" { print("Couldn't delete"); print(responseValue) }
				}
				
			}
		}
	}
	
	func registerCanvasObjectMovement(id: String, x: Float, y: Float) {
		if var objectData = currentProject?.getObject(id) {
			objectData["position"]["x"] = JSON(x)
			objectData["position"]["y"] = JSON(y)
			updateCanvasObject(objectData)
		}
	}
	
	func registerCanvasObjectResize(id: String, width: Float, height: Float) {
		if var objectData = currentProject?.getObject(id) {
			objectData["dimensions"]["width"] = JSON(width)
			objectData["dimensions"]["height"] = JSON(height)
			updateCanvasObject(objectData)
		}
	}
	
	func registerCanvasObjectText(id: String, text: String) {
		print("Register canvas object text")
		if var objectData = currentProject?.getObject(id) {
			if objectData["type"].stringValue == "text" {
				objectData["text"] = JSON(text)
				updateCanvasObject(objectData)
			}
		}
	}
	
	
	// API response functions
	
	func receiveProjects(response: Response<AnyObject, NSError>) {
		if let responseValue = response.result.value {
			allProjects.removeAll()
			
			for (_, project) in JSON(responseValue) {
				allProjects.append(project)
			}
			
			notificationCenter.postNotificationName("ReceivedProjects", object: nil)
		}
	}
	
	func receiveProject(response: Response<AnyObject, NSError>) {
		if let responseValue = response.result.value {
			print("Project received")
			let projectData = JSON(responseValue)
			currentProject = Project(
				id: projectData["_id"].stringValue,
				name: projectData["name"].stringValue,
				creator: projectData["creator"].stringValue
			)
			currentProject?.driveFolderID = projectData["driveFolderID"].stringValue
			print("Project drive folder ID:")
			print(projectData["driveFolderID"])
			requestDriveFolder()
			
			if let collaborators = projectData["collaborators"].array {
				for collaborator in collaborators {
					currentProject?.addCollaborator(collaborator.stringValue)
				}
			}
			
			setupProjectSocket()
			notificationCenter.postNotificationName("ReceivedProject", object: nil)
		}
	}
	
	func receiveCanvasObjects(response: Response<AnyObject, NSError>) {
        if let responseValue = response.result.value {
			print("Canvas objects received")
            let objects = JSON(responseValue)
            currentProject?.resetObjects()
            for (_,object):(String, JSON) in objects {
                currentProject?.addObject(object)
            }
			
            notificationCenter.postNotificationName("ReceivedCanvasObjects", object: nil)
        }
		
	}
	
	func receiveUserInfo(response: Response<AnyObject, NSError>) {
		if let responseValue = response.result.value {
			print("User info received")
			let user = JSON(responseValue)
			userInfo.append(user)
			userNames[user["_id"].stringValue] = user["UserName"].stringValue
			
			notificationCenter.postNotificationName("ReceivedUserInfo", object: nil)
		}
	}
	
	func receiveImage(response: Response<Image, NSError>, forFileID fileID: String) {
		if let image = response.result.value {
			currentProject?.addImage(image, forFileID: fileID)
			
			notificationCenter.postNotificationName("ReceivedImage", object: nil)
		}
	}
	
    func receiveDriveFolder(response: Response<AnyObject, NSError>) {
        if let responseValue = response.result.value {
            print("Drive folder info received")
            let folder = JSON(responseValue)
			for (_, file) in folder {
				currentProject?.addFile(file)
			}

			notificationCenter.postNotificationName("ReceivedFiles", object: nil)
			requestFolderImages()
        }
    }
    
    func receiveChatMessages(response: Response<AnyObject, NSError>) {
        if let responseValue = response.result.value {
            print("Chat Messages received")
           
            let rawResponse = JSON(responseValue)

			if let messages = rawResponse["chatMessages"].array {
				currentProject?.addMessages(messages)
				notificationCenter.postNotificationName("ReceivedChatMessages", object: nil)
			}
			
        }
    }
	

}