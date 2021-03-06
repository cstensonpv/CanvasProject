//
//  Canvas.swift
//  CanvasProject
//
//  Created by Rasmus Berggrén on 2016-03-18.
//  Copyright © 2016 KTH. All rights reserved.
//

import UIKit
import SwiftyJSON

class Project {
	private var objects = [String: JSON]()
	private var files = [String: JSON]()
    private var messages = [JSON]()
	var fileImages = [String: UIImage]()
	var driveFolderID: String?
	var driveFolderName: String?
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
	
	func addFile(file: JSON) {
		files[file["id"].stringValue] = file
	}
    
    func addMessages(newMessages: [JSON]) {
        /*print( message)
        if let messageArray = message.array {
            messages += message.array
        }*/
        //print(messages)
        
        //old
        messages = newMessages
    }
	
	func addImage(image: UIImage, forFileID fileID: String) {
		fileImages[fileID] = image
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
	
	func getFiles() -> [JSON] {
		var files = [JSON]()
		
		for (_, value) in self.files {
			files.append(value)
		}
		
		return files
	}
    
    func getChatMessages() -> [JSON] {
        var messages = [JSON]()
        print("project getChatmessages")
        
        /*for (_, value) in self.messages {
            print("appends")
            messages.append(value)
        }*/
        messages = self.messages
        
        return messages
    }
	
	func getObject(id: String) -> JSON? {
		return objects[id]
	}
	
	func getFile(name: String) -> JSON? {
		return files[name]
	}
	
	func getImage(id: String) -> UIImage? {
		return fileImages[id]
	}
	
	func getCollaborators() -> [String] {
		return collaborators
	}
	
}