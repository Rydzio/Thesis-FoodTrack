//
//  InvitationTableViewController.swift
//  FoodTrack
//
//  Created by Michał Rytych on 9/4/21.
//

import UIKit
import Firebase

class InvitationTableViewController: UITableViewController {
    
    let db = Firestore.firestore()
    var invitation: [Invitation] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 60.0
        tableView.register(UINib(nibName: Constant.Cell.invitation, bundle: nil), forCellReuseIdentifier: Constant.Cell.invitation)
        tableView.dataSource = self
        readInvitation()
    }
    
    //MARK: - CRUD
    
    func readInvitation() {
        db
            .collection(Constant.FireStore.Invitation.collection)
            .whereField(Constant.FireStore.Invitation.receiverID, isEqualTo: Auth.auth().currentUser!.uid)
//            .whereField(Constant.FireStore.Invitation.isAccepted, isEqualTo: false)
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
                               let receiverID = data[Constant.FireStore.Invitation.receiverID] as? String,
                               let nickname = data[Constant.FireStore.Invitation.receiverNickname] as? String,
                               let groupName = data[Constant.FireStore.Invitation.groupName] as? String,
                               let sentDate = data[Constant.FireStore.Invitation.sentDate] as? Double,
                               let isAccepted = data[Constant.FireStore.Invitation.isAccepted] as? Bool {
                                let newInvitation = Invitation(invitationID: invitationID,
                                                               groupID: groupID,
                                                               receiverID: receiverID,
                                                               receiverNickname: nickname,
                                                               groupName: groupName,
                                                               sentDate: sentDate,
                                                               isAccepted: isAccepted)
                                if !newInvitation.isAccepted {
                                    self.invitation.append(newInvitation)
                                }
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
    }
    
    func updateInvitation(at indexPath: IndexPath) {
        MainTableViewController()
            .createGroupPerUser(with: invitation[indexPath.row].groupID)
        
        db
            .collection(Constant.FireStore.Invitation.collection)
            .document(invitation[indexPath.row].invitationID)
            .updateData([Constant.FireStore.Invitation.isAccepted: true]) { (error) in
                if let isError = error?.localizedDescription {
                    self.alert(present: isError)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        invitation.remove(at: indexPath.row)
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

//MARK: - Table View Data Source

extension InvitationTableViewController: InvitationCellDelegate {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invitation.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.Cell.invitation, for: indexPath) as! InvitationCell
        
        cell.delegate = self
        cell.indexPath = indexPath
        cell.titleLabel.text = invitation[indexPath.row].groupName
        cell.detailLabel.text = NSLocalizedString("Pending", comment: "Pending invitation status")
        cell.leftButton.setTitle(NSLocalizedString("Delete", comment: "Delete invitation action"), for: .normal)
        cell.leftButton.setTitleColor(#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), for: .normal)
        cell.rightButton.setTitle(NSLocalizedString("Accept", comment: "Accept invitation action"), for: .normal)
        cell.rightButton.setTitleColor(#colorLiteral(red: 0.09411764706, green: 0.4666666667, blue: 0.9490196078, alpha: 1), for: .normal)
        
        return cell
    }
    
    func didTapButton(at indexPath: IndexPath?, with title: String?) {
        if let indexPath = indexPath {
            if title == NSLocalizedString("Accept", comment: "Accept invitation button title") {
                updateInvitation(at: indexPath)
            } else if title == NSLocalizedString("Delete", comment: "Delete invitation button title") {
                deleteInvitation(at: indexPath)
            }
            tableView.reloadData()
        }
    }
}
