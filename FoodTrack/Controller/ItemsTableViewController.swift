//
//  ItemsTableViewController.swift
//  FoodTrack
//
//  Created by Michał Rytych on 25/2/21.
//

import UIKit
import Firebase
import SwipeCellKit

class ItemsTableViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let db = Firestore.firestore()
    var items: [Item] = []
    var filteredItems: [Item] = []
    var selectedGroup : Group?
    
    override func viewDidLoad() {
        self.tabBarController?.tabBar.isHidden = false
        super.viewDidLoad()
        tableView.dataSource = self
        searchBar.delegate = self
        tableView.rowHeight = 60.0
        readItem()
        searchBar.selectedScopeButtonIndex = 0
        tableView.keyboardDismissMode = .interactive // or .onDrag
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedGroup?.groupName
    }
    
    //MARK: - CRUD Data Manipulation Methods
    
    func createItem(name textField: UITextField) {
    }
    
    func readItem() {
        if let groupID = selectedGroup?.groupID {
            db
                .collection(Constant.FireStore.Group.collection)
                .document(groupID)
                .collection(Constant.FireStore.Item.collection)
                .order(by: Constant.FireStore.Item.isDone)
                .order(by: Constant.FireStore.Item.expiryDate)
                .addSnapshotListener { (querySnapshot, error) in
                    self.items = []
                    if let isError = error?.localizedDescription {
                        self.alert(present: isError)
                    } else {
                        if let snapshotDocuments = querySnapshot?.documents {
                            for document in snapshotDocuments {
                                let data = document.data()
                                if let itemName = data[Constant.FireStore.Item.itemName] as? String,
                                   let itemID = data[Constant.FireStore.Item.itemID] as? String,
                                   let itemUserID = data[Constant.FireStore.Item.userID] as? String,
                                   let itemGroupID = data[Constant.FireStore.Item.groupID] as? String,
                                   let itemDate = data[Constant.FireStore.Item.creationDate] as? Double,
                                   let itemDone = data[Constant.FireStore.Item.isDone] as? Bool,
                                   let itemType = data[Constant.FireStore.Item.type] as? String,
                                   let itemExpiryDate = data[Constant.FireStore.Item.expiryDate] as? Double {
                                    let newItem = Item(itemName: itemName,
                                                       itemID: itemID,
                                                       userID: itemUserID,
                                                       groupID: itemGroupID,
                                                       creationDate: itemDate,
                                                       isDone: itemDone,
                                                       type: itemType,
                                                       expiryDate: itemExpiryDate)
                                    if newItem.isDone {
                                        if !UserDefaults.standard.bool(forKey: Constant.UserDefaults.show) {
                                            self.items.append(newItem)
                                        }
                                    } else {
                                        self.items.append(newItem)
                                    }
                                    self.filterItems(self.searchBar)
                                    DispatchQueue.main.async {
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                        } else {
                            self.alert(present: NSLocalizedString("Failed to retrive data", comment: "Items failed alert"))
                        }
                        
                    }
                }
        }
        
    }
    
    func updateItem(for item: Item) {
        if let groupID = selectedGroup?.groupID {
        db
            .collection(Constant.FireStore.Group.collection)
            .document(groupID)
            .collection(Constant.FireStore.Item.collection)
            .document(item.itemID)
            .updateData([Constant.FireStore.Item.itemName : item.itemName,
                         Constant.FireStore.Item.isDone : item.isDone,
                         Constant.FireStore.Item.expiryDate : item.expiryDate,
                         Constant.FireStore.Item.type : item.type,
                         Constant.FireStore.Item.userID : Auth.auth().currentUser!.uid])
        }
        readItem()
    }
    
    func deleteItem(for item: Item) {
        if let groupID = selectedGroup?.groupID,
           let itemsIndex = items.firstIndex(of: item),
           let filteredItemsIndex = filteredItems.firstIndex(of: item) {
        db
            .collection(Constant.FireStore.Group.collection)
            .document(groupID)
            .collection(Constant.FireStore.Item.collection)
            .document(item.itemID)
            .delete()

            items.remove(at: itemsIndex)
            filteredItems.remove(at: filteredItemsIndex)
        }
    }
    
    // MARK: - TableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchBar.text?.count != 0 || searchBar.selectedScopeButtonIndex != 0 ? filteredItems.count : items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.Cell.item, for: indexPath) as! SwipeTableViewCell
        let item = searchBar.text?.count != 0 || searchBar.selectedScopeButtonIndex != 0 ? filteredItems[indexPath.row] : items[indexPath.row]
        
        item.isDone == true ? (cell.accessoryType = .checkmark) : (cell.accessoryType = .none)
        cell.textLabel?.text = item.itemName
        cell.backgroundColor = Constant.colorTable[Constant.typeTable.firstIndex(of: item.type)!]
        cell.delegate = self
        
        showExpiryDate(for: cell, with: item)
        return cell
    }
    
    func showExpiryDate(for cell: SwipeTableViewCell, with item: Item) {
        let date = Date(timeIntervalSince1970: item.expiryDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY"
        let dateToShow = dateFormatter.string(from: date)
        cell.detailTextLabel?.text = NSLocalizedString("Expires: ", comment: "Expires detail label in Items") + dateToShow
        
        if item.expiryDate < Date().timeIntervalSince1970, !item.isDone {
            cell.textLabel?.text?.append(NSLocalizedString(" (EXPIRED)", comment: "EXPIRED label in Items"))
            cell.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        } else if item.isDone {
            cell.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        }
    }

    //MARK: - Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var item = searchBar.text?.count != 0 || searchBar.selectedScopeButtonIndex != 0 ? filteredItems[indexPath.row] : items[indexPath.row]
        item.isDone = !item.isDone
        updateItem(for: item)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AddNewItemViewController {
            destination.selectedGroup = selectedGroup
            destination.selectedItem = sender as? Item
        }
    }
}

extension ItemsTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterItems(searchBar)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterItems(searchBar)
    }
    
    func filterItems(_ searchBar: UISearchBar) {
        let searchText = searchBar.text ?? ""
        let selectedScope = searchBar.selectedScopeButtonIndex
        filteredItems = ItemsTableViewController.doFilterItems(searchWith: searchText, selectedScope: selectedScope, items: items)
        tableView.reloadData()
    }
    
    static func doFilterItems(searchWith searchText: String, selectedScope: Int, items: [Item]) -> [Item] {
        return items.filter { item in
            let isMatchingText = item.itemName.range(of: searchText, options: [.diacriticInsensitive, .caseInsensitive]) != nil ||  searchText.count == 0
            let isMatchingType = item.type == Constant.scopeTable[selectedScope] || selectedScope == 0
            return isMatchingText && isMatchingType
        }
    }
    
}

