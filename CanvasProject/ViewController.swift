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

class ViewController: UIViewController, UITextViewDelegate, UITableViewDataSource {
	let model = CanvasProjectModel()
	let notificationCenter = NSNotificationCenter.defaultCenter()
	var canvasViewObjects = [String: CanvasViewObject]()
    var selectedCanvasViewObject: CanvasViewObject?
	
	let resizeHandleHeight: CGFloat = 16;
	let resizeHandleWidth: CGFloat = 26.5
	
	var dragStartPositionRelativeToCenter: CGPoint?
	var dimensionsBeforeResize: CGSize?
    
    let tableData = ["item1", "item2", "item3"]
	
	
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
        //initial is hide on show folder
        hideContainerView()
		
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
        print("reloads tabledata")
        folderTableView.reloadData()
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count //length of aray in model
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->   UITableViewCell {
        let cell = UITableViewCell()
        let label = UILabel(frame:CGRect(x:20, y:0, width:200, height:50))
        label.text = tableData[indexPath.row] //" Man Future file"
        cell.addSubview(label)
        cell.accessoryView = UIImageView(image:UIImage(named:"plusIcon")!)
        return cell
    }
    
    /*func tableView(foldertableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = folderTableView.dequeueReusableCellWithIdentifier("customcell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = "hej"
        print("sets table data")
        return cell
    }*/
    
    
    

    
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
	}

	func updateCanvasObjects() {
		let shouldBeSelected = selectedCanvasViewObject?.id
		print("Update canvas objects")
		
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

