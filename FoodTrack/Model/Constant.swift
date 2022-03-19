//
//  Constant.swift
//  FoodTrack
//
//  Created by Michał Rytych on 02/2/21.
//

import UIKit

struct Constant {
    static let appName = "🎯 FoodTrack"
    static let colorTable = [#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1), #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1), #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)]
    static let typeTable = ["Other", "Fruit", "Vegie", "Dairy", "Grain", "Protein", "Sweet"]
    static let scopeTable = ["All", "Fruit", "Vegie", "Dairy", "Grain", "Protein", "Sweet"]
    
    static let localizableTypeTable =
        [NSLocalizedString("Other", comment: "Other typeTable"),
         NSLocalizedString("Fruit", comment: "Fruit typeTable"),
         NSLocalizedString("Vegie", comment: "Vegie typeTable"),
         NSLocalizedString("Dairy", comment: "Dairy typeTable"),
         NSLocalizedString("Grain", comment: "Grain typeTable"),
         NSLocalizedString("Protein", comment: "Protein typeTable"),
         NSLocalizedString("Sweet", comment: "Sweet typeTable")]
    
    
    struct Segue {
        static let signOut = "SignOut"
        static let login = "LoginToMain"
        static let register = "RegisterToMain"
        static let settings = "MainToSettings"
        static let profile = "SettingsToProfile"
        static let invitation = "SettingsToInvitation"
        static let invite = "MainToInvite"
        static let group = "MainToItems"
        static let item = "ItemsToAddNewItem"
    }
    
    struct Cell {
        static let group = "GroupCell"
        static let item = "ItemCell"
        static let settings = "SettingsCell"
        static let invite = "InviteCell"
        static let invitation = "InvitationCell"
        static let language = "LanguageCell"
    }
    
    struct settingsCell {
        var name: String
        var image: UIImage?
        var color: UIColor?
        var segue: String?
    }
    
    struct UserDefaults {
        static let show = "HideExpiredItems"
        static let language = "Language"
    }
    
    struct FireStore {
        
        struct User {
            static let collection = "User"
            static let userID = "UserID"
            static let userName = "UserName"
            static let email = "Email"
        }
        
        struct Group {
            static let collection = "Group"
            static let groupName = "GroupName"
            static let groupID = "GroupID"
            static let userID = "UserID"
            static let creationDate = "CreationDate"
        }
        
        struct Item {
            static let collection = "Item"
            static let itemName = "ItemName"
            static let itemID = "ItemID"
            static let groupID = "GroupID"
            static let userID = "UserID"
            static let creationDate = "CreationDate"
            static let expiryDate = "ExpiryDate"
            static let isDone = "IsDone"
            static let type = "Type"
            static let typeNumber = "TypeNumber"
        }
        
        struct GroupPerUser {
            static let collection = "GroupPerUser"
            static let groupPerUserID = "GroupPerUserID"
            static let groupID = "GroupID"
            static let userID = "UserID"
            static let creationDate = "CreationDate"
        }
        
        struct Invitation {
            static let collection = "Invitation"
            static let invitationID = "InvitationID"
            static let groupID = "GroupID"
            static let receiverID = "ReceiverID"
            static let groupName = "GroupName"
            static let receiverNickname = "ReceiverNickname"
            static let sentDate = "SentDate"
            static let isAccepted = "IsAccepted"
        }
    }
}


