//
//  ViewController.swift
//  CanvasProject
//
//  Created by Rasmus Berggrén on 2016-03-14.
//  Copyright © 2016 KTH. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	let model = CanvasProjectModel()
	let notificationCenter = NSNotificationCenter.defaultCenter()

//	required init?(coder aDecoder: NSCoder) {
//	    fatalError("init(coder:) has not been implemented")
//	}

	override func viewDidLoad() {
		super.viewDidLoad()
		notificationCenter.addObserver(self, selector: "update", name: "ReceivedData", object: nil)
		// Do any additional setup after loading the view, typically from a nib.
		
	}
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
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func drawTextBox(textBox: TextBox) {
		print("Draw text box")
		var txtField: UITextField = UITextField()
		txtField.frame = CGRectMake(CGFloat(textBox.position.x), CGFloat(textBox.position.y), CGFloat(textBox.dimentions.width), CGFloat(textBox.dimentions.height))
		self.view.addSubview(txtField)
	}

	func update() {
		theLabel.text = model.testValue
		print("update")
		
		if let project = model.currentProject {
			for var object in project.getObjects() {
				switch object {
				case is TextBox:
					print("case text")
					drawTextBox(object as! TextBox)
				default:
					print("Unrecognised canvas object in model")
				}
			}
		}
	}
}

