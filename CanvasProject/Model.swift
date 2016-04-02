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
	let username: String = "Mats"
	let userID: String = "1"
	var userNames = [String: String]()
	var userInfo = [JSON]()
	var allProjects = [JSON]()
	var currentProject: Project?
	var socket: SocketIOClient?

	let serverAddress: String = "192.168.0.10"
	let serverHTTPPort: String = "8080"
	let serverSocketPort: String = "8081"
	let serverURI: String
	let serverSocketURI: String
	
	init() {
		serverURI = "http://" + serverAddress + ":" + serverHTTPPort
		serverSocketURI = "http://" + serverAddress + ":" + serverSocketPort
		print("Model initialized")
	}
	
	enum CanvasObjectType {
		case TextBox
		case Rectangle
        case File
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
	
	func testJSONGet() {
		Alamofire.request(.GET, serverURI + "/get/test")
			.responseJSON { response in
					print(response.response)
				
					if let JSON = response.result.value {
						print(JSON)
					}
			}
	}
	
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
	
	func setupSocket() {
		socket = SocketIOClient(socketURL: NSURL(string: serverSocketURI)!)
		socket?.on("connect") {data, ack in
			print("Socket connected")
		}
		
		socket?.on("canvasObjectUpdate") { data, ack in
			print("Received notification of canvas object update")
			if self.currentProject != nil {
				self.requestCanvasObjects()
			}
		}
		
		socket?.on("projectsUpdate") { data, ack in
			self.requestProjects()
		}
		
		socket?.on("projectUpdate") { data, ack in
			if let currentProject = self.currentProject {
				self.openProject(id: currentProject.id)
			}
		}
		
		socket?.connect()
	}
	
	func closeProject() {
		print("Close project")
		currentProject = nil
	}
	
	
	// API request functions
	
	func requestProjects() {
		print("Request projects")
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
	
	func requestProjectUserInfo() {
		if let project = currentProject {
			userInfo.removeAll()
			userNames.removeAll()
			
			requestUserInfo(project.creator)
			
			for collaborator in project.collaborators {
				print("Requesting user info for collaborator " + collaborator)
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
	
	
	// API upload functions

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
                    print(data);
                    newCanvasObject = CanvasObjectPrototypes.file(project.id, data: data)
                    
                }
			}
            
            if let newCanvasObject = newCanvasObject {
                Alamofire.request(.POST, serverURI + "/canvasobject/" + project.id, parameters: newCanvasObject.dictionaryObject, encoding: .JSON)
            }
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
		print(id)
		print(text)
		if var objectData = currentProject?.getObject(id) {
			if objectData["type"].stringValue == "text" {
				print(objectData)
				objectData["text"] = JSON(text)
				updateCanvasObject(objectData)
			}
		}
	}
	
	
	// API response functions
	
	func receiveProjects(response: Response<AnyObject, NSError>) {
		print("received projects")
		print(response)
		if let responseValue = response.result.value {
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
			
			self.socket?.emit("subscribeToProject", self.currentProject!.id)
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
			print("image downloaded: \(image)")
			print("For fileID \(fileID)")
			
			notificationCenter.postNotificationName("ReceivedImage", object: nil)
		}
	}
	
    func receiveDriveFolder(response: Response<AnyObject, NSError>) {
        if let responseValue = response.result.value {
            print("Drive folder info received")
            let folder = JSON(responseValue)
//			print("Received files:")
//			print(folder)
			for (_, file) in folder {
				currentProject?.addFile(file)
			}

			notificationCenter.postNotificationName("ReceivedFiles", object: nil)
			requestFolderImages()
        }
    }
	

}