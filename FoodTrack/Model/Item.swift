//
//  Item.swift
//  FoodTrack
//
//  Created by Michał Rytych on 25/2/21.
//

import Foundation

struct Item: Equatable {
    var itemName: String
    var itemID: String
    var userID: String
    var groupID: String
    var creationDate: Double
    var isDone: Bool = false
    var type: String
    var expiryDate: Double
}
