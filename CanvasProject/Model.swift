//
//  model.swift
//  CanvasProject
//
//  Created by Rasmus Berggrén on 2016-03-14.
//  Copyright © 2016 KTH. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CanvasProjectModel {
	let notificationCenter = NSNotificationCenter.defaultCenter()
	var testValue: String = ""
	let username: String = "Mats"
	let userID: String = "1"
	var userNames = [String: String]()
	var userInfo = [JSON]()
	var currentProject: Project?
	
	let serverAddress: String = "130.229.155.130"
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
	func addCanvasObject(type: CanvasObjectType) {
		if let project = currentProject {
			let newCanvasObject: [String : NSObject]
			
			switch type {
			case .TextBox:
				newCanvasObject = CanvasObjectPrototypes.textBox(project.id)
			}
			
			Alamofire.request(.POST, serverURI + "/canvasobject/" + project.id, parameters: newCanvasObject, encoding: .JSON).responseJSON {
				response in self.requestCanvasObjects()
			}
		}
	}
	
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
				requestUserInfo(collaborator)
			}
		}
	}
	
	func requestUserInfo(userID: String) {
		Alamofire.request(.GET, serverURI + "/user/" + userID).responseJSON {
			response in self.receiveUserInfo(response)
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
			
			if let collaborators = projectData["collaborators"].array {
				for collaborator in collaborators {
					currentProject?.addCollaborator(collaborator.stringValue)
				}
			}
			
			requestProjectUserInfo()
			
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
	

}