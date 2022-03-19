//
//  Message.swift
//  FoodTrack
//
//  Created by Michał Rytych on 25/2/21.
//

import Foundation

struct Invitation {
    let invitationID: String
    let groupID: String
    let receiverID: String
    let receiverNickname: String
    let groupName: String
    let sentDate: Double
    let isAccepted: Bool
}
