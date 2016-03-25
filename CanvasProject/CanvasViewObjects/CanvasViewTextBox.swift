//
//  TextBox.swift
//  CanvasProject
//
//  Created by Carl Sténson on 2016-03-22.
//  Copyright © 2016 KTH. All rights reserved.
//

import UIKit
import SwiftyJSON

class CanvasViewTextBox: UIView, CanvasViewObject {
	var dragStartPositionRelativeToCenter: CGPoint?
	var frameBeforeResize: CGRect?
	var startFrame: CGRect!
	var mainController: ViewController?
	var id = ""
	var position = Position(x: Float(0), y: Float(0))
	var dimensions = Dimensions(width: Float(0), height: Float(0))
	
	var textField = UITextView()
	var resizeHandleImage = UIImageView(image: UIImage(named: "resizeLines")!)
	var resizeHandle = UIView()
	
	let resizeHandleSize: CGFloat = 20
	let marginForResizeHandle: CGFloat = 5
	let resizeHandleImageHeight: CGFloat = 16; let resizeHandleImageWidth: CGFloat = 26.5
	let resizeHandleImageXDisplacement: CGFloat = 16.5; let resizeHandleImageYDisplacement: CGFloat = 15;

	var text: String {
		get {
			return textField.text ?? ""
		}
		set(newText) {
			textField.text = newText
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.position = Position(x: Float(self.center.x), y: Float(self.center.y))
		self.backgroundColor = UIColor.clearColor()

		textField.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(detectPan)))
		textField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(wasTapped)))
		
//		textField.layer.shadowOffset = CGSize(width: 0, height: 0)
		textField.layer.shadowOpacity = 0.0
		textField.layer.shadowRadius = 6
		textField.layer.borderColor = UIColor.grayColor().CGColor
		textField.layer.backgroundColor = UIColor.clearColor().CGColor
		textField.font = UIFont(name: "Helvetica", size: 16)
		
		textField.editable = true
		textField.scrollEnabled = false
		
		resizeHandle = UIView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setData(data: JSON) {
		// The whole view
		frame = CGRect(
			x: CGFloat(data["position"]["x"].floatValue),
			y: CGFloat(data["position"]["y"].floatValue),
			width: CGFloat(data["dimensions"]["width"].intValue) + marginForResizeHandle,
			height: CGFloat(data["dimensions"]["height"].intValue) + marginForResizeHandle
		)
		id = data["_id"].stringValue
		
		// Text box
		textField.frame = CGRect(
			x: CGFloat(0),
			y: CGFloat(0),
			width: CGFloat(data["dimensions"]["width"].intValue),
			height: CGFloat(data["dimensions"]["height"].intValue)
		)
		textField.text = data["text"].stringValue
		addSubview(textField)

		
		// Resize handle image
		resizeHandleImage.frame = CGRect(
			x: CGFloat(textField.frame.width) - resizeHandleImageXDisplacement,
			y: CGFloat(textField.frame.height) - resizeHandleImageYDisplacement,
			width: CGFloat(resizeHandleImageWidth),
			height: CGFloat(resizeHandleImageHeight)
		)
		resizeHandleImage.hidden = true
		textField.addSubview(resizeHandleImage)
		
		
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
	
	func setTextFieldDelegate(delegate: UITextViewDelegate) {
		textField.delegate = delegate
	}
	
	func wasTapped() {
		mainController?.selectCanvasViewObject(self)
	}
	
	func select() {
		self.superview?.bringSubviewToFront(self)
		textField.layer.borderWidth = 0.5
		resizeHandleImage.hidden = false
	}
	
	func deselect() {
		textField.layer.borderWidth = 0.0
		resizeHandleImage.hidden = true
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
			
			resizeHandle.frame = CGRect(
				x: CGFloat(locationInView.x - frameBeforeResize!.origin.x) - resizeHandleSize,
				y: CGFloat(locationInView.y - frameBeforeResize!.origin.y) - resizeHandleSize,
				width: CGFloat(resizeHandleSize),
				height: CGFloat(resizeHandleSize)
			)
			
			textField.frame = CGRect(
				x: CGFloat(0),
				y: CGFloat(0),
				width: frame.size.width - marginForResizeHandle,
				height: frame.size.height - marginForResizeHandle
			)
			
			resizeHandleImage.frame = CGRect(
				x: CGFloat(textField.frame.width) - resizeHandleImageXDisplacement,
				y: CGFloat(textField.frame.height) - resizeHandleImageYDisplacement,
				width: CGFloat(resizeHandleImageWidth),
				height: CGFloat(resizeHandleImageHeight)
			)
			
			dimensions = Dimensions(
				width: Float(textField.frame.size.width),
				height: Float(textField.frame.size.height)
			)
		case .Ended:
			mainController!.registerObjectResize(self)
		default:
			()
		}
	}
	
	
	
}
