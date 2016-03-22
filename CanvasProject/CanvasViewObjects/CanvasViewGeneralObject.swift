////
////  TextBox.swift
////  CanvasProject
////
////  Created by Carl Sténson on 2016-03-22.
////  Copyright © 2016 KTH. All rights reserved.
////
//
//import UIKit
//import SwiftyJSON
//
//class CanvasViewGeneralObject: UIView {
//    var dragStartPositionRelativeToCenter: CGPoint?
//    var startFrame: CGRect!
//    
//    /*
//     // Only override drawRect: if you perform custom drawing.
//     // An empty implementation adversely affects performance during animation.
//     override func drawRect(rect: CGRect) {
//     // Drawing code
//     }
//     */
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        var panRecognizer = UIPanGestureRecognizer(target: self, action: "detectPan:")
//        self.gestureRecognizers = [panRecognizer]
//        
//        self.backgroundColor = UIColor.brownColor()
//        layer.shadowOffset = CGSize(width: 0, height: 10)
//        layer.shadowOpacity = 0.0
//        layer.shadowRadius = 6
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func setData(data: JSON) {
//        switch data["type"].stringValue {
//        case "text":
//            print("case text")
//            drawTextBox(data)
//        default:
//            print("Unrecognised canvas object in model")
//        }
//        print(data["dimentions"]["height"].intValue)
//    }
//    
//    func drawTextBox(data: JSON) {
//        let rect = CGRectMake(
//            CGFloat(data["position"]["x"].intValue),
//            CGFloat(data["position"]["y"].intValue),
//            CGFloat(data["dimentions"]["width"].intValue),
//            CGFloat(data["dimentions"]["height"].intValue)
//        )
//        
//        self.frame = rect
//        
//        var textBox = UITextField()
//        textBox.frame = rect
//        textBox.text = data["text"].stringValue
//        self.addSubview(textBox)
//    }
//    
//    func detectPan(recognizer: UIPanGestureRecognizer) {
//        switch (recognizer.state) {
//        case .Began:
//            self.superview?.bringSubviewToFront(self)
//            
//            let locationInView = recognizer.locationInView(superview)
//            dragStartPositionRelativeToCenter = CGPoint(
//                x: locationInView.x - center.x,
//                y: locationInView.y - center.y
//            )
//            
//            self.layer.shadowOpacity = 0.5
//        case .Changed:
//            let locationInView = recognizer.locationInView(superview)
//            
//            self.center = CGPoint(
//                x: locationInView.x - self.dragStartPositionRelativeToCenter!.x,
//                y: locationInView.y - self.dragStartPositionRelativeToCenter!.y
//            )
//        case .Ended:
//            dragStartPositionRelativeToCenter = nil
//            self.layer.shadowOpacity = 0
//        default:
//            print("Bad drag case")
//        }
//    }
//    
//}
