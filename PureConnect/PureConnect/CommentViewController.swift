//
//  CommentViewController.swift
//  PureConnect
//
//  Created by Darpon Chakma on 17/11/23.
//

import UIKit
import Firebase
import FirebaseStorage

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var ownerName: UILabel!
    
    @IBOutlet weak var commentTime: UILabel!
    
    @IBOutlet weak var commentText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
    }
}


class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var postID: String?
    
    var listComment = [CommentData]()
    
    @IBOutlet weak var TableView: UITableView!
    
    @IBOutlet weak var commentBox: UITextField!
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBAction func commentClicked(_ sender: Any) {
        
        guard let postID = postID else {
            // Handle the case where postID or userID is nil
            return
        }
        
        if let commentData = commentBox.text {
            // Check if the password meets the minimum length requirement
            if commentData.count < 1 {
                let alert = UIAlertController(title: title, message: "Error", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Please write a comment first.", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
        }
        
        let commentsRef = Database.database().reference().child("posts").child(postID).child("Comments").childByAutoId()
        
        let timestamp = 1700207158671 / 1000  // Assuming the timestamp is in milliseconds, convert to seconds

        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"  // Customize the date format as needed
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")  // Set the locale to English

        let formattedDate = dateFormatter.string(from: date)
        
        let commentData: [String: Any] = [
            "owner": SharedData.shared
                .userID,
            "owner_name": SharedData.shared
                .userName,
            "time": formattedDate,
            "comment": commentBox.text ?? ""
        ]
        
        commentsRef.setValue(commentData) { (error, ref) in
            if let error = error {
                print("Error adding comment: \(error.localizedDescription)")
            } else {
                print("Comment added successfully!")
                
                // Display an alert for success
                let successAlert = UIAlertController(title: "Success", message: "Comment added successfully!", preferredStyle: .alert)
                successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    // Clear the commentBox
                    self.commentBox.text = ""
                }))
                self.present(successAlert, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ref = Database.database().reference().child("posts").child(postID!).child("Comments")
        
        ref.observe(.childAdded) { [weak self] snapshot, _ in
            if let commentDict = snapshot.value as? [String: Any] {
                let comment = CommentData(
                    ownerText: commentDict["owner"] as? String ?? "",
                    ownerNameText: commentDict["owner_name"] as? String ?? "",
                    timeText: commentDict["time"] as? String ?? "",
                    commentText: commentDict["comment"] as? String ?? ""
                )

                self?.listComment.append(comment)
                self?.perform(#selector(self?.loadTable), with: nil, afterDelay: 0.5)
            }
        }

    }
    
    @objc func loadTable() {
        self.TableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listComment.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell

        let comment = listComment[indexPath.row]

        // Configure labels
        cell.ownerName.text = comment.ownerNameText
        cell.commentTime.text = comment.timeText
        cell.commentText.text = comment.commentText

        // Customize the profile image
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width / 2
        cell.profileImage.clipsToBounds = true
        cell.profileImage.contentMode = .scaleAspectFill

        // Set a placeholder image while the actual image is loading
        //cell.profileImage.image = UIImage(named: "placeholder_image")

        // Load profile image from Firebase Storage
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("users").child(comment.ownerText).child("profileImage").child("\(comment.ownerText).jpg")

        imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image from Firebase Storage: \(error.localizedDescription)")
            } else if let imageData = data, let profileImage = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    // Set the profile image and update layout
                    cell.profileImage.image = profileImage
                    cell.profileImage.contentMode = .scaleAspectFill
                    cell.profileImage.layer.cornerRadius = 25
                    cell.profileImage.clipsToBounds = true
                    cell.setNeedsLayout()
                    cell.layoutIfNeeded()
                }
            }
        }

        return cell
    }

    
    

}
