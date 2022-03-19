//
//  LoginViewController.swift
//  FoodTrack
//
//  Created by Michał Rytych on 02/2/21.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        login()
    }
    
    func login() {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                guard let self = self else { return }
                if let isError = error?.localizedDescription {
                    self.alert(present: isError)
                } else {
                    self.performSegue(withIdentifier: Constant.Segue.login, sender: self)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? MainTableViewController {
            destination.firstOpen = true
        }
    }
    
}
