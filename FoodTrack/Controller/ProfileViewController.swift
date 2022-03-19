//
//  ProfileViewController.swift
//  FoodTrack
//
//  Created by Michał Rytych on 9/4/21.
//

import UIKit
import Firebase
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    let db = Firestore.firestore()
    var imagePicker: UIImagePickerController!

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var newPasswordTestField: UITextField!
    @IBOutlet weak var repeatNewPasswordTestField: UITextField!
    @IBOutlet weak var newEmailTextField: UITextField!
    @IBOutlet weak var repeatNewEmailTextField: UITextField!
    @IBOutlet weak var oldPasswordTestField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        let currentUser = Auth.auth().currentUser
        nicknameTextField.text = currentUser?.displayName
        emailTextField.text = currentUser?.email
        downloadProfilePicture(withURL: (Auth.auth().currentUser?.photoURL), completion: { (image) in
            self.profilePicture.image = image == nil ? UIImage(named: "person.circle") : image
        })
        profilePicture.layer.cornerRadius = profilePicture.bounds.height/2
        setPicker()
    }
    
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        if let oldPassword = oldPasswordTestField.text {
            let credential = EmailAuthProvider.credential(withEmail: emailTextField.text!, password: oldPassword)
            
            // User re-authenticate.
            Auth.auth().currentUser?.reauthenticate(with: credential, completion: { (authDataResult, error) in
                if let isError = error?.localizedDescription {
                    self.alert(present: isError)
                } else {
                    
                    // Change Password
                    if let newPassword = self.repeatNewPasswordTestField.text,
                       let repeatNewPassword = self.newPasswordTestField.text {
                        if newPassword == repeatNewPassword {
                            self.changePassword(to: newPassword)
                        } else {
                            self.alert(present: NSLocalizedString("New passwords do not match", comment: "Profile View password error"))
                        }
                    }
                    
                    // Change Email
                    if let newEmail = self.newEmailTextField.text,
                       let repeatNewEmail = self.repeatNewEmailTextField.text {
                        if newEmail == repeatNewEmail {
                            self.changeEmail(to: newEmail)
                        } else {
                            self.alert(present: NSLocalizedString("New emails do not match", comment: "Profile View password error"))
                        }
                    }
                }
                
            })
        } else {
            alert(present: NSLocalizedString("To confirm any changes, please provide current password", comment: "Profile View confirm error"))
        }
    }
    
    func changePassword(to newPassword: String) {
        Auth.auth().currentUser?.updatePassword(to: newPassword) { (error) in
            if let isError = error?.localizedDescription {
                self.alert(present: isError)
            } else {
                self.alert(present: NSLocalizedString("Updated Successfully", comment: "Profile View successful email alert"))
            }
        }
    }
    
    func changeEmail(to newEmail: String) {
        Auth.auth().currentUser?.updateEmail(to: newEmail) { (error) in
            if let isError = error?.localizedDescription {
                self.alert(present: isError)
            } else {
                self.alert(present: NSLocalizedString("Updated Successfully", comment: "Profilee View successful password alert"))
            }
        }
    }
    
}

//MARK: - Profile Picture Extension

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func changeProfilePicture(_ sender: UIButton) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func setPicker() {
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.profilePicture.image = pickedImage
            uploadProfileImage(pickedImage) { (url) in
                let changeRequest = Auth.auth().currentUser!.createProfileChangeRequest()
                changeRequest.photoURL = url
                changeRequest.commitChanges(completion: nil)
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
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
        }
    }
    
    func uploadProfileImage(_ image: UIImage, completion: @escaping (_ url: URL?) -> () ) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let storageRef = Storage.storage().reference(withPath: "profilePictures/\(uid)")
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {return}
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        // Save new picture
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
