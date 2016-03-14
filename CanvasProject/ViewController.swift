//
//  ViewController.swift
//  CanvasProject
//
//  Created by Rasmus Berggrén on 2016-03-14.
//  Copyright © 2016 KTH. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	let model = Model()

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
	}
	@IBOutlet weak var theLabel: UILabel!
	@IBOutlet weak var textField: UITextField!
	@IBAction func requestHelloWorld(sender: AnyObject) {
		let response = model.getTestRequest()
	}
	
	@IBAction func helloWorld(sender: UIButton, forEvent event: UIEvent) {
		model.test()
		theLabel.text = textField.text
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

