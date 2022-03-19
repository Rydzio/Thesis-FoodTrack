//
//  SettingsTableViewController.swift
//  FoodTrack
//
//  Created by Michał Rytych on 25/2/21.
//

import UIKit
import Firebase

class SettingsTableViewController: UITableViewController {
    
    let cells = [
        Constant.settingsCell(name: NSLocalizedString("Hide Used Items", comment: "Hide Used Items settings cell"),
                              image: UIImage(systemName: "eye.slash"),
                              color: nil,
                              segue: nil),
        Constant.settingsCell(name: NSLocalizedString("Profile", comment: "Profile settings cell"),
                              image: UIImage(systemName: "person"),
                              color: nil,
                              segue: Constant.Segue.profile),
        Constant.settingsCell(name: NSLocalizedString("Invitation", comment: "Invitation settings cell"),
                              image: UIImage(systemName: "envelope"),
                              color: nil,
                              segue: Constant.Segue.invitation),
        Constant.settingsCell(name: NSLocalizedString("Sign Out", comment: "Sign Out settings cell"),
                              image: UIImage(systemName: "arrow.left.square"),
                              color: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1),
                              segue: Constant.Segue.signOut)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 60.0
        navigationItem.backBarButtonItem?.tintColor = .white
//        navigationItem.backBarButtonItem?.title = " "
        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let segueIdentifier = cells[indexPath.row].segue {
            performSegue(withIdentifier: segueIdentifier, sender: self)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.Cell.settings, for: indexPath)
        
        if indexPath.row == 0 {addSwitchView(for: cell)}
        cell.textLabel?.text = cells[indexPath.row].name
        cell.imageView?.image = cells[indexPath.row].image
        cell.textLabel?.textColor = cells[indexPath.row].color
        
        return cell
    }
    
    func addSwitchView(for cell: UITableViewCell) {
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(UserDefaults.standard.bool(forKey: Constant.UserDefaults.show), animated: true)
        switchView.tag = 0
        switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.setValue(true, forKey: Constant.UserDefaults.show)
        } else {
            UserDefaults.standard.setValue(false, forKey: Constant.UserDefaults.show)
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            alert(present: signOutError.localizedDescription)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }

}
