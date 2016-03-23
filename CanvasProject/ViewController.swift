//
//  ViewController.swift
//  CanvasProject
//
//  Created by Rasmus Berggrén on 2016-03-14.
//  Copyright © 2016 KTH. All rights reserved.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController, UITextFieldDelegate {
	let model = CanvasProjectModel()
	let notificationCenter = NSNotificationCenter.defaultCenter()
    var canvasViewObjects = [CanvasViewObject]()
    var selectedCanvasViewObject: CanvasViewObject?
    
//	required init?(coder aDecoder: NSCoder) {
//	    fatalError("init(coder:) has not been implemented")
//	}

	override func viewDidLoad() {
		super.viewDidLoad()
		notificationCenter.addObserver(self, selector: #selector(updateProject), name: "ReceivedProject", object: nil)
        notificationCenter.addObserver(self, selector: #selector(updateCanvasObjects), name: "ReceivedCanvasObjects", object: nil)
		notificationCenter.addObserver(self, selector: #selector(updateUserInfo), name: "ReceivedUserInfo", object: nil)
		// Do any additional setup after loading the view, typically from a nib.
		
	}
	
    @IBOutlet weak var canvas: UIScrollView!
	@IBOutlet weak var projectNameLabel: UINavigationItem!
	@IBOutlet weak var collaboratorsLabel: UILabel!
	@IBOutlet weak var theLabel: UILabel!
	@IBOutlet weak var textField: UITextField!
	
	@IBAction func requestHelloWorld(sender: AnyObject) {
		model.testStringGet()
	}
	
	@IBAction func addTextBox(sender: AnyObject) {
		model.addCanvasObject(CanvasProjectModel.CanvasObjectType.TextBox)
	}
	
	@IBAction func helloWorld(sender: UIButton, forEvent event: UIEvent) {
		model.test()
		if let text = textField.text {
			model.setTestValue(text)
		}
	}

	@IBAction func jsonTest(sender: AnyObject) {
		model.testJSONGet()
	}
	@IBAction func jsonPostTest(sender: AnyObject) {
		model.testJSONPost()
	}
    
    func textFieldDidBeginEditing(textField: UITextField) {
        selectCanvasViewObject(textField as! CanvasViewObject)
    }
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
    }
    
    func selectCanvasViewObject(objectToSelect: CanvasViewObject) {
        deselectAllCanvasViewObjects()
        selectedCanvasViewObject = objectToSelect
        objectToSelect.select()
    }
    
    func deselectAllCanvasViewObjects() {
        selectedCanvasViewObject = nil
        for var object in canvasViewObjects {
            object.deselect()
        }
    }
	
	func updateProject() {
		print("Update project")
		if let project = model.currentProject {
			projectNameLabel.title = project.name
			
			model.requestProjectUserInfo()
			model.requestCanvasObjects()
		}
		
	}
	
	func updateUserInfo() {
		print("Update user info")
		if let project = model.currentProject {
			collaboratorsLabel.text = "Collaborators: "
			for var collaborator in project.getCollaborators() {
				collaboratorsLabel.text? += model.userNames[collaborator]! + ", "
			}
		}
	}

	func updateCanvasObjects() {
		theLabel.text = model.testValue
		print("Update canvas objects")
		
		if let project = model.currentProject {
			for var object in project.getObjects() {
				let newCanvasViewObject = CanvasViewTextBox()
                newCanvasViewObject.mainController = self
                newCanvasViewObject.setData(object)
                newCanvasViewObject.delegate = self
                canvas.addSubview(newCanvasViewObject)
                canvasViewObjects.append(newCanvasViewObject)
			}
		}
    }
}

