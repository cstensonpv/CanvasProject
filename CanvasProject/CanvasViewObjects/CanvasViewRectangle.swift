////
////  CanvasViewRectangle.swift
////  CanvasProject
////
////  Created by Rasmus Berggrén on 2016-04-01.
////  Copyright © 2016 KTH. All rights reserved.
////
//
//import UIKit
//import SwiftyJSON
//
//class CanvasViewRectangle: UIView, CanvasViewObject {
//
//    /*
//    // Only override drawRect: if you perform custom drawing.
//    // An empty implementation adversely affects performance during animation.
//    override func drawRect(rect: CGRect) {
//        // Drawing code
//    }
//    */
//	
//	var id = ""
//	var position = Position(x: Float(0), y: Float(0))
//	var dimensions = Dimensions(width: Float(0), height: Float(0))
//	
//	var mainController: ViewController?
//	
//	var rectangle = UIView()
//	var resizeHandleImage = UIImageView(image: UIImage(named: "resizeLines")!)
//	var resizeHandle = UIView()
//	
//	let resizeHandleSize: CGFloat = 20
//	let marginForResizeHandle: CGFloat = 5
//	let resizeHandleImageHeight: CGFloat = 16; let resizeHandleImageWidth: CGFloat = 26.5
//	let resizeHandleImageXDisplacement: CGFloat = 16.5; let resizeHandleImageYDisplacement: CGFloat = 15;
//	
//	override init(frame: CGRect) {
//		self.backgroundColor = UIColor.clearColor()
//		
//		rectangle.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(detectPan)))
//		rectangle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(wasTapped)))
//	}
//	
//	func setData(data: JSON) {
//		
//	}
//	
//	func wasTapped() {
//		
//	}
//	
//	func detectPan(recognizer: UIPanGestureRecognizer) {
//		
//	}
//	
//	func select() {
//		
//	}
//	
//	func deselect() {
//		
//	}
//	
//	func removeFromSuperview() {
//		
//	}
//
//}
