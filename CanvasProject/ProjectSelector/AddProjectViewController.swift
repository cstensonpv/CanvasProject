//
//  LoginViewRegisterController.swift
//  CanvasProject
//
//  Created by Rasmus Berggrén on 2016-04-06.
//  Copyright © 2016 KTH. All rights reserved.
//

import UIKit

class AddProjectViewController: UIViewController {
	let generalRegisterError = "Couldn't register: Server communication error"
	let generalProjectError = "Unknown server project controller error"
	var newProjectName: String?
	
	// MARK: Properties
	@IBOutlet weak var projectNameTextField: UITextField!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var messageLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.preferredContentSize = CGSizeMake(
			CGFloat(540),
			CGFloat(150)
		)
		
		self.activityIndicator.stopAnimating()
		self.activityIndicator.hidden = true
		self.messageLabel.text = ""
		projectNameTextField.becomeFirstResponder()
		
		// Do any additional setup after loading the view.
	}
	
	@IBAction func createProject(sender: AnyObject) {
		if let newProjectName = projectNameTextField.text {
			activityIndicator.hidden = false
			activityIndicator.startAnimating()
			model.addProject(withName: newProjectName, callback: { returnedInfo in
				if (returnedInfo == CanvasProjectModel.APIErrorMessage.UnknownProjectError.rawValue) {
					self.messageLabel.text = self.generalProjectError
				} else if (returnedInfo == CanvasProjectModel.APIErrorMessage.Unknown.rawValue) {
					self.messageLabel.text = self.generalRegisterError
				} else {
					self.newProjectName = returnedInfo
					self.performSegueWithIdentifier("closeAddProjectView", sender: sender)
				}
				
				self.activityIndicator.hidden = true
			})
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	
	
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		messageLabel.text = ""
		activityIndicator.stopAnimating()
		activityIndicator.hidden = true
		
//		if let projectSelectorController = segue.destinationViewController as? ProjectSelectorTableViewController {
//			if let newProjectName = newProjectName {
//				// Maybe go to the project automatically?
//			}
//		}
	}
	
	
}
