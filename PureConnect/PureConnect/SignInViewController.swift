//
//  SignInViewController.swift
//  PureConnect
//
//  Created by Darpon Chakma on 10/11/23.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {
    
    @IBOutlet weak var phone: UITextField!
    
    @IBOutlet weak var password: UITextField!
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBAction func signInClicked(_ sender: Any) {
        if let phoneNumber = phone.text,
           let userPassword = password.text {
            
            if !phoneNumber.isEmpty,
               !userPassword.isEmpty {
                
                let ref = Database.database().reference()
                let usersRef = ref.child("users").child(phoneNumber)
                
                usersRef.observeSingleEvent(of: .value) { (snapshot) in
                    if snapshot.exists(),
                       let storedPassword = snapshot.childSnapshot(forPath: "password").value as? String,
                       storedPassword == userPassword {
                        
                        // User exists and password is correct, fetch the name
                        if let userName = snapshot.childSnapshot(forPath: "name").value as? String {
                            
                            // You can use userName here or pass it to another view controller
                            SharedData.shared.userID = phoneNumber
                            SharedData.shared.userName = userName
                            
                            // Save login state
                            UserDefaults.standard.set(true, forKey: "isLoggedIn")
                            
                            self.navigateToHomeViewController()
                        }
                    } else {
                        // User doesn't exist or password is incorrect, show an alert
                        self.showAlert(title: "Error", message: "Invalid phone number or password.")
                    }
                }
            }
            
            else {
                showAlert(title: "Error", message: "All fields must be filled")
            }
        }
    }
    func customizeTextField(_ textField: UITextField) {
        textField.backgroundColor = UIColor(white: 1, alpha: 0.7)
        textField.borderStyle = .roundedRect
        textField.font = UIFont(name: "Helvetica Neue", size: 16)
        // Add other customization as needed
    }
    
    private func navigateToHomeViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Assuming your storyboard is named "Main.storyboard"
        if let homeTabBarController = storyboard.instantiateViewController(withIdentifier: "HomeTabBarController") as? HomeTabBarController {
            self.navigationController?.pushViewController(homeTabBarController, animated: true)
        }
       }

       private func showAlert(title: String, message: String) {
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           present(alert, animated: true, completion: nil)
       }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        customizeTextField(phone)
        customizeTextField(password)
    }
}
