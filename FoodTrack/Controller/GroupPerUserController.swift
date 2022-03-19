//
//  GroupPerUserController.swift
//  FoodTrack
//
//  Created by Michał Rytych on 29/3/21.
//

import UIKit
import Firebase

extension MainTableViewController {
    
    func createGroupPerUser(with groupID: String) {
        let groupPerUserID = UUID().uuidString
        db
            .collection(Constant.FireStore.GroupPerUser.collection)
            .document(groupPerUserID)
            .setData([
                Constant.FireStore.GroupPerUser.groupPerUserID: groupPerUserID,
                Constant.FireStore.GroupPerUser.userID: Auth.auth().currentUser!.uid,
                Constant.FireStore.GroupPerUser.groupID: groupID,
                Constant.FireStore.GroupPerUser.creationDate: Date().timeIntervalSince1970
            ]) { error in
                if let isError = error?.localizedDescription {
                    self.alert(present: isError)
                }
            }
    }
    
    func readGroupPerUser() {
        db
            .collection(Constant.FireStore.GroupPerUser.collection)
            .order(by: Constant.FireStore.GroupPerUser.creationDate)
            .whereField(Constant.FireStore.GroupPerUser.userID, isEqualTo: Auth.auth().currentUser!.uid)
            .addSnapshotListener { (querySnapshot, error) in
                self.groupsID = []
                if let isError = error?.localizedDescription {
                    self.alert(present: isError)
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for document in snapshotDocuments {
                            let data = document.data()
                            if let groupID = data[Constant.FireStore.GroupPerUser.groupID] as? String {
                                self.groupsID.append(groupID)
                            }
                        }
                    }
                    self.readGroup()
                }
            }
    }
    
    func updateGroupPerUser() {
    
    }
    
    func deleteGroupPerUser(with groupID: String) {
        db
            .collection(Constant.FireStore.GroupPerUser.collection)
            .whereField(Constant.FireStore.GroupPerUser.groupID, isEqualTo: groupID)
            .getDocuments { (querySnapshot, error) in
                if let isError = error?.localizedDescription {
                    self.alert(present: isError)
                } else {
                    for document in querySnapshot!.documents {
                        document.reference.delete()
                    }
                }
            }
    }
    
}
