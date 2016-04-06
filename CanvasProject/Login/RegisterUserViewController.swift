//
//  LoginViewRegisterController.swift
//  CanvasProject
//
//  Created by Rasmus Berggrén on 2016-04-06.
//  Copyright © 2016 KTH. All rights reserved.
//

import UIKit

class RegisterUserViewController: UIViewController {
	let userNameTakenError = "Username already taken"
	let generalRegisterError = "Couldn't register: Server communication error"
	var newUsername: String?
	
	// MARK: Properties
	@IBOutlet weak var userNameTextField: UITextField!
	@IBOutlet weak var messageLabel: UILabel!

	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.preferredContentSize = CGSizeMake(
			CGFloat(540),
			CGFloat(150)
		)
		
		self.activityIndicator.stopAnimating()
		self.activityIndicator.hidden = true
		userNameTextField.becomeFirstResponder()

        // Do any additional setup after loading the view.
    }

	@IBAction func register(sender: AnyObject) {
		if let username = userNameTextField.text {
			activityIndicator.hidden = false
			activityIndicator.startAnimating()
			model.registerUser(username, callback: { returnedInfo in
				if (returnedInfo == CanvasProjectModel.APIErrorMessage.UserNameTaken.rawValue) {
					self.messageLabel.text = self.userNameTakenError
				} else if (returnedInfo == CanvasProjectModel.APIErrorMessage.Unknown.rawValue) {
					self.messageLabel.text = self.generalRegisterError
				} else {
					self.newUsername = returnedInfo
					self.performSegueWithIdentifier("closeRegisterUserView", sender: sender)
				}
			})
				
			self.activityIndicator.hidden = true
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
		
		if let loginViewController = segue.destinationViewController as? LoginViewController {
			if let newUsername = newUsername {
				loginViewController.userNameInput.text = newUsername
				loginViewController.tryLogin(newUsername)
			}
		}
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
	

}
