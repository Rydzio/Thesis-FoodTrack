//
//  MainTableViewController.swift
//  FoodTrack
//
//  Created by Michał Rytych on 23/2/21.
//

import UIKit
import Firebase
import SwipeCellKit

class MainTableViewController: UITableViewController {
    
    let db = Firestore.firestore()
    var groups: [Group] = []
    var groupsID: [String] = []
    var user: User?
    var firstOpen = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        title = Constant.appName
        tableView.dataSource = self
        tableView.rowHeight = 60.0
        readGroupPerUser()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        createAlert()
    }
    
    //MARK: - Segue Delegate Methods
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ItemsTableViewController {
            let indexPathRow = tableView.indexPathForSelectedRow?.row ?? 0
            destination.selectedGroup = groups[indexPathRow]
        } else if let destination = segue.destination as? InviteTableViewController {
            destination.selectedGroup = sender as? Group
        }
    }
    
    //MARK: - Alert Methods
    
    func createAlert() {
        var textField = UITextField()
        let alert = UIAlertController(title: NSLocalizedString("Add New Group", comment: "Add new group alert in Main"), message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: NSLocalizedString("Add Group", comment: "Add Group action button in Main"), style: .default) { (action) in
            if let groupName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                if groupName.hasPrefix(" ") || groupName.isEmpty
                {
                    self.alert(present: NSLocalizedString("Can not add group without name", comment: "Add New Group missing group name alert"))
                } else {
                    self.createGroup(with: groupName)
                    self.tableView.reloadData()
                }
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = NSLocalizedString("New Group Name", comment: "New Group Name placeholder")
            textField = alertTextField
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancell button in Add New Group"), style: .cancel, handler: nil))
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func updateAlert(at indexPath: IndexPath) {
        var textField = UITextField()
        let cell = tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
        let alert = UIAlertController(title: NSLocalizedString("Edit Group Name", comment: "Edit Group name alert"), message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: NSLocalizedString("Edit Name", comment: "Edit Name action button in Edit Group alert"), style: .default) { (action) in
            if let groupName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                if groupName.hasPrefix(" ") || groupName.isEmpty
                {
                    self.alert(present: NSLocalizedString("Can not add group without name", comment: "Edit Group Name alert for group with no name"))
                } else {
                    cell.hideSwipe(animated: true, completion: nil)
                    self.updateGroup(at: indexPath, with: groupName)
                    self.tableView.reloadData()
                }
            }
        }
        
        alert.addTextField { (alertTextField) in
//            alertTextField.placeholder = "New Group Name"
            alertTextField.text = self.groups[indexPath.row].groupName
            textField = alertTextField
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel button in Edit Group Name"), style: .cancel, handler: { (alert) in
            cell.hideSwipe(animated: true, completion: nil)
        }))
        alert.addAction(action)
        self.present(alert, animated: true) {
        }
    }
    
    func deleteAlert(at indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
        
        var alert = UIAlertController()
        var action = UIAlertAction()
        
        if self.groups[indexPath.row].userID == Auth.auth().currentUser!.uid {
            // Group owner
            alert = UIAlertController(title: NSLocalizedString("Delete Group", comment: "Delete Group alert"), message: "Deleting this group will also delete all its content. This action cannot be undone. Do you want to procide?", preferredStyle: .alert)
            
            action = UIAlertAction(title: NSLocalizedString("Delete", comment: "Delete button in Delete Group"), style: .destructive) { (action) in
                cell.hideSwipe(animated: true, completion: nil)
                self.deleteGroup(at: indexPath)
                self.tableView.reloadData()
            }
            
        } else {
            // Not a group owner
            alert = UIAlertController(title: NSLocalizedString("Leave Group", comment: "Leave group alert"), message: NSLocalizedString("Are you sure, you want to leave this group?", comment: "Leave Group alert message"), preferredStyle: .alert)
            
            action = UIAlertAction(title: NSLocalizedString("Leave", comment: "Leave button in Delete Group action"), style: .destructive) { (action) in
                cell.hideSwipe(animated: true, completion: nil)
                self.leaveGroup(at: indexPath)
                self.tableView.reloadData()
            }
        }
        
        
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel button in Delete Group alert"), style: .cancel, handler: { (alert) in
            cell.hideSwipe(animated: true, completion: nil)
        }))
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - CRUD Data Manipulation Methods
    
    func createGroup(with textField: String) {
        let groupID = UUID().uuidString
        db
            .collection(Constant.FireStore.Group.collection)
            .document(groupID)
            .setData([
                        Constant.FireStore.Group.groupName: textField,
                        Constant.FireStore.Group.groupID: groupID,
                        Constant.FireStore.Group.userID: Auth.auth().currentUser!.uid, /*if SIGBAT nil, force unwrap is here*/
                        Constant.FireStore.Group.creationDate: Date().timeIntervalSince1970
            ]) { (error) in
                if let isError = error?.localizedDescription {
                    self.alert(present: isError)
                }
            }
        createInvitation(with: groupID, named: textField)
        createGroupPerUser(with: groupID)
    }
    
    func createInvitation(with groupID: String, named groupName: String) {
            let invitationID = UUID().uuidString
            db
                .collection(Constant.FireStore.Invitation.collection)
                .document(invitationID)
                .setData([
                    Constant.FireStore.Invitation.groupID: groupID,
                    Constant.FireStore.Invitation.invitationID: invitationID,
                    Constant.FireStore.Invitation.receiverNickname: Auth.auth().currentUser!.displayName!,
                    Constant.FireStore.Invitation.groupName: groupName,
                    Constant.FireStore.Invitation.receiverID: Auth.auth().currentUser!.uid,
                    Constant.FireStore.Invitation.sentDate: Date().timeIntervalSince1970,
                    Constant.FireStore.Invitation.isAccepted: true
                ], merge: false) { (error) in
                    if let isError = error?.localizedDescription {
                        self.alert(present: isError)
                    }
                }
        }
    
    func readGroup() {
        db.collection(Constant.FireStore.Group.collection)
            .order(by: Constant.FireStore.Group.creationDate)
            .getDocuments(completion: { (querySnapshot, error) in
                self.groups = []
                if let isError = error?.localizedDescription {
                    self.alert(present: isError)
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for groupID in self.groupsID {
                            for document in snapshotDocuments {
                                let data = document.data()
                                if data[Constant.FireStore.Group.groupID] as! String == groupID {
                                    if let groupName = data[Constant.FireStore.Group.groupName] as? String,
                                       let groupID = data[Constant.FireStore.Group.groupID] as? String,
                                       let groupUserID = data[Constant.FireStore.Group.userID] as? String,
                                       let groupDate = data[Constant.FireStore.Group.creationDate] as? Double {
                                        let newGroup = Group(groupName: groupName, groupID: groupID, userID: groupUserID, creationDate: groupDate)
                                        self.groups.append(newGroup)
                                        DispatchQueue.main.async {
                                            self.tableView.reloadData()
                                        }
                                    }
                                }
                            }
                        }
                        if self.groups.count == 1,
                           self.firstOpen == true {
                            self.firstOpen = false
                            self.performSegue(withIdentifier: Constant.Segue.group, sender: self)
                        }
                    }
                }
            })
    }
    
    func updateGroup(at indexPath: IndexPath, with textField: String) {
        db
            .collection(Constant.FireStore.Group.collection)
            .document(groups[indexPath.row].groupID)
            .updateData([Constant.FireStore.Group.groupName: textField])
        groups[indexPath.row].groupName = textField
    }
    
    func deleteGroup(at indexPath: IndexPath) {
        
        //Delete all groupPerUser for the group
        deleteGroupPerUser(with: groups[indexPath.row].groupID)
        
        //Delete all invitation for the group
        db
            .collection(Constant.FireStore.Invitation.collection)
            .whereField(Constant.FireStore.Invitation.groupID, isEqualTo: groups[indexPath.row].groupID)
            .getDocuments { (querySnapshot, error) in
                if let isError = error?.localizedDescription {
                    self.alert(present: isError)
                } else {
                    for document in querySnapshot!.documents {
                        document.reference.delete()
                    }
                }
            }
        
        //Delete the group
        db
            .collection(Constant.FireStore.Group.collection)
            .document(groups[indexPath.row].groupID)
            .delete()
        groups.remove(at: indexPath.row)
    }
    
    func leaveGroup(at indexPath: IndexPath) {
        
        //Delete invitation for the user
        db
            .collection(Constant.FireStore.Invitation.collection)
            .whereField(Constant.FireStore.Invitation.groupID, isEqualTo: groups[indexPath.row].groupID)
            .whereField(Constant.FireStore.Invitation.receiverID, isEqualTo: Auth.auth().currentUser!.uid)
            .getDocuments { (querySnapshot, error) in
                if let isError = error?.localizedDescription {
                    self.alert(present: isError)
                } else {
                    for document in querySnapshot!.documents {
                        document.reference.delete()
                    }
                }
            }
        
        //Delete groupPerUser for the user
        db
            .collection(Constant.FireStore.GroupPerUser.collection)
            .whereField(Constant.FireStore.GroupPerUser.groupID, isEqualTo: groups[indexPath.row].groupID)
            .whereField(Constant.FireStore.GroupPerUser.userID, isEqualTo: Auth.auth().currentUser!.uid)
            .getDocuments { (querySnapshot, error) in
                if let isError = error?.localizedDescription {
                    self.alert(present: isError)
                } else {
                    for document in querySnapshot!.documents {
                        document.reference.delete()
                    }
                }
            }

        groups.remove(at: indexPath.row)
    }
}

