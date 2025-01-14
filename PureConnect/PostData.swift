//
//  PostData.swift
//  PureConnect
//
//  Created by Darpon Chakma on 11/11/23.
//

import Foundation

class PostData {
    var idText: String
    var ownerText: String
    var ownerNameText: String
    var timeText: String
    var likesText: String
    var descriptText: String
    
    init(idText: String, ownerText: String, ownerNameText: String, timeText: String, likesText: String, descriptText: String) {
        self.idText = idText
        self.ownerText = ownerText
        self.ownerNameText = ownerNameText
        self.timeText = timeText
        self.likesText = likesText
        self.descriptText = descriptText
    }
}
