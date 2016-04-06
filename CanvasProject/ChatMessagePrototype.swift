//
//  chatMessagePrototype.swift
//  CanvasProject
//
//  Created by Carl Sténson on 2016-04-06.
//  Copyright © 2016 KTH. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

struct ChatMessagePrototype {
    static func chatMessage(UserID: String, message: String) -> JSON {
        print("new object with \(UserID)   \(message)")
        return [
            "UserID": UserID,
            "message": message
        ]
    }
}