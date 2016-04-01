//
//  CanvasObjectPrototypes.swift
//  CanvasProject
//
//  Created by Rasmus Berggrén on 2016-03-23.
//  Copyright © 2016 KTH. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

struct CanvasObjectPrototypes {
	static func textBox(projectID: String) -> JSON {
		return [
			"project_id": projectID,
			"position": [
				"x": 100,
				"y": 100
			],
			"dimensions": [
				"width": 100,
				"height": 50
			],
			"type": "text",
			"style": "normal",
			"text": "Text box"
		]
	}
	
	static func rectangle(projectID: String) -> JSON {
		return [
			"project_id": projectID,
			"position": [
				"x": 200,
				"y": 200
			],
			"dimensions": [
				"width": 200,
				"height": 150
			],
			"type": "rectangle",
			"stroke": 1
		]
	}
}