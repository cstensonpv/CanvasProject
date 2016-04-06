//
//  LoginViewRegisterController.swift
//  CanvasProject
//
//  Created by Rasmus Berggrén on 2016-04-06.
//  Copyright © 2016 KTH. All rights reserved.
//

import UIKit

class LoginViewRegisterController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		
		let width = self.preferredContentSize.width
		print(width)
		
		self.preferredContentSize = CGSizeMake(
			CGFloat(540),
			CGFloat(200)
		)
		
		print("Login register view did load")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
