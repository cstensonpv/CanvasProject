//
//  TextBox.swift
//  CanvasProject
//
//  Created by Carl Sténson on 2016-03-22.
//  Copyright © 2016 KTH. All rights reserved.
//

import UIKit
import SwiftyJSON

class CanvasViewTextBox: UITextField, CanvasViewObject {
    var dragStartPositionRelativeToCenter: CGPoint?
    var startFrame: CGRect!
    var mainController: ViewController?
	var id = ""
	var position = Position(x: Float(0), y: Float(0))
	
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
    override init(frame: CGRect) {
		super.init(frame: frame)
		self.position = Position(x: Float(self.center.x), y: Float(self.center.y))
		
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(detectPan)))
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(wasTapped)))
        
        layer.shadowOffset = CGSize(width: 10, height: 10)
        layer.shadowOpacity = 0.0
        layer.shadowRadius = 6
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(data: JSON) {
        self.frame = CGRectMake(
            CGFloat(data["position"]["x"].floatValue),
            CGFloat(data["position"]["y"].floatValue),
            CGFloat(data["dimensions"]["width"].intValue),
            CGFloat(data["dimensions"]["height"].intValue)
        )
		
		print("Received position: \(data["position"]["x"]) \(data["position"]["y"])")
		
        self.text = data["text"].stringValue
		self.id = data["_id"].stringValue
//        self.backgroundColor = UIColor.brownColor()
    }
    
    func wasTapped() {
        mainController?.selectCanvasViewObject(self)
    }
    
    func select() {
        self.superview?.bringSubviewToFront(self)
        self.borderStyle = .RoundedRect
    }
    
    func deselect() {
        self.borderStyle = .None
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
            print("Bad drag case")
        }
    }
    
}
