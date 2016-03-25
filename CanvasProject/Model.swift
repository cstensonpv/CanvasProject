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

class CanvasProjectModel {
	let notificationCenter = NSNotificationCenter.defaultCenter()
	var testValue: String = ""
	let username: String = "Mats"
	let userID: String = "1"
	var userNames = [String: String]()
	var userInfo = [JSON]()
	var currentProject: Project?
	
	let serverAddress: String = "130.229.153.14"
	let serverPort: String = "8080"
	let serverURI: String
	
	init() {
		serverURI = "http://" + serverAddress + ":" + serverPort
		switchProject(id: "56f29db6451cba0416cf06ee")
	}
	
	enum CanvasObjectType {
		case TextBox
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
	
	
	// API request functions
	
	func switchProject(id id: String) {
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

	func addCanvasObject(type: CanvasObjectType) {
		if let project = currentProject {
			let newCanvasObject: JSON
			
			switch type {
			case .TextBox:
				newCanvasObject = CanvasObjectPrototypes.textBox(project.id)
			}
			
			Alamofire.request(.POST, serverURI + "/canvasobject/" + project.id, parameters: newCanvasObject.dictionaryObject, encoding: .JSON).responseJSON {
				response in self.requestCanvasObjects()
			}
		}
	}
	
	func updateCanvasObject(objectData: JSON) {
		Alamofire.request(.PUT, serverURI + "/canvasObject/", parameters: objectData.dictionaryObject, encoding: .JSON).responseJSON {
			response in self.requestCanvasObjects()
		}
	}
	
	func deleteCanvasObject(id: String) {
		if let project = currentProject {
			print("Delete canvas object \(id)")
			Alamofire.request(.DELETE, serverURI + "/canvasObject/\(project.id)/\(id)").responseString { response in
				if let responseValue = response.result.value {
					if responseValue == "succes" { print("Successfully deleted"); self.requestCanvasObjects() }
					else { print("Couldn't delete"); print(responseValue) }
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
	
	func receiveProject(response: Response<AnyObject, NSError>) {
		if let responseValue = response.result.value {
			print("Project received")
			let projectData = JSON(responseValue)
			currentProject = Project(
				id: projectData["_id"].stringValue,
				name: projectData["name"].stringValue,
				creator: projectData["creator"].stringValue
			)
//			currentProject?.driveFolderName = projectData["DriveFolderName"].stringValue
			currentProject?.driveFolderID = projectData["driveFolderID"].stringValue
			print("Project drive folder ID:")
			print(projectData["driveFolderID"])
			requestDriveFolder()
			
			if let collaborators = projectData["collaborators"].array {
				for collaborator in collaborators {
					currentProject?.addCollaborator(collaborator.stringValue)
				}
			}
			
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
    
    func receiveDriveFolder(response: Response<AnyObject, NSError>) {
        if let responseValue = response.result.value {
            print("Drive folder info received")
            let folder = JSON(responseValue)
			for (_, file) in folder {
				currentProject?.addFile(file)
			}
			
			notificationCenter.postNotificationName("ReceivedFiles", object: nil)
        }
    }
	

}