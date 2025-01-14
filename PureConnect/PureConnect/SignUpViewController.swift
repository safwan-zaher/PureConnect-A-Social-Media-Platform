//
//  SignUpViewController.swift
//  PureConnect
//
//  Created by Darpon Chakma on 10/11/23.
//

import UIKit
import Firebase
import FirebaseStorage

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var img: UIImageView!
    
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var phone: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var address: UITextField!
    
    @IBOutlet weak var descript: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBAction func selectImageClicked(_ sender: Any) {
        let imagePicker = UIImagePickerController()
                        imagePicker.delegate = self
                        imagePicker.sourceType = .photoLibrary
                        present(imagePicker, animated: true, completion: nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    
    @IBAction func signUpClicked(_ sender: Any) {
        
        if let phoneNumber = phone.text,
                   let userPassword = password.text,
                   let userEmail = email.text,
                   let userAddress = address.text,
                   let userDescription = descript.text,
                   let userName = name.text,
                   let image = img.image,
                   let imageData = image.jpegData(compressionQuality: 0.5) {

                    // Check if the password meets the minimum length requirement
                    if userPassword.count < 6 {
                        showAlert(title: "Error", message: "Password must be at least 6 characters long")
                        return
                    }

                    // Check if userEmail, userAddress, userDescription, and userName are not empty
                    if !phoneNumber.isEmpty,
                       !userEmail.isEmpty,
                       !userName.isEmpty {

                        let ref = Database.database().reference()
                        let usersRef = ref.child("users").child(phoneNumber)

                        // Check if the user already exists
                        usersRef.observeSingleEvent(of: .value) { (snapshot) in
                            if snapshot.exists() {
                                // User already exists, show an alert
                                self.showAlert(title: "Error", message: "User with this phone number already exists")
                            } else {
                                // User doesn't exist, save the data
                                usersRef.child("phone").setValue(phoneNumber)
                                usersRef.child("password").setValue(userPassword)
                                usersRef.child("email").setValue(userEmail)
                                usersRef.child("address").setValue(userAddress)
                                usersRef.child("description").setValue(userDescription)
                                usersRef.child("name").setValue(userName) // Add 'name' to Firebase

                                // Save the profile image to Firebase Storage
                                self.uploadImageToFirebaseStorage(phoneNumber, imageData: imageData)

                                // Show a success alert
                                self.showAlert(title: "Success", message: "Signed up successfully")
                            }
                        }
                    } else {
                        // Show an error alert if any of the required fields are empty
                        showAlert(title: "Error", message: "All fields must be filled")
                    }
                } else {
                    // Show an error alert if any field is empty
                    showAlert(title: "Error", message: "All fields must be filled")
                }

        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    img.image = pickedImage
                    img.contentMode = .scaleAspectFill
                    img.layer.cornerRadius = 55
                    img.clipsToBounds = true
                }
                picker.dismiss(animated: true, completion: nil)
            }
        
        private func showAlert(title: String, message: String) {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
    
    func customizeTextField(_ textField: UITextField) {
        textField.backgroundColor = UIColor(white: 1, alpha: 0.7)
        textField.borderStyle = .roundedRect
        textField.font = UIFont(name: "Helvetica Neue", size: 16)
        // Add other customization as needed
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
                            self.showAlert(title: "Error", message: "Image Uploaded Successfully")
                            
                            
                        } else if let error = error {
                            self.showAlert(title: "Error", message: "Image has not been uploaded. Try again")
                        }
                    }
                }
            }
        }
    func customizeButton(_ button: UIButton) {
        button.backgroundColor = UIColor.blue
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 5
        // Add other customization as needed
    }
    func customizeImageView(_ imageView: UIImageView) {
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.clipsToBounds = true
        // Add other customization as needed
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        customizeTextField(name)
          customizeTextField(phone)
        customizeTextField(email)
        customizeTextField(address)
          customizeTextField(descript)
        customizeTextField(password)
       
        view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)

    }
}
