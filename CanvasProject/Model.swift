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
	var currentProject: Project?
	let serverAddress: String = "192.168.0.11"
	let serverPort: String = "8080"
	let serverURI: String
	
	init() {
		serverURI = "http://" + serverAddress + ":" + serverPort
		createNewProject()
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
	
	func addTextBox() {
		Alamofire.request(.GET, serverURI + "/testText").responseJSON {
			response in self.requestObjects(response)
		}
	}
	
	func createNewProject() {
		self.currentProject = Project(id: "1", name: "Test project", creator: self.userID)
	}
	
	func requestObjects(response: Response<AnyObject, NSError>) {
		Alamofire.request(.GET, serverURI + "/testText").responseJSON {
			response in self.receiveObjects(response)
		}
	}
	
	func receiveObjects(response: Response<AnyObject, NSError>) {
        if response.result.value != nil {
            let objects = JSON(response.result.value!)
            currentProject?.resetObjects()
            for (_,object):(String, JSON) in objects {
                currentProject?.addObject(object)
            }
            notificationCenter.postNotificationName("ReceivedData", object: nil)
        }
            
            
            
//			for var object in objects as! [[String: NSObject]] {
//			var object = objects
//				switch object["type"] as! String {
//				case "text":
//					currentProject?.addObject(
//						TextBox(
//							id: object["id"] as! String,
//							x: (object["position"] as! [String: NSObject])["x"] as! Int,
//							y: (object["position"] as! [String: NSObject])["y"] as! Int,
//							width: (object["dimentions"] as! [String: NSObject])["width"] as! Int,
//							height: (object["dimentions"] as! [String: NSObject])["height"] as! Int,
//							text: object["text"] as! String,
//							style: object["style"] as? String
//						)
//					)
//				default:
//					print("Unrecognised object received")
//				}
//			}
			
		
	}
	

}