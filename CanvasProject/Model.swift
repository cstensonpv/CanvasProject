//
//  model.swift
//  CanvasProject
//
//  Created by Rasmus Berggrén on 2016-03-14.
//  Copyright © 2016 KTH. All rights reserved.
//

import UIKit

class CanvasProjectModel {
	var observers = [UIViewController]()
	let notificationCenter = NSNotificationCenter.defaultCenter()
	var testValue: String = ""
	
	func test() {
		print("test")
	}
	
	func setTestValue(text: String) {
		testValue = text
		notificationCenter.postNotificationName("ReceivedData", object: nil)
	}
	
//	func getTestRequest() {
//		var responseString: NSString? = ""
//		
//		let url = NSURL(string: "http://130.229.159.53:3000/test")!
//		
//		var request = NSURLRequest(URL: url)
//		let queue = NSOperationQueue()
//		
//		NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
//			print(NSString(data: data!, encoding: NSUTF8StringEncoding))
//			responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
//		}
//	}

	
}