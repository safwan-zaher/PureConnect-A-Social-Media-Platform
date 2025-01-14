//
//  ViewController.swift
//  PureConnect
//
//  Created by Darpon Chakma on 10/11/23.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.navigateToSignInViewController()
        }
    }
    
    private func navigateToSignInViewController() {
            // Navigate to SignInViewController
            let storyboard = UIStoryboard(name: "Main", bundle: nil) // Assuming your storyboard is named "Main.storyboard"
            if let signInViewController = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController {
                self.navigationController?.pushViewController(signInViewController, animated: true)
            }
        }
}
