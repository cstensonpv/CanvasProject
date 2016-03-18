//
//  model.swift
//  CanvasProject
//
//  Created by Rasmus Berggrén on 2016-03-14.
//  Copyright © 2016 KTH. All rights reserved.
//

import UIKit
import Alamofire

class CanvasProjectModel {
	var observers = [UIViewController]()
	let notificationCenter = NSNotificationCenter.defaultCenter()
	var testValue: String = ""
	let username: String = "Mats"
	let userID: String = "1"
	var currentProject: Project?
	var serverAddress = "http://localhost"
	var serverPort = "8080"
	
	func test() {
		print("test")
	}
	
	func setTestValue(text: String) {
		testValue = text
		notificationCenter.postNotificationName("ReceivedData", object: nil)
	}
	
	func testStringGet() {
		Alamofire.request(.GET, serverAddress + serverPort + "/test")
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
		Alamofire.request(.GET, serverAddress + serverPort + "get/test")
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
		
		Alamofire.request(.POST, serverAddress + serverPort + "post", parameters: parameters, encoding: .JSON)
			.responseString { response in
				if let str = response.result.value {
					self.setTestValue(str)
				}
			}
	}
	
	func createNewProject() {
		self.currentProject = Project(id: "1", name: "Test project", creator: self.userID)
	}
	
}