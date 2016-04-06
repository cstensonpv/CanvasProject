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
//	let model = CanvasProjectModel()
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
	
	// View object outlets
	
	@IBOutlet weak var canvasScrollView: UIScrollView!
	@IBOutlet weak var canvas: UIView!
	@IBOutlet weak var collaboratorsLabel: UILabel!
	@IBOutlet weak var folderScrollView: UIScrollView!
	@IBOutlet weak var folderTableView: UITableView!
	@IBOutlet weak var projectNameLabel: UINavigationItem!
    
    
	override func viewDidLoad() {
		super.viewDidLoad()
		notificationCenter.addObserver(self, selector: #selector(updateWholeProject), name: "ReceivedProject", object: nil)
        notificationCenter.addObserver(self, selector: #selector(updateCanvasObjects), name: "ReceivedCanvasObjects", object: nil)
		notificationCenter.addObserver(self, selector: #selector(updateUserInfo), name: "ReceivedUserInfo", object: nil)
		notificationCenter.addObserver(self, selector: #selector(updateFileInfo), name: "ReceivedFiles", object: nil)
		notificationCenter.addObserver(self, selector: #selector(updateImages), name: "ReceivedImage", object: nil)
        

        folderTableView.dataSource = self
        folderTableView.delegate = self
        //initial is hide on show folder
		self.folderScrollView.hidden = true
        
       
		
		canvas.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deselectAllCanvasViewObjects)))
		canvasScrollView.contentSize = canvas.frame.size
		
		print("ViewController did load")
	}

	@IBAction func requestHelloWorld(sender: AnyObject) {
		model.testStringGet()
	}
	
	// Toolbar functions
	@IBAction func showFolder(sender: AnyObject) {
		model.requestDriveFolder()
		toggleFolderView()
		updateTable()
	}
    
	
	@IBAction func addTextBox(sender: AnyObject) {
        model.addCanvasObject(CanvasProjectModel.CanvasObjectType.TextBox)
	}
	
	@IBAction func addRectangle(sender: AnyObject) {
		model.addCanvasObject(CanvasProjectModel.CanvasObjectType.Rectangle)
	}

	@IBAction func deleteObject(sender: AnyObject) {
		if let object = selectedCanvasViewObject {
			let id = object.id
			object.removeFromSuperview()
			model.deleteCanvasObject(id)
		}
	}
    
    func toggleFolderView() {
        if (self.folderScrollView.hidden) {
            self.folderScrollView.hidden = false
        } else {
            self.folderScrollView.hidden = true
        }
    }
    
    func updateTable() {
        if let project = model.currentProject {
            tableData = project.getFiles()
        }
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
			model.registerCanvasObjectText(changedObject.id, text: changedObject.text)
		}
	}
	
	func registerObjectMovement(changedObject: CanvasViewObject) {
		print("register movement")
		model.registerCanvasObjectMovement(changedObject.id, x: changedObject.position.x, y: changedObject.position.y)
	}
	
	func registerObjectResize(changedObject: CanvasViewObject) {
		print("register resize")
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
	
	func updateWholeProject() {
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
			
			let collaborators = project.getCollaborators()
			
			for i in 0..<collaborators.count {
				if let userName = model.userNames[collaborators[i]] {
					if i < collaborators.count-1 {
						collaboratorsLabel.text? += userName + ", "
					} else {
						collaboratorsLabel.text? += userName
					}
				} else {
					collaboratorsLabel.text? += collaborators[i] + ", "
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
		updateTable()
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
				case "rectangle":
					print("Rectangle")
					let newCanvasViewObject = CanvasViewRectangle()
					newCanvasViewObject.mainController = self
					newCanvasViewObject.setData(object)
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
	
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier != "toChat"){
            print("closes project")
            model.closeProject()
        }
	}
}

