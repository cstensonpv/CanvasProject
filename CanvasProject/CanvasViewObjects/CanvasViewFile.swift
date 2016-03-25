//
//  CanvasViewFile.swift
//  CanvasProject
//
//  Created by Rasmus Berggrén on 2016-03-25.
//  Copyright © 2016 KTH. All rights reserved.
//

import UIKit
import SwiftyJSON

class CanvasViewFile: UIView, CanvasViewObject {
	var id = ""
	var position = Position(x: Float(0), y: Float(0))
	var dimensions = Dimensions(width: Float(0), height: Float(0))
	var mainController: ViewController?
	var link: String?
	
	var fileName = UIButton()
	var fileImage = UIImageView()
	var resizeHandleImage = UIImageView(image: UIImage(named: "resizeLines")!)
	var resizeHandle = UIView()
	
	var dragStartPositionRelativeToCenter: CGPoint?
	var frameBeforeResize: CGRect?
	
	let resizeHandleSize: CGFloat = 20
	let marginForResizeHandle: CGFloat = 5
	let resizeHandleImageHeight: CGFloat = 16; let resizeHandleImageWidth: CGFloat = 26.5
	let resizeHandleImageXDisplacement: CGFloat = 16.5; let resizeHandleImageYDisplacement: CGFloat = 15;
	let fileNameHeight = CGFloat(35)
	