//MARK: - Swipe Cell Manager

extension MainTableViewController: SwipeTableViewCellDelegate {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constant.Segue.group, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.Cell.group, for: indexPath) as! SwipeTableViewCell
        cell.textLabel?.text = groups[indexPath.row].groupName
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let cell = tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: NSLocalizedString("Delete", comment: "Delete in Group Swipe Action")) { action, indexPath in
            self.deleteAlert(at: indexPath)
        }
        deleteAction.image = UIImage(systemName: "trash.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium))
        deleteAction.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        
        let editAction = SwipeAction(style: .default, title: NSLocalizedString("Edit", comment: "Edit in Group Swipe Action")) { (action, indexPath) in
            if self.groups[indexPath.row].userID == Auth.auth().currentUser!.uid {
                self.updateAlert(at: indexPath)
                cell.hideSwipe(animated: true, completion: nil)
            } else {
                self.alert(present: NSLocalizedString("Only the owner of the group can edit it", comment: "Edit Group Swipe Action alert"))
            }
        }
        editAction.image = UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium))
        editAction.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        let inviteAction = SwipeAction(style: .default, title: NSLocalizedString("Invite", comment: "Invite in Group Swipe Action")) { (action, indexPath) in
            self.performSegue(withIdentifier: Constant.Segue.invite, sender: self.groups[indexPath.row])
            
            cell.hideSwipe(animated: true, completion: nil)
        }
        inviteAction.image = UIImage(systemName: "person.badge.plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium))
        inviteAction.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        
        
        return [deleteAction, editAction, inviteAction]
    }
    
//        func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
//            var options = SwipeOptions()
//            options.expansionStyle = .destructiveAfterFill
//            options.transitionStyle = .border
//            return options
//        }
}
