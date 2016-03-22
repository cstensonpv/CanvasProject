//
//  TextBox.swift
//  CanvasProject
//
//  Created by Rasmus Berggrén on 2016-03-21.
//  Copyright © 2016 KTH. All rights reserved.
//

//import Foundation
//
//class ModelTextBox: CanvasObject {
//	var position: Position
//	var dimentions: Dimentions
//	var id: String
//	var style: TextStyles
//	
//	let defaultText = "Text"
//	let defaultDimentions = Dimentions(width: 200, height: 50)
//	let defaultStyle = TextStyles.Normal
//	
//	var text: String
//	
//	init(id: String, x: Int, y: Int, width: Int, height: Int, text: String, style: String?) {
//		self.id = id
//		self.position = Position(x: x, y: y)
//		self.dimentions = Dimentions(width: width, height: height)
//		self.text = text
//		
//		switch (style) {
//		case "Normal"?:
//			self.style = TextStyles.Normal
//		case "Header"?:
//			self.style = TextStyles.Header
//		default:
//			self.style = defaultStyle
//		}
//	}
//	
//}