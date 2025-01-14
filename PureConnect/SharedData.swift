//
//  SharedData.swift
//  PureConnect
//
//  Created by Darpon Chakma on 11/11/23.
//

import Foundation

class SharedData {
    static let shared = SharedData()
    
    var userID: String?
    var userName: String?
    var loggedIn: String?
}
