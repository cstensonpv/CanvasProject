//
//  ChatViewController.swift
//  CanvasProject
//
//  Created by Carl Sténson on 2016-04-05.
//  Copyright © 2016 KTH. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    var messages = [JSON]()
    var cellIdentifier = "ChatTableViewCell"

    override func viewDidLoad() {
        //print("Loaded chatView CTRL)")
        model.requestChatMessages()
        notificationCenter.addObserver(self, selector: #selector(updateTable), name: "ReceivedChatMessages", object: nil)
        
        super.viewDidLoad()
        chatTable.dataSource = self
        chatTable.delegate = self

        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var chatTable: UITableView!
    @IBOutlet weak var textField: UITextView!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickSendButton(sender: AnyObject) {
        print("adds Chat message")
        model.addChatMessage(textField.text)
    }
    func updateTable() {
        print("Updates chatTable")
        //model.requestChatMessages()
        if let project = model.currentProject {
            messages = project.getChatMessages()
        }
        chatTable.reloadData()
        scrollToEnd();
        
        
        
    }
    
    func scrollToEnd() {
        let indexPath = NSIndexPath(forRow: messages.count - 1, inSection: 0)
        chatTable.scrollToRowAtIndexPath(indexPath,atScrollPosition:UITableViewScrollPosition.Middle, animated: true)
        
    
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("Called chattableview count " + String(messages.count))
        return messages.count //length of aray in model
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->   UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ChatTableViewCell
        
        let message = messages[indexPath.row]
        var userName = "";
        if(message["UserID"].stringValue == model.userID) {
            userName = "Me"
        }else {
            //If user not in UserNames the messages dosn't get a sender.
            userName = model.userNames[message["UserID"].stringValue]!
        }
        
        //add to component in cell
        cell.UserNameLabel.text = userName
        cell.MessageLabel.text = message["message"].stringValue
        cell.TimeLabel.text = message["posted"].stringValue
        //print("added cell with: " + message["message"].stringValue)
        
        
        
        
        return cell
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
