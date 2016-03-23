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
        notificationCenter.addObserver(self, selector: #selector(update), name: "ReceivedData", object: nil)

		// Do any additional setup after loading the view, typically from a nib.
		
	}
    @IBOutlet weak var canvas: UIScrollView!
	@IBOutlet weak var theLabel: UILabel!
	@IBOutlet weak var textField: UITextField!
	
	@IBAction func requestHelloWorld(sender: AnyObject) {
		model.testStringGet()
	}
	
	@IBAction func addTextBox(sender: AnyObject) {
		model.addTextBox()
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

	func update() {
		theLabel.text = model.testValue
		print("update")
		
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

