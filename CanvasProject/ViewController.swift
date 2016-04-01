//
//  ViewController.swift
//  CanvasProject
//
//  Created by Rasmus Berggrén on 2016-03-14.
//  Copyright © 2016 KTH. All rights reserved.
//

import UIKit
import SwiftyJSON
import AlamofireImage

class ViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate {
	let model = CanvasProjectModel()
	let notificationCenter = NSNotificationCenter.defaultCenter()
	var canvasViewObjects = [String: CanvasViewObject]()
    var selectedCanvasViewObject: CanvasViewObject?
	
	let resizeHandleHeight: CGFloat = 16;
	let resizeHandleWidth: CGFloat = 26.5
	
	var dragStartPositionRelativeToCenter: CGPoint?
	var dimensionsBeforeResize: CGSize?
    
    
    var tableData = [JSON]()//["item1", "item2", "item3"]
	
	
//	required init?(coder aDecoder: NSCoder) {
//	    fatalError("init(coder:) has not been implemented")
//	}

	override func viewDidLoad() {
		super.viewDidLoad()
		notificationCenter.addObserver(self, selector: #selector(updateProject), name: "ReceivedProject", object: nil)
        notificationCenter.addObserver(self, selector: #selector(updateCanvasObjects), name: "ReceivedCanvasObjects", object: nil)
		notificationCenter.addObserver(self, selector: #selector(updateUserInfo), name: "ReceivedUserInfo", object: nil)
		notificationCenter.addObserver(self, selector: #selector(updateFileInfo), name: "ReceivedFiles", object: nil)
		notificationCenter.addObserver(self, selector: #selector(updateImages), name: "ReceivedImage", object: nil)

        folderTableView.dataSource = self
        folderTableView.delegate = self
        //initial is hide on show folder
        hideContainerView()
        
        
        //tableController = storyBoard.instantiateViewControllerWithIdentifier("TableViewController") as? TableViewController
        
//        tableController?.hello()
        //self.navigationController?.pushViewController(tableController!, animated: true)
		
		canvas.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deselectAllCanvasViewObjects)))
		canvasScrollView.contentSize = canvas.frame.size
		// Do any additional setup after loading the view, typically from a nib.
    
		
	}
    
	
	// View object outlets
	@IBOutlet weak var projectNameLabel: UINavigationItem!
	@IBOutlet weak var canvasScrollView: UIScrollView!
	@IBOutlet weak var canvas: UIView!
	@IBOutlet weak var collaboratorsLabel: UILabel!
    @IBOutlet weak var FolderScrollView: UIScrollView!
    @IBOutlet weak var folderTableView: UITableView!
    
    
    @IBAction func ShowListFolder(sender: AnyObject) {
        hideContainerView()
        updateTable()
    }
	
	@IBAction func requestHelloWorld(sender: AnyObject) {
		model.testStringGet()
	}	
	
	// Toolbar functions
	@IBAction func addTextBox(sender: AnyObject) {
        model.addCanvasObject(CanvasProjectModel.CanvasObjectType.TextBox)
	}
	
	@IBAction func deleteObject(sender: AnyObject) {
		if let object = selectedCanvasViewObject {
			let id = object.id
			object.removeFromSuperview()
			model.deleteCanvasObject(id)
		}
	}
	

	@IBAction func jsonTest(sender: AnyObject) {
		model.testJSONGet()
	}
	
	@IBAction func jsonPostTest(sender: AnyObject) {
		model.testJSONPost()
	}
    
    func hideContainerView() {
        if(self.FolderScrollView.hidden) {
            self.FolderScrollView.hidden = false
            print("showes scrollview")
			
        } else {
            self.FolderScrollView.hidden = true
            print("hides scrollview")
        }
    }
    
    func updateTable() {
        if let project = model.currentProject {
            tableData = project.getFiles()
            //print(tableData[0]["name"]);
        }
        print("reloads tabledata")
        folderTableView.reloadData()
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
        model.addCanvasObject(CanvasProjectModel.CanvasObjectType.File, data: tableData[indexPath.row])
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("Called tableview count")
        return tableData.count //length of aray in model
    }
    
    func tableView(folderTableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->   UITableViewCell {
        print("Called tableview write")
        let margin = CGFloat(7)
        let cell = UITableViewCell()
        
        let label = UILabel(frame:CGRect(x:cell.bounds.height, y:0, width:200, height:50))
        label.text = tableData[indexPath.row]["name"].stringValue
        cell.addSubview(label)
        //cell.tag = indexPath.row
        if let project = model.currentProject {
            if var image = project.getImage(tableData[indexPath.row]["id"].stringValue){
                //print(image)
                image = image.af_imageAspectScaledToFitSize(CGSize(
                    width: cell.bounds.height - margin,
                    height: cell.bounds.height - margin
                ))
                let imageView = UIImageView(image:image)
                imageView.frame = CGRect(
                    x: margin/2,
                    y: margin/2,
                    width: cell.bounds.height - margin,
                    height: cell.bounds.height - margin
                )
                cell.addSubview(imageView)
                
            }
        }

        cell.accessoryView = UIImageView(image:UIImage(named:"plusIcon")!)        
    
        return cell
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
		if textView.superview! is CanvasViewTextBox {
			let object = textView.superview! as! CanvasViewTextBox
			selectCanvasViewObject(object)
		}
    }
	
	func textViewDidEndEditing(textView: UITextView) {
		if textView.superview! is CanvasViewTextBox && textView.text != nil {
			let changedObject = textView.superview! as! CanvasViewTextBox
			self.model.registerCanvasObjectText(changedObject.id, text: changedObject.text)
		}
	}
	
	func registerObjectMovement(changedObject: CanvasViewObject) {
		model.registerCanvasObjectMovement(changedObject.id, x: changedObject.position.x, y: changedObject.position.y)
	}
	
	func registerObjectResize(changedObject: CanvasViewObject) {
		model.registerCanvasObjectResize(changedObject.id, width: changedObject.dimensions.width, height: changedObject.dimensions.height)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
    }
    
    func selectCanvasViewObject(objectToSelect: CanvasViewObject) {
        deselectAllCanvasViewObjects()
        selectedCanvasViewObject = objectToSelect
        objectToSelect.select()
    }
    
    func deselectAllCanvasViewObjects() {
        selectedCanvasViewObject = nil
        for (_, object) in canvasViewObjects {
            object.deselect()
        }
    }
	
	func updateProject() {
		print("Update project")
		if let project = model.currentProject {
			projectNameLabel.title = project.name
			
			model.requestProjectUserInfo()
			model.requestCanvasObjects()
		}
		
	}
	
	func updateUserInfo() {
		if let project = model.currentProject {
			collaboratorsLabel.text = "Collaborators: "
			for collaborator in project.getCollaborators() {
				if let userName = model.userNames[collaborator] {
					collaboratorsLabel.text? += userName + ", "
				} else {
					collaboratorsLabel.text? += collaborator + ", "
				}
			}
		}
	}
	
	func resetCanvas() {
		for (_, view) in canvasViewObjects {
			view.removeFromSuperview()
		}
		
		canvasViewObjects.removeAll()
	}
	
	func updateFileInfo() {
		updateCanvasObjects()
	}
	
	func updateImages() {
//		if let project = model.currentProject {
//			for (_, object) in canvasViewObjects {
//				if object is CanvasViewFile {
//					if 
//						(object as! CanvasViewFile).setImage(UIImage(image))
//				}
//			}
//		}
		print("Update images")
		updateCanvasObjects()
        updateTable();
	}

	func updateCanvasObjects() {
		let shouldBeSelected = selectedCanvasViewObject?.id
		print("ViewController updating canvas objects")
		
		if let project = model.currentProject {
			resetCanvas()
			
			for var object in project.getObjects() {
				switch (object["type"]) {
				case "text":
					let newCanvasViewObject = CanvasViewTextBox()
					newCanvasViewObject.setTextFieldDelegate(self)
					newCanvasViewObject.mainController = self
					newCanvasViewObject.setData(object)
					canvas.addSubview(newCanvasViewObject)
					canvasViewObjects[newCanvasViewObject.id] = newCanvasViewObject
				case "file":
//					print(object)
					let newCanvasViewObject = CanvasViewFile()
					newCanvasViewObject.mainController = self
					newCanvasViewObject.setData(object)
					if let fileInfo = project.getFile(object["driveFileID"].stringValue) {
						newCanvasViewObject.setFileInfo(fileInfo)
						
						if let fileImage = project.getImage(object["driveFileID"].stringValue) {
							newCanvasViewObject.setImage(fileImage, isFullImage: true)
						}
					}
					canvas.addSubview(newCanvasViewObject)
					canvasViewObjects[newCanvasViewObject.id] = newCanvasViewObject
				default:
					print("Unrecognized canvas object")
					print(object)
				}
				

			}
			
			if let id = shouldBeSelected {
				if (canvasViewObjects[id]) != nil {
					selectCanvasViewObject(canvasViewObjects[id]!)
				}
				
			}
		}
		
		
    }
}

