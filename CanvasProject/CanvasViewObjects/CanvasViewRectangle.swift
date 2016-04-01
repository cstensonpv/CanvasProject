//
//  CanvasViewRectangle.swift
//  CanvasProject
//
//  Created by Rasmus Berggrén on 2016-04-01.
//  Copyright © 2016 KTH. All rights reserved.
//

import UIKit
import SwiftyJSON

class CanvasViewRectangle: UIView, CanvasViewObject {
	var id = ""
	var position = Position(x: Float(0), y: Float(0))
	var dimensions = Dimensions(width: Float(0), height: Float(0))
	
	var dragStartPositionRelativeToCenter: CGPoint?
	var frameBeforeResize: CGRect?
	
	var mainController: ViewController?
	
	var rectangle = UIView()
	var resizeHandleImage = UIImageView(image: UIImage(named: "resizeLines")!)
	var resizeHandle = UIView()
	var stroke = CGFloat(1)
	let strokeAdditionWhenSelected = CGFloat(2)
	
	let resizeHandleSize: CGFloat = 20
	let marginForResizeHandle: CGFloat = 5
	let resizeHandleImageHeight: CGFloat = 16; let resizeHandleImageWidth: CGFloat = 26.5
	let resizeHandleImageXDisplacement: CGFloat = 16.5; let resizeHandleImageYDisplacement: CGFloat = 15;
	
	let minimumSize: CGFloat = 20
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.backgroundColor = UIColor.clearColor()
		
		rectangle.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(detectPan)))
		rectangle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(wasTapped)))
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
		
		// Rectangle
		rectangle.frame = CGRect(
			x: CGFloat(data["position"]["x"].floatValue),
			y: CGFloat(data["position"]["y"].floatValue),
			width: CGFloat(data["dimensions"]["width"].intValue),
			height: CGFloat(data["dimensions"]["height"].intValue)
		)
		stroke = CGFloat(data["stroke"].floatValue)
		rectangle.layer.borderWidth = CGFloat(data["stroke"].floatValue)
		addSubview(rectangle)
		
		// Resize handle image
		resizeHandleImage.frame = CGRect(
			x: CGFloat(rectangle.frame.width) - resizeHandleImageXDisplacement,
			y: CGFloat(rectangle.frame.height) - resizeHandleImageYDisplacement,
			width: CGFloat(resizeHandleImageWidth),
			height: CGFloat(resizeHandleImageHeight)
		)
		resizeHandleImage.hidden = true
		rectangle.addSubview(resizeHandleImage)
		
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
	
	func wasTapped() {
		mainController?.selectCanvasViewObject(self)
	}
	
	func select() {
		
	}
	
	func deselect() {
		
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
			
			rectangle.frame = CGRect(
				x: CGFloat(0),
				y: CGFloat(0),
				width: frame.size.width - marginForResizeHandle,
				height: frame.size.height - marginForResizeHandle
			)
			
			resizeHandleImage.frame = CGRect(
				x: CGFloat(rectangle.frame.width) - resizeHandleImageXDisplacement,
				y: CGFloat(rectangle.frame.height) - resizeHandleImageYDisplacement,
				width: CGFloat(resizeHandleImageWidth),
				height: CGFloat(resizeHandleImageHeight)
			)
			
			dimensions = Dimensions(
				width: Float(rectangle.frame.size.width),
				height: Float(rectangle.frame.size.height)
			)
		case .Ended:
			mainController!.registerObjectResize(self)
		default:
			()
		}
	}

}
