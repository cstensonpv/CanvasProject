//
//  CanvasViewObject.swift
//  CanvasProject
//
//  Created by Carl Sténson on 2016-03-22.
//  Copyright © 2016 KTH. All rights reserved.
//

import UIKit
import Foundation

protocol CanvasViewObject {
	var id: String { get }
	var position: Position { get }
	var dimensions: Dimensions { get }
    func select()
    func deselect()
	func removeFromSuperview()
}