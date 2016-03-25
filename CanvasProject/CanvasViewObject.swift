//
//  CanvasViewObject.swift
//  CanvasProject
//
//  Created by Carl Sténson on 2016-03-22.
//  Copyright © 2016 KTH. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON

protocol CanvasViewObject {
	var id: String { get }
	var position: Position { get }
	var dimensions: Dimensions { get }
	var mainController: ViewController? { get set }
	func setData(data: JSON)
	func wasTapped()
	func detectPan(recognizer: UIPanGestureRecognizer)
    func select()
    func deselect()
	func removeFromSuperview()
}