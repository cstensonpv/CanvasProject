//
//  CanvasObject.swift
//  CanvasProject
//
//  Created by Rasmus Berggrén on 2016-03-21.
//  Copyright © 2016 KTH. All rights reserved.
//

import Foundation

class CanvasObject {
	struct Position {
		var x: Int
		var y: Int
	}
	
	struct Dimentions {
		var width: Int
		var height: Int
	}
	
	enum TextStyles {
		case Normal
		case Header
	}
}