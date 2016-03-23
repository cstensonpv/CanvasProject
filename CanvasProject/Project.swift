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
	private var objects = [JSON]()
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
		objects.append(object)
	}
	
	func addCollaborator(collaborator: String) {
		collaborators.append(collaborator)
	}
	
	func getObjects() -> [JSON] {
		return objects
	}
	
	func getCollaborators() -> [String] {
		return collaborators
	}
	
}