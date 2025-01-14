//
//  CreatePostViewController.swift
//  PureConnect
//
//  Created by Darpon Chakma on 11/11/23.
//

import UIKit
import Firebase
import FirebaseStorage

class CreatePostViewController: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var img: UIImageView!

    @IBOutlet var selectImg: UIButton!
    @IBOutlet var descript: UITextView!
    
    @IBOutlet weak var createe: UIButton!
    @IBAction func selectImageClicked(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                present(imagePicker, animated: true, completion: nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func createClicked(_ sender: Any) {
        
        if let image = img.image,
           let imageData = image.jpegData(compressionQuality: 0.5),
           let descriptionText = descript.text {
            
            if !imageData.isEmpty,
               !descriptionText.isEmpty {
                
                let ref = Database.database().reference()
                let currentUserID = SharedData.shared.userID ?? ""
                let currentUserName = SharedData.shared.userName ?? ""
                
                let postsRef = ref.child("posts").childByAutoId()
                
                if let autoID = postsRef.key {
                    self.uploadImageToFirebaseStorage(currentUserID, imageData: imageData, autoID: autoID)
                } else {
                    print("Error: Auto-generated key is nil")
                    // Handle the error, show an alert, or take appropriate action
                }
                
                // Save the description, likes, dislikes, and time
                postsRef.child("owner").setValue(currentUserID)
                postsRef.child("owner_name").setValue(currentUserName)
                postsRef.child("description").setValue(descriptionText)
                
                // Use the current timestamp
                let currentTimestamp = Date().timeIntervalSince1970
                
                // Format the timestamp for display if needed
                let date = Date(timeIntervalSince1970: currentTimestamp)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"  // Customize the date format as needed
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")  // Set the locale to English
                
                let formattedDate = dateFormatter.string(from: date)
                
                postsRef.child("time").setValue(formattedDate)
                
                showAlert(title: "Success", message: "Post created successfully")
                
            } else {
                // Show an error alert if any field is empty
                showAlert(title: "Error", message: "All fields must be filled")
            }
        }
        else {
            showAlert(title: "Error", message: "All fields must be filled")
        }

    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
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
    
    func uploadImageToFirebaseStorage(_ phoneNumber: String, imageData: Data, autoID: String) {
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("posts").child(autoID).child("\(autoID).jpg")

        imageRef.putData(imageData, metadata: nil) { (_, error) in
            if let error = error {
                print("Error uploading image to Firebase Storage: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: "Image has not been uploaded. Try again")
            } else {
                print("Image uploaded successfully to Firebase Storage")
                // Now get the download URL and save it to the Realtime Database
                imageRef.downloadURL { (url, error) in
                    if let downloadURL = url {
                        // Save the download URL to the Realtime Database
                        self.saveImageURLToDatabase(phoneNumber: phoneNumber, autoID: autoID, imageURL: downloadURL)
                    } else if let error = error {
                        self.showAlert(title: "Error", message: "Image has been uploaded, but URL could not be retrieved. Try again.")
                    }
                }
            }
        }
    }
    
    func customizeButton(_ button: UIButton) {
            button.backgroundColor = UIColor.black
                button.setTitleColor(UIColor.white, for: .normal)
                button.layer.cornerRadius = 5
        }
    
    func saveImageURLToDatabase(phoneNumber: String, autoID: String, imageURL: URL) {
        let ref = Database.database().reference()
        let postRef = ref.child("posts").child(autoID)
        
        // Save the image URL to the Realtime Database
        postRef.child("imageURL").setValue(imageURL.absoluteString) { (error, _) in
            if let error = error {
                print("Error saving image URL to the Realtime Database: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: "Image has been uploaded, but URL could not be saved. Try again.")
            } else {
                self.showAlert(title: "Success", message: "Image Uploaded Successfully")
            }
        }
    }
    
    


    override func viewDidLoad() {
        super.viewDidLoad()
        customizeButton(createe)
        customizeButton(selectImg)
    //customizeTextField(descript)
    }
}
