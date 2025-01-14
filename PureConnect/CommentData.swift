//
//  CommentData.swift
//  PureConnect
//
//  Created by Darpon Chakma on 17/11/23.
//

import Foundation

class CommentData {
    var ownerText: String
    var ownerNameText: String
    var timeText: String
    var commentText: String
    
    init(ownerText: String, ownerNameText: String, timeText: String, commentText: String) {
        self.ownerText = ownerText
        self.ownerNameText = ownerNameText
        self.timeText = timeText
        self.commentText = commentText
    }
}
