//
//  MessagesTableViewController.swift
//  FoodTrack
//
//  Created by Michał Rytych on 25/2/21.
//

import UIKit
import Firebase
import SwipeCellKit

class InviteTableViewController: UITableViewController {
    
    let db = Firestore.firestore()
    var invitation: [Invitation] = []
    var selectedGroup: Group?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 60.0
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constant.Cell.invite, bundle: nil), forCellReuseIdentifier: Constant.Cell.invite)
        title = selectedGroup?.groupName
        title?.append(NSLocalizedString(" invitation", comment: "Append to title in Invite"))
        tableView.keyboardDismissMode = .interactive // or .onDrag
        searchBar.delegate = self
        self.hideKeyboardWhenTappedAround()
        readInvitation()
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        search()
    }
    
    func search() {
        var alreadyInvited = false
        if let nickname = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            for invitation in invitation {
                if nickname == invitation.receiverNickname {
                    alreadyInvited = true
                    alert(present: NSLocalizedString("User already invited", comment: "Search User alert in Invite"))
                }
            }
            if !alreadyInvited {
                checkNickname(for: nickname)
            }
        }
        searchBar.text?.removeAll()
    }
    
    func downloadProfilePicture(withURL url: URL?, completion: @escaping (_ image: UIImage?)->()) {
        if let url = url {
            let dataTask = URLSession.shared.dataTask(with: url) { data, url, error in
                var downloadedImage: UIImage?
                if let isError = error?.localizedDescription {
                    self.alert(present: isError)
                } else if let data = data {
                    downloadedImage = UIImage(data: data)
                }
                DispatchQueue.main.async {
                    completion(downloadedImage)
                }
            }
            dataTask.resume()
        } else {
            completion(nil)
        }
    }
    

    
    //MARK: - CRUD Data Manipulation Methods
    
    func createInvitation(for user: User) {
        if let group = selectedGroup
        {
            let invitationID = UUID().uuidString
            db
                .collection(Constant.FireStore.Invitation.collection)
                .document(invitationID)
                .setData([
                    Constant.FireStore.Invitation.groupID: group.groupID,
                    Constant.FireStore.Invitation.invitationID: invitationID,
                    Constant.FireStore.Invitation.receiverNickname: user.userName,
                    Constant.FireStore.Invitation.groupName: group.groupName,
                    Constant.FireStore.Invitation.receiverID: user.userID,
                    Constant.FireStore.Invitation.sentDate: Date().timeIntervalSince1970,
                    Constant.FireStore.Invitation.isAccepted: false
                ], merge: false) { (error) in
                    if let isError = error?.localizedDescription {
                        self.alert(present: isError)
                    }
                }
        }
    }
    
    func checkNickname(for nickname: String) {
        //        if let nickname = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
        db
            .collection(Constant.FireStore.User.collection)
            .whereField(Constant.FireStore.User.userName, isEqualTo: nickname)
            .addSnapshotListener { (querySnapshot, error) in
                if let isError = error?.localizedDescription {
                    self.alert(present: isError)
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        if snapshotDocuments.isEmpty {
                            self.alert(present: NSLocalizedString("User with this nickname does not exist", comment: "Search alert in Invite when User nickname does not exist"))
                        } else {
                            for document in snapshotDocuments {
                                let data = document.data()
                                if let nickname = data[Constant.FireStore.User.userName] as? String,
                                   let userID = data[Constant.FireStore.User.userID] as? String {
                                    let user = User(userID: userID, userName: nickname)
                                    self.createInvitation(for: user)
                                }
                            }
                        }
                    }
                }
            }
        //        }
    }
    
    func readInvitation() {
        if let groupID = selectedGroup?.groupID {
            db
                .collection(Constant.FireStore.Invitation.collection)
                .whereField(Constant.FireStore.Invitation.groupID, isEqualTo: groupID)
                .order(by: Constant.FireStore.Invitation.isAccepted, descending: true)
                .order(by: Constant.FireStore.Invitation.sentDate)
                .addSnapshotListener { (querySnapshot, error) in
                    self.invitation = []
                    if let isError = error?.localizedDescription {
                        self.alert(present: isError)
                    } else {
                        if let snapshotDocuments = querySnapshot?.documents {
                            for document in snapshotDocuments {
                                let data = document.data()
                                if let groupID = data[Constant.FireStore.Invitation.groupID] as? String,
                                   let invitationID = data[Constant.FireStore.Invitation.invitationID] as? String,
                                   let userID = data[Constant.FireStore.Invitation.receiverID] as? String,
                                   let receiverNickname = data[Constant.FireStore.Invitation.receiverNickname] as? String,
                                   let groupName = data[Constant.FireStore.Invitation.groupName] as? String,
                                   let sentDate = data[Constant.FireStore.Invitation.sentDate] as? Double,
                                   let isAccepted = data[Constant.FireStore.Invitation.isAccepted] as? Bool {
                                    let newInvitation = Invitation(invitationID: invitationID,
                                                                   groupID: groupID,
                                                                   receiverID: userID,
                                                                   receiverNickname: receiverNickname,
                                                                   groupName: groupName,
                                                                   sentDate: sentDate,
                                                                   isAccepted: isAccepted)
                                    self.invitation.append(newInvitation)
                                    DispatchQueue.main.async {
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                }
        }
    }
    
    func updateInvitation(at indexPath: IndexPath) {
        
    }
    
    func deleteGroupPerUser(at indexPath: IndexPath) {
        if let group = selectedGroup {
            db
                .collection(Constant.FireStore.GroupPerUser.collection)
                .whereField(Constant.FireStore.GroupPerUser.groupID, isEqualTo: group.groupID)
                .whereField(Constant.FireStore.GroupPerUser.userID, isEqualTo: invitation[indexPath.row].receiverID)
                .getDocuments { (querySnapshot, error) in
                    if let isError = error?.localizedDescription {
                        self.alert(present: isError)
                    } else {
                        if let snapshotDocuments = querySnapshot?.documents {
                            for document in snapshotDocuments {
                                let data = document.data()
                                if let groupPerUserID = data[Constant.FireStore.GroupPerUser.groupPerUserID] as? String {
                                    self.db
                                        .collection(Constant.FireStore.GroupPerUser.collection)
                                        .document(groupPerUserID)
                                        .delete()
//                                    self.deleteInvitation(at: indexPath)
                                }
                            }
                        }
                    }
                }
        }
    }
    
    func deleteInvitation(at indexPath: IndexPath) {
        db
            .collection(Constant.FireStore.Invitation.collection)
            .document(invitation[indexPath.row].invitationID)
            .delete()
        invitation.remove(at: indexPath.row)
        tableView.reloadData()
    }
    
}

//MARK: - Search Bar Delegate

extension InviteTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        search()
    }
    
}

/*
//MARK: - Swipe Table View Delegate

extension InviteTableViewController: SwipeTableViewCellDelegate {
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let cell = tableView.cellForRow(at: indexPath) as! SwipeTableViewCell

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            if self.selectedGroup?.userID == Auth.auth().currentUser?.uid {
                if self.invitation[indexPath.row].receiverID == Auth.auth().currentUser?.uid {
                    self.alert(present: "You can not delete your own invitation to your own group")
                    cell.hideSwipe(animated: true)
                } else {
                    if self.invitation[indexPath.row].isAccepted {
                        self.deleteGroupPerUser(at: indexPath)
                    } else {
                        self.deleteInvitation(at: indexPath)
                    }
                }
            } else if self.invitation[indexPath.row].receiverNickname == Auth.auth().currentUser?.uid {
                self.deleteGroupPerUser(at: indexPath)
            } else {
                self.alert(present: "Only group owner can delete invitation")
                cell.hideSwipe(animated: true, completion: nil)
            }
        }
        deleteAction.image = UIImage(systemName: "trash.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium))
        deleteAction.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)

        return [deleteAction]
    }

    
        func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
            var options = SwipeOptions()
            if self.selectedGroup?.userID == Auth.auth().currentUser?.uid {
                options.expansionStyle = .destructiveAfterFill
                options.transitionStyle = .border
            } else {
                options.expansionStyle = .none
            }
            return options
        }

}
*/

// MARK: - Table View Data Source

extension InviteTableViewController: InviteCellDelegate {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return invitation.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.Cell.invite, for: indexPath) as! InviteCell
        
        cell.delegate = self
        cell.indexPath = indexPath
        cell.titleLabel?.text = invitation[indexPath.row].receiverNickname
        
        if invitation[indexPath.row].receiverID == selectedGroup?.userID {
            cell.detailLabel?.text = "Owner"
            cell.button.isHidden = true
        } else {
            cell.detailLabel?.text = invitation[indexPath.row].isAccepted == true ? NSLocalizedString("Accepted", comment: "Invitation status") : NSLocalizedString("Pending", comment: "Invitation status")
        }
        
        
        if Auth.auth().currentUser?.uid == selectedGroup?.userID {
            // For Group Owner
            if invitation[indexPath.row].isAccepted == true {
                cell.button.setTitle(NSLocalizedString("Delete", comment: "Delete invitation"), for: .normal)
                cell.button.setTitleColor(#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), for: .normal)
                
            } else {
                cell.button.setTitle(NSLocalizedString("Cancel", comment: "Cancel invitation"), for: .normal)
                cell.button.setTitleColor(#colorLiteral(red: 0.09411764706, green: 0.4666666667, blue: 0.9490196078, alpha: 1), for: .normal)
            }
            
        } else {
            // For Other Users
            cell.button.isHidden = true
        }

        Storage.storage().reference().child("profilePictures/\(invitation[indexPath.row].receiverID)").downloadURL { (url, error) in
            if let isError = error?.localizedDescription {
                self.alert(present: isError)
                cell.profilePicture.image = UIImage(named: "person.circle")
            } else {
                self.downloadProfilePicture(withURL: url, completion: { (image) in
                    cell.profilePicture.image = image
                })
            }
        }
        
        return cell
    }
    
    func didTapButton(at indexPath: IndexPath?, with title: String?) {
        if let indexPath = indexPath {
            if self.selectedGroup?.userID == Auth.auth().currentUser?.uid {
                // For group owner
                if self.invitation[indexPath.row].receiverID == Auth.auth().currentUser?.uid {
                    self.alert(present: NSLocalizedString("You can not delete your own invitation to your own group", comment: "Invite alert"))
                } else {
                    if self.invitation[indexPath.row].isAccepted {
                        self.deleteGroupPerUser(at: indexPath)
                    } // else {
                    self.deleteInvitation(at: indexPath)
                    // }
                }
            } else if self.invitation[indexPath.row].receiverNickname == Auth.auth().currentUser?.displayName {
                self.deleteGroupPerUser(at: indexPath)
                self.deleteInvitation(at: indexPath)
            } else {
                self.alert(present: NSLocalizedString("Only group owner can delete invitation", comment: "Invite alert"))
            }
        }
    }
    
    
}

extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
