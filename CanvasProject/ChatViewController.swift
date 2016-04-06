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
        print("Loaded chatView CTRL)")
        model.requestChatMessages()
        notificationCenter.addObserver(self, selector: #selector(updateTable), name: "ReceivedChatMessages", object: nil)
        
        super.viewDidLoad()
        chatTable.dataSource = self
        chatTable.delegate = self

        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var chatTable: UITableView!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTable() {
        if let project = model.currentProject {
            messages = project.getChatMessages()
            print(messages);
        }
        chatTable.reloadData()
        
    }
    
    /*func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
        model.addCanvasObject(CanvasProjectModel.CanvasObjectType.File, data: tableData[indexPath.row])
    }*/
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("Called tableview count")
        return messages.count //length of aray in model
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->   UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ChatTableViewCell
        let message = messages[indexPath.row]
        print(message)
        cell.UserNameLabel.text = message["UserName"].stringValue
        cell.MessageLabel.text = message["message"].stringValue
        
        
        
        
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
