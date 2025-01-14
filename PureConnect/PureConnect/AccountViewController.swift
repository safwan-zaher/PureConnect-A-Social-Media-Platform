//
//  AccountViewController.swift
//  PureConnect
//
//  Created by Darpon Chakma on 11/11/23.
//

import UIKit
import Firebase
import FirebaseStorage

class AccountViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var phone: UILabel!
    
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var address: UITextField!
    
    @IBOutlet weak var descript: UITextField!
    
    @IBOutlet weak var img: UIImageView!
    
    @IBOutlet weak var oldPassword: UITextField!
    
    @IBOutlet weak var newPassword: UITextField!
    
    @IBOutlet weak var confirmPassword: UITextField!
    
    @IBAction func signOutClicked(_ sender: Any) {
        // Logout
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Assuming your storyboard is named "Main.storyboard"
        if let signInViewController = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController {
            self.navigationController?.pushViewController(signInViewController, animated: true)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func resetPasswordClicked(_ sender: Any) {
        
        guard let phoneNumber = phone.text, let oldPassword = oldPassword.text, let newPassword = newPassword.text, let confirmPassword = confirmPassword.text else {
                showAlert(title: "Error", message: "Please fill in all fields.")
                return
            }

            // Check if the new password is at least 6 characters long
            guard newPassword.count >= 6 else {
                showAlert(title: "Error", message: "New password must be at least 6 characters long.")
                return
            }

            let userRef = Database.database().reference().child("users").child(phoneNumber)

            userRef.observeSingleEvent(of: .value) { snapshot in
                guard let userData = snapshot.value as? [String: Any], let storedPassword = userData["password"] as? String else {
                    self.showAlert(title: "Error", message: "User not found.")
                    return
                }

                if oldPassword == storedPassword {
                    if newPassword == confirmPassword {
                        // Update password in Firebase
                        userRef.child("password").setValue(newPassword) { error, _ in
                            if let error = error {
                                self.showAlert(title: "Error", message: "Failed to update password. \(error.localizedDescription)")
                            } else {
                                self.showAlert(title: "Success", message: "Password updated successfully.")
                            }
                        }
                    } else {
                        self.showAlert(title: "Error", message: "New password and confirm password do not match.")
                    }
                } else {
                    self.showAlert(title: "Error", message: "Incorrect old password.")
                }
            }
    }
    
    
    @IBAction func imagePickerClicked(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            img.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    func uploadImageToFirebaseStorage(_ phoneNumber: String, imageData: Data) {
        let storageRef = Storage.storage().reference()
                let imageRef = storageRef.child("users").child("\(phoneNumber)").child("profileImage").child("\(phoneNumber).jpg")

                imageRef.putData(imageData, metadata: nil) { (_, error) in
                    if let error = error {
                        print("Error uploading image to Firebase Storage: \(error.localizedDescription)")
                    } else {
                        print("Image uploaded successfully to Firebase Storage")
                        // Now get the download URL and save it to the Realtime Database
                        imageRef.downloadURL { (url, error) in
                            if let downloadURL = url {
                                // Save the download URL to the Realtime Database
                                self.showAlert(title: "Success", message: "Image Uploaded Successfully")
                            } else if let error = error {
                                self.showAlert(title: "Error", message: "Image has not been uploaded. Try again")
                            }
                        }
                    }
                }
    }
    
    @IBAction func saveClicked(_ sender: Any) {
        if let phoneNumber = phone.text,
                   let userEmail = email.text,
                   let userAddress = address.text,
                   let userDescription = descript.text,
                   let userName = name.text,
                   let image = img.image,
                   let imageData = image.jpegData(compressionQuality: 0.5) {

                    if !userEmail.isEmpty,
                       !userName.isEmpty {

                        let ref = Database.database().reference()
                        let usersRef = ref.child("users").child(phoneNumber)

                        usersRef.child("email").setValue(userEmail)
                        usersRef.child("address").setValue(userAddress)
                        usersRef.child("description").setValue(userDescription)
                        usersRef.child("name").setValue(userName)
                        self.uploadImageToFirebaseStorage(phoneNumber, imageData: imageData)
                        self.showAlert(title: "Success", message: "Information Updated successfully")
                    }
                }
            
        }
        
        func downloadImageFromFirebaseStorage(_ currentUserID: String) {
            let storageRef = Storage.storage().reference()
                    let imageRef = storageRef.child("users").child(currentUserID).child("profileImage").child("\(currentUserID).jpg")

                    imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if let error = error {
                            self.showAlert(title: "Error", message: "\(error.localizedDescription)")
                        } else if let imageData = data, let profileImage = UIImage(data: imageData) {
                            DispatchQueue.main.async {
                                self.img.image = profileImage
                                self.img.contentMode = .scaleAspectFill
                                self.img.layer.cornerRadius = 70
                                self.img.clipsToBounds = true
                            }
                        }
                    }
        }
        
    func customizeTextField(_ textField: UITextField) {
        textField.backgroundColor = UIColor(white: 1, alpha: 0.7)
        textField.borderStyle = .roundedRect
        textField.font = UIFont(name: "Helvetica Neue", size: 16)
        // Add other customization as needed
    }

        
        override func viewDidLoad() {
            super.viewDidLoad()
            customizeTextField(name)
                customizeTextField(email)
                customizeTextField(address)
                customizeTextField(descript)
            customizeTextField(oldPassword)
            customizeTextField(newPassword)
            customizeTextField(confirmPassword)
            let ref = Database.database().reference()
            let currentUserID = SharedData.shared.userID ?? ""
            let userRef = ref.child("users").child(currentUserID)
            
            userRef.observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists() {
                    if let userData = snapshot.value as? [String: Any] {
                        self.phone.text = userData["phone"] as? String
                        self.name.text = userData["name"] as? String
                        self.email.text = userData["email"] as? String
                        self.address.text = userData["address"] as? String
                        self.descript.text = userData["description"] as? String
                        
                        // Corrected path usage for retrieving image from Firebase Storage
                        self.downloadImageFromFirebaseStorage(currentUserID)
                        
                    }
                }
            }
        }
    }

