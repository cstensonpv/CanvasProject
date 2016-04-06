//
//  LoginViewController.swift
//  CanvasProject
//
//  Created by Rasmus Berggrén on 2016-04-02.
//  Copyright © 2016 KTH. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class LoginViewController: UIViewController {

	// MARK: Properties
	
	@IBOutlet weak var userNameInput: UITextField!
	@IBOutlet weak var loginButton: UIButton!
	@IBOutlet weak var errorLabel: UILabel!
	@IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
	
	let couldntFindUserError = "Couldn't find user"
	
    override func viewDidLoad() {
        super.viewDidLoad()
		loginActivityIndicator.hidden = true
		errorLabel.text = ""
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

	
    // MARK: - Navigation
	@IBAction func loginButtonTapped(sender: AnyObject) {
		if let username = userNameInput.text {
			tryLogin(username)
		}
	}
	
	func tryLogin(username: String) {
		loginActivityIndicator.hidden = false
		loginActivityIndicator.startAnimating()
		model.login(username, callback: { userFound in
			if (userFound) {
				self.performSegueWithIdentifier("login", sender: nil)
			} else {
				self.errorLabel.text = self.couldntFindUserError
			}
			
			self.loginActivityIndicator.hidden = true
		})
	}
	
	@IBAction func unwind(segue: UIStoryboardSegue) {
		
	}

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		errorLabel.text = ""
		loginActivityIndicator.stopAnimating()
		loginActivityIndicator.hidden = true
    }
	

}
