//
//  Canvas.swift
//  CanvasProject
//
//  Created by Rasmus Berggrén on 2016-03-18.
//  Copyright © 2016 KTH. All rights reserved.
//

import Foundation
import SwiftyJSON


class Project {
	private var objects = [String: JSON]()
	var collaborators = [String]()
	let id, name, creator: String
	
	init(id: String, name: String, creator: String) {
		self.id = id
		self.name = name
		self.creator = creator		
	}
    
    func resetObjects() {
        objects.removeAll()
    }
	
	func addObject(object: JSON) {
		objects[object["_id"].stringValue] = object
	}
	
	func addCollaborator(collaborator: String) {
		collaborators.append(collaborator)
	}
	
	func getObjects() -> [JSON] {
		var objects = [JSON]()
		
		for (_, value) in self.objects {
			objects.append(value)
		}
		
		return objects
	}
	
	func getObject(id: String) -> JSON? {
		return objects[id]
	}
	
	func getCollaborators() -> [String] {
		return collaborators
	}
	
}