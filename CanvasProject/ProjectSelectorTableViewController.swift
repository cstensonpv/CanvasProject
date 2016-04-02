//
//  ProjectSelectorController.swift
//  CanvasProject
//
//  Created by Rasmus Berggrén on 2016-04-01.
//  Copyright © 2016 KTH. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProjectSelectorTableViewController: UITableViewController {
	
	// MARK: Properties
	let test = ["1", "2", "3"]
	
	var projects = [String]()
	let notificationCenter = NSNotificationCenter.defaultCenter()
	
	@IBOutlet weak var projectsLoadingIndicator: UIActivityIndicatorView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.navigationItem.rightBarButtonItem = self.editButtonItem()
		projectsLoadingIndicator.startAnimating()
		model.requestProjectsForLoggedInUser()
		notificationCenter.addObserver(self, selector: #selector(loadProjects), name: "ReceivedProjects", object: nil)
		loadProjects()
    }
	
	func loadProjects() {
		print("load projects")
		projectsLoadingIndicator.hidden = true
		self.tableView.reloadData()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return model.allProjects.isEmpty ? 0 : model.allProjects.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProjectSelectorTableViewCell", forIndexPath: indexPath) as! ProjectSelectorTableViewCell

		if !model.allProjects.isEmpty {
			cell.projectNameLabel.text = model.allProjects[indexPath.row]["name"].stringValue
		}

        return cell
    }
	
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation
	override func viewWillDisappear(animated: Bool) {
		model.logout()
	}

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController

		let projectIndex = self.tableView.indexPathForSelectedRow!.row
		let projectID = model.allProjects[projectIndex]["_id"].stringValue
		print("Opening project \(projectID)")
		model.openProject(id: projectID)
		
		print("Segue")
        // Pass the selected object to the new view controller.
    }


}
