//
//  RegisterViewController.swift
//  FoodTrack
//
//  Created by Michał Rytych on 02/2/21.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    let db = Firestore.firestore()
    var imagePicker: UIImagePickerController!
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var repeatEmailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        self.hideKeyboardWhenTappedAround()
        setPicker()
        profilePicture.layer.cornerRadius = profilePicture.bounds.height/2
    }
    
    @IBAction func addProfilePicture(_ sender: UIButton) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func setPicker() {
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
            checkUsername()
    }
    
    func checkUsername() {
        if let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            self.db.collection(Constant.FireStore.User.collection)
                .whereField(Constant.FireStore.User.userName, isEqualTo: username)
                .getDocuments { (querySnapshot, error) in
                    if let isError = error?.localizedDescription {
                        self.alert(present: isError)
                    } else {
                        if querySnapshot?.isEmpty == false {
                            self.alert(present: NSLocalizedString("The username is already in use by another account.", comment: "Username is already in use registration"))
                        } else {
                            self.registerUser()
                        }
                    }
                }
        }
    }
    
    func registerUser() {
        if let image = profilePicture.image,
           let email = emailTextField.text,
           let password = passwordTextField.text,
           let repeatEmail = repeatEmailTextField.text,
           let repeatPassword = repeatPasswordTextField.text,
           let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if email == repeatEmail {
                if password == repeatPassword {
                    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                        if let isError = error?.localizedDescription {
                            self.alert(present: isError)
                        } else if authResult == nil {
                            self.alert(present: NSLocalizedString("User not authenticated", comment: "User not authenticated in registration"))
                        } else {
                            self.uploadProfileImage(image) { (url) in
                                let changeRequest = authResult?.user.createProfileChangeRequest()
                                changeRequest?.displayName = username
                                changeRequest?.photoURL = url
                                changeRequest?.commitChanges(completion: { (error) in
                                    if let isError = error?.localizedDescription {
                                        self.alert(present: isError)
                                    } else {
                                        self.createUser(with: username) { (success) in
                                            if success {
                                                self.performSegue(withIdentifier: Constant.Segue.register, sender: self)
                                            } else {
                                                self.reset()
                                            }
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
                else {
                    alert(present: NSLocalizedString("Password Incorrect", comment: "Password incorrect in registration"))
                }
            }
            else {
                alert(present: NSLocalizedString("Email Incorrect", comment: "Email incorrect in registration"))
            }
        }
    }
    
    func createUser(with username: String, completion: @escaping ((_ success:Bool)->())) {
        if let userID = Auth.auth().currentUser?.uid {
        db.collection(Constant.FireStore.User.collection)
            .document(userID)
            .setData([
                        Constant.FireStore.User.userID: userID,
                        Constant.FireStore.User.userName: username]) { (error) in
                if let isError = error?.localizedDescription {
                    self.alert(present: isError)
                }
                completion(error == nil)
            }
        }
    }
    
    func reset() {
        view.reloadInputViews()
        alert(present: NSLocalizedString("Error signing up", comment: "Register error sighning up"))
    }
    
    func uploadProfileImage(_ image: UIImage, completion: @escaping (_ url: URL?) -> () ) {
        if let uid = Auth.auth().currentUser?.uid {
            let storageRef = Storage.storage().reference().child("profilePictures/\(uid)")
                    
                    guard let imageData = image.jpegData(compressionQuality: 0.75) else {return}
                    
                    let metaData = StorageMetadata()
                    metaData.contentType = "image/jpeg"
                    storageRef.putData(imageData, metadata: metaData) { (downloadMetadata, error) in
                        if let isError = error?.localizedDescription {
                            self.alert(present: isError)
                        } else {
                            storageRef.downloadURL(completion: { (url, error) in
                                if let isError = error?.localizedDescription {
                                    self.alert(present: isError)
                                } else {
                                    completion(url)
                                }
                            })
                        }
                    }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? MainTableViewController {
            destination.createGroup(with: "Home")
            destination.firstOpen = true
        }
    }
    
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.profilePicture.image = pickedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
}
