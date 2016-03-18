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

	func update() {
		theLabel.text = model.testValue
	}
}

