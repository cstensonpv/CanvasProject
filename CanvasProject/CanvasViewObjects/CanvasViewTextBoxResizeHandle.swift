//
//  CanvasViewTextBoxResizeHandle.swift
//  CanvasProject
//
//  Created by Rasmus Berggrén on 2016-03-24.
//  Copyright © 2016 KTH. All rights reserved.
//

import UIKit
import SwiftyJSON

class CanvasViewTextBoxResizeHandle: UIImageView {
	
	let resizeHandleHeight: CGFloat = 16;
	let resizeHandleWidth: CGFloat = 26.5
	var textBox: CanvasViewTextBox?
	
	override init(image: UIImage?) {
		super.init(image: image)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func initialize() {
		textBox = self.superview as? CanvasViewTextBox
		
		self.frame = CGRect(
			x: textBox!.frame.width - 16.5,
			y: textBox!.frame.height - 15,
			width: resizeHandleWidth,
			height: resizeHandleHeight
		)
		
		addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(detectResize)))
	}
	
	func detectResize(recognizer: UIPanGestureRecognizer) {
		switch (recognizer.state) {
		case .Began:
			print("Dragging resize handle")
		case .Changed:
			print("Resizing")
			let locationInView = recognizer.locationInView(superview)

			textBox!.frame = CGRect(
				x: textBox!.frame.origin.x,
				y: textBox!.frame.origin.x,
				width: locationInView.x - textBox!.frame.origin.x,
				height: locationInView.y - textBox!.frame.origin.y
			)

			self.frame = CGRect(
				x: textBox!.frame.width - 16.5,
				y: textBox!.frame.height - 15,
				width: resizeHandleWidth,
				height: resizeHandleHeight
			)
		case .Ended:
			print("Resize ended")
		default:
			print("Bad resize case")
		}
	}
}
