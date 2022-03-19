//
//  AddNewItemViewController.swift
//  FoodTrack
//
//  Created by Michał Rytych on 25/2/21.
//

import UIKit
import Firebase

class AddNewItemViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var productNameTextField: UITextField!
    @IBOutlet weak var typePicker: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let db = Firestore.firestore()
    var type: String = Constant.typeTable[0]
    
    var selectedItem : Item?
    var selectedGroup: Group?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.productNameTextField.delegate = self
        datePicker.minimumDate = Date()
        readItem(for: selectedItem)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        createItem()
    }
    
    func createItem() {
        if let productName = productNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if productName.hasPrefix(" ") || productName.isEmpty {
                self.alert(present: NSLocalizedString("Can not add item without name", comment: "Create new item error description"))
            } else if let groupID = selectedGroup?.groupID {
                dismiss(animated: true) {
                    let documentID = self.selectedItem?.itemID ?? UUID().uuidString
                    self.db
                        .collection(Constant.FireStore.Group.collection)
                        .document(groupID)
                        .collection(Constant.FireStore.Item.collection)
                        .document(documentID)
                        .setData([
                                    Constant.FireStore.Item.itemName: productName,
                                    Constant.FireStore.Item.isDone: self.selectedItem?.isDone ?? false,
                                    Constant.FireStore.Item.itemID: documentID,
                                    Constant.FireStore.Item.userID: Auth.auth().currentUser!.uid, /*if SIGBAT nil, force unwrap is here*/
                                    Constant.FireStore.Item.groupID: groupID,
                                    Constant.FireStore.Item.creationDate: Date().timeIntervalSince1970,
                                    Constant.FireStore.Item.type: self.type,
                                    Constant.FireStore.Item.expiryDate: self.datePicker!.date.timeIntervalSince1970
                        ], merge: true) { (error) in
                            if let isError = error?.localizedDescription {
                                self.alert(present: isError)
                            }
                        }
                }
            }
        }
    }
    
    func readItem(for givenItem: Item?) {
        if let item = givenItem {
            type = item.type
            productNameTextField.text = item.itemName
            datePicker.setDate(Date(timeIntervalSince1970: item.expiryDate), animated: true)
            typePicker.selectRow(Constant.typeTable.firstIndex(of: item.type)!, inComponent: 0, animated: true)
        }
    }
}

extension AddNewItemViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constant.typeTable.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Constant.localizableTypeTable[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        type = Constant.typeTable[row]
    }
    
    //    For changing properties of text in pickerView
    //    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    //        return Constant.type[row]
    //    }
    
}