//MARK: - Swipe Cell Delegate Methods

extension ItemsTableViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let cell = tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
        let item = searchBar.text?.count != 0 || searchBar.selectedScopeButtonIndex != 0 ? filteredItems[indexPath.row] : items[indexPath.row]
        
        let deleteAction = SwipeAction(style: .destructive, title: NSLocalizedString("Delete", comment: "Delete action title")) { action, indexPath in
            self.deleteItem(for: item)
        }
        deleteAction.image = UIImage(systemName: "trash.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium))
        deleteAction.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        
        let editAction = SwipeAction(style: .default, title: NSLocalizedString("Edit", comment: "Edit action title")) { (action, indexPath) in
            self.performSegue(withIdentifier: Constant.Segue.item, sender: item)
        }
        editAction.image = UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium))
        editAction.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        let shareAction = SwipeAction(style: .default, title: NSLocalizedString("Share", comment: "Share action title")) { (action, indexPath) in
            self.shareItem(share: item)
            cell.hideSwipe(animated: true)
        }
        shareAction.image = UIImage(systemName: "square.and.arrow.up", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium))
        shareAction.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        
        return [deleteAction, editAction, shareAction]
    }
    
    func shareItem (share item: Item) {
        let calendar = Calendar.current

        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: Date())
        let date2 = calendar.startOfDay(for: Date(timeIntervalSince1970: item.expiryDate))

        let difference = calendar.dateComponents([.day], from: date1, to: date2).value(for: .day)
        guard let dif = difference else {return}
        
        let shareText = (item.itemName + NSLocalizedString(" expires in ", comment: "Share string") + String(dif) + NSLocalizedString(" days", comment: "Share string"))
        let share = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        present(share, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        //        options.transitionStyle = .border
        return options
    }
}