	let fileNameBackgroundNormal = UIColor(
		red: CGFloat(0.5),
		green: CGFloat(0.5),
		blue: CGFloat(0.5),
		alpha: CGFloat(0.2)
	)
	let fileNameBackgroundPressed = UIColor(
		red: CGFloat(0.5),
		green: CGFloat(0.5),
		blue: CGFloat(0.5),
		alpha: CGFloat(0.5)
	)
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(detectPan)))
		self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(wasTapped)))
		
		layer.shadowOpacity = 0.0
		layer.shadowRadius = 6
		layer.borderColor = UIColor.grayColor().CGColor
		layer.backgroundColor = UIColor.clearColor().CGColor
		layer.cornerRadius = CGFloat(5)
		self.clipsToBounds = true
		
		fileName.backgroundColor = fileNameBackgroundNormal
		fileName.layer.cornerRadius = CGFloat(5)
		fileName.clipsToBounds = true
		fileName.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
		fileName.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
		fileName.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)

	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setData(data: JSON) {
		// The whole view
		frame = CGRect(
			x: CGFloat(data["position"]["x"].floatValue),
			y: CGFloat(data["position"]["y"].floatValue),
			width: CGFloat(data["dimensions"]["width"].intValue),
			height: CGFloat(data["dimensions"]["height"].intValue)
		)
		id = data["_id"].stringValue
		
		// File name
		fileName.frame = CGRect(
			x: CGFloat(0),
			y: CGFloat(frame.height) - fileNameHeight,
			width: CGFloat(frame.width),
			height: CGFloat(fileNameHeight)
		)
		fileName.setTitle(data["name"].stringValue, forState: UIControlState.Normal)
		addSubview(fileName)
		
		// Resize handle image
		resizeHandleImage.frame = CGRect(
			x: CGFloat(frame.width) - resizeHandleImageXDisplacement,
			y: CGFloat(frame.height) - resizeHandleImageYDisplacement,
			width: CGFloat(resizeHandleImageWidth),
			height: CGFloat(resizeHandleImageHeight)
		)
		resizeHandleImage.hidden = true
		addSubview(resizeHandleImage)
		
		// Resize handle
		resizeHandle.frame = CGRect(
			x: CGFloat(frame.width - resizeHandleSize),
			y: CGFloat(frame.height - resizeHandleSize),
			width: resizeHandleSize,
			height: resizeHandleSize
		)
		//		resizeHandle.backgroundColor = UIColor.redColor()
		resizeHandle.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(detectResize)))
		addSubview(resizeHandle)
	}
	
	func setFileInfo(data: JSON) {
		link = data["webViewLink"].stringValue
		fileName.addTarget(self, action: #selector(fileNameTouchDown), forControlEvents: UIControlEvents.TouchDown)
		fileName.addTarget(self, action: #selector(fileNameTouchUpInside), forControlEvents: UIControlEvents.TouchUpInside)
		fileName.addTarget(self, action: #selector(fileNameTouchCancel), forControlEvents: UIControlEvents.TouchUpOutside)
		fileName.addTarget(self, action: #selector(fileNameTouchCancel), forControlEvents: UIControlEvents.TouchCancel)
	}
	
	func select() {
		self.superview?.bringSubviewToFront(self)
		layer.borderWidth = 0.5
		resizeHandleImage.hidden = false
	}
	
	func deselect() {
		layer.borderWidth = 0.0
		resizeHandleImage.hidden = true
	}
	
	func wasTapped() {
		mainController?.selectCanvasViewObject(self)
	}
	
	func fileNameTouchDown(sender: UIButton!) {
		fileName.backgroundColor = fileNameBackgroundPressed
	}
	
	func fileNameTouchUpInside(sender: UIButton!) {
		fileName.backgroundColor = fileNameBackgroundNormal
		if link != nil {
			if let url = NSURL(string: link!) {
				UIApplication.sharedApplication().openURL(url)
			}
		}
	}
	
	func fileNameTouchCancel(sender: UIButton!) {
		fileName.backgroundColor = fileNameBackgroundNormal
	}
	
	func detectPan(recognizer: UIPanGestureRecognizer) {
		switch (recognizer.state) {
		case .Began:
			mainController!.selectCanvasViewObject(self)
			
			let locationInView = recognizer.locationInView(superview)
			dragStartPositionRelativeToCenter = CGPoint(
				x: locationInView.x - center.x,
				y: locationInView.y - center.y
			)
			
			self.layer.shadowOpacity = 0.5
		case .Changed:
			let locationInView = recognizer.locationInView(superview)
			
			self.center = CGPoint(
				x: locationInView.x - self.dragStartPositionRelativeToCenter!.x,
				y: locationInView.y - self.dragStartPositionRelativeToCenter!.y
			)
			self.position = Position(
				x: Float(self.frame.origin.x),
				y: Float(self.frame.origin.y)
			)
		case .Ended:
			dragStartPositionRelativeToCenter = nil
			self.layer.shadowOpacity = 0
			mainController!.registerObjectMovement(self)
		default:
			()
		}
	}
	
	func detectResize(recognizer: UIPanGestureRecognizer) {
		switch (recognizer.state) {
		case .Began:
			frameBeforeResize = frame
		case .Changed:
			let locationInView = recognizer.locationInView(superview)
			
			frame = CGRect(
				x: frameBeforeResize!.origin.x,
				y: frameBeforeResize!.origin.y,
				width: CGFloat(locationInView.x - frameBeforeResize!.origin.x),
				height: CGFloat(locationInView.y - frameBeforeResize!.origin.y)
			)
			
			fileName.frame = CGRect(
				x: CGFloat(0),
				y: CGFloat(frame.height) - fileNameHeight,
				width: CGFloat(frame.width),
				height: CGFloat(fileNameHeight)
			)
			
			resizeHandle.frame = CGRect(
				x: CGFloat(locationInView.x - frameBeforeResize!.origin.x) - resizeHandleSize,
				y: CGFloat(locationInView.y - frameBeforeResize!.origin.y) - resizeHandleSize,
				width: CGFloat(resizeHandleSize),
				height: CGFloat(resizeHandleSize)
			)
			
			resizeHandleImage.frame = CGRect(
				x: CGFloat(frame.width) - resizeHandleImageXDisplacement,
				y: CGFloat(frame.height) - resizeHandleImageYDisplacement,
				width: CGFloat(resizeHandleImageWidth),
				height: CGFloat(resizeHandleImageHeight)
			)
			
			dimensions = Dimensions(
				width: Float(frame.size.width),
				height: Float(frame.size.height)
			)
		case .Ended:
			mainController!.registerObjectResize(self)
		default:
			()
		}
	}
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
