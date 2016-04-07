//
//  LoginViewRegisterController.swift
//  CanvasProject
//
//  Created by Rasmus Berggrén on 2016-04-06.
//  Copyright © 2016 KTH. All rights reserved.
//

import UIKit

class AddProjectViewController: UIViewController, UITextFieldDelegate {
	let generalRegisterError = "Couldn't register: Server communication error"
	let generalProjectError = "Unknown server project controller error"
	let couldntFindFolderError = "Couldn't find folder"
	let moreThanOneFolderError = "There is more than one folder with that name"
	var newProjectName: String?
	
	// MARK: Properties
	@IBOutlet weak var driveFolderNameTextField: UITextField!
	@IBOutlet weak var projectNameTextField: UITextField!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var messageLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.preferredContentSize = CGSizeMake(
			CGFloat(540),
			CGFloat(200)
		)
		
		self.activityIndicator.stopAnimating()
		self.activityIndicator.hidden = true
		self.messageLabel.text = ""
		projectNameTextField.delegate = self
		driveFolderNameTextField.delegate = self
		projectNameTextField.becomeFirstResponder()
		
		// Do any additional setup after loading the view.
	}
	
	@IBAction func createProject(sender: AnyObject) {
		if let newProjectName = projectNameTextField.text {
			activityIndicator.hidden = false
			activityIndicator.startAnimating()
			let driveFolderName = driveFolderNameTextField.text ?? ""
			model.addProject(withName: newProjectName, driveFolderName: driveFolderName, callback: { returnedInfo, success in
				if (success) {
					self.performSegueWithIdentifier("closeAddProjectView", sender: sender)
				} else {
					if (returnedInfo == CanvasProjectModel.APIErrorMessage.UnknownProjectError.rawValue) {
						self.messageLabel.text = self.generalProjectError
					} else if (returnedInfo == CanvasProjectModel.APIErrorMessage.CouldntFindFolder.rawValue) {
						self.messageLabel.text = self.couldntFindFolderError
					} else if (returnedInfo == CanvasProjectModel.APIErrorMessage.FoundMoreThanOneFolder.rawValue) {
						self.messageLabel.text = self.moreThanOneFolderError
					} else {
						self.messageLabel.text = self.generalRegisterError
					}
				}
				
				
				self.activityIndicator.hidden = true
			})
		}
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		createProject(textField)
		return true
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
