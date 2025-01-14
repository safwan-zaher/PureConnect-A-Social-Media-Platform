//
//  TimelineViewController.swift
//  PureConnect
//
//  Created by Darpon Chakma on 11/11/23.
//

import UIKit
import Firebase
import FirebaseStorage

class MyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ownerView: UILabel!
    
    @IBOutlet var profilePic: UIImageView!
    
    @IBOutlet weak var timeView: UILabel!
    
    @IBOutlet weak var likesView: UILabel!
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var descriptView: UILabel!
    
    @IBOutlet weak var heartButton: UIButton!
    
    @IBOutlet weak var commentButton: UIButton!
    
    var heartButtonClickedCallback: (() -> Void)?
    
    var commentButtonClickedCallback: (() -> Void)?
    
    
    @IBAction func heartButtonClicked(_ sender: Any) {
        heartButtonClickedCallback?()
    }
    
    
    @IBAction func commentButtonClicked(_ sender: Any) {
        commentButtonClickedCallback?()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
    }
}

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var TableView: UITableView!
    
    var listPost = [PostData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let ref = Database.database().reference().child("posts")

        // Listen for data changes, order by time in descending order, and limit to the last N posts
        ref.queryOrdered(byChild: "time").queryLimited(toLast: 10).observe(.childAdded) { snapshot in
            if let postDict = snapshot.value as? [String: Any] {
                let post = PostData(idText: snapshot.key ?? "",
                                    ownerText: postDict["owner"] as? String ?? "",
                                    ownerNameText: postDict["owner_name"] as? String ?? "",
                                    timeText: postDict["time"] as? String ?? "",
                                    likesText: postDict["likes"] as? String ?? "",
                                    descriptText: postDict["description"] as? String ?? "")

                // Insert the post at the beginning of the array to show in reverse order
                self.listPost.insert(post, at: 0)

                self.perform(#selector(self.loadTable), with: nil, afterDelay: 0.5)
            }
        }

    }
    
    @objc func loadTable() {
        self.TableView.reloadData()
    }
    
            func showAlert(title: String, message: String) {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
            
            func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                
                return listPost.count
            }
    
    func handleHeartButtonClicked(postID: String, cell: MyTableViewCell) {
        let likesRef = Database.database().reference().child("posts").child(postID).child("Liked_By").child(SharedData.shared.userID!)
        
        Database.database().reference().child("posts").child(postID).child("Liked_By_Name").child(SharedData.shared.userName!)
        
        likesRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                // The post is already liked, remove the like
                likesRef.removeValue { error, _ in
                    if let error = error {
                        print("Error removing like: \(error.localizedDescription)")
                    } else {
                        // Successfully removed the like, update likesView
                        self.updateLikesView(for: postID, in: cell)
                        cell.heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
                    }
                }
            } else {
                // The post is not liked, add the like
                likesRef.setValue("Liked") { error, _ in
                    if let error = error {
                        print("Error adding like: \(error.localizedDescription)")
                    } else {
                        // Successfully added the like, update likesView
                        self.updateLikesView(for: postID, in: cell)
                        cell.heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                    }
                }
            }
        }
    }
    
    func handleCommentButtonClicked(postID: String, cell: MyTableViewCell) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Use your actual storyboard name
            if let commentViewController = storyboard.instantiateViewController(withIdentifier: "CommentViewController") as? CommentViewController {
                commentViewController.postID = postID
                navigationController?.pushViewController(commentViewController, animated: true)
            }
    }

    func updateLikesView(for postID: String, in cell: MyTableViewCell) {
        let likesRef = Database.database().reference().child("posts").child(postID).child("Liked_By")
        likesRef.observeSingleEvent(of: .value) { snapshot in
            let likesCount = snapshot.childrenCount
            cell.likesView.text = "\(likesCount)"
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! MyTableViewCell

        // Set background color and corner radius for the cell
        cell.contentView.backgroundColor = UIColor.white
        cell.contentView.layer.cornerRadius = 10

        let post = listPost[indexPath.row]

        // Configure labels and buttons
        cell.ownerView.text = post.ownerNameText
        cell.timeView.text = post.timeText
        cell.descriptView.text = post.descriptText
        cell.likesView.text = "0" // Set an initial value, will be updated later

        // Customize the font for labels
        cell.ownerView.font = UIFont.boldSystemFont(ofSize: 16)
        cell.timeView.font = UIFont.systemFont(ofSize: 14)
        cell.descriptView.font = UIFont.boldSystemFont(ofSize: 16)
        cell.likesView.font = UIFont.boldSystemFont(ofSize: 14)

        // Customize the heart button appearance
        cell.heartButton.tintColor = UIColor.red
        cell.heartButton.setImage(UIImage(systemName: "heart"), for: .normal)

        // Customize the comment button appearance
        cell.commentButton.tintColor = UIColor.blue
        cell.commentButton.setImage(UIImage(systemName: "message"), for: .normal)

        // Configure button tags and callbacks
        cell.heartButton.tag = indexPath.row
        cell.heartButtonClickedCallback = { [weak self] in
            self?.handleHeartButtonClicked(postID: post.idText, cell: cell)
        }

        cell.commentButton.tag = indexPath.row
        cell.commentButtonClickedCallback = { [weak self] in
            self?.handleCommentButtonClicked(postID: post.idText, cell: cell)
        }

        // Update the likesView initially
        self.updateLikesView(for: post.idText, in: cell)

        // Download and set image asynchronously
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("posts").child(post.idText).child("\(post.idText).jpg")
        let profileImageRef = storageRef.child("users").child(post.ownerText).child("profileImage").child("\(post.ownerText).jpg")

        imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image from Firebase Storage: \(error.localizedDescription)")
            } else if let imageData = data, let profileImage = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    // Set image and update layout
                    cell.imgView.image = profileImage
                    cell.imgView.contentMode = .scaleAspectFill
                    cell.imgView.layer.cornerRadius = 10
                    cell.imgView.clipsToBounds = true
                    cell.setNeedsLayout()
                    cell.layoutIfNeeded()
                }
            }
        }
        
        profileImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image from Firebase Storage: \(error.localizedDescription)")
            } else if let imageData = data, let profileImage = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    // Set image and update layout
                    cell.profilePic.image = profileImage
                    cell.profilePic.contentMode = .scaleAspectFill
                    cell.profilePic.layer.cornerRadius = 25
                    cell.profilePic.clipsToBounds = true
                    cell.setNeedsLayout()
                    cell.layoutIfNeeded()
                }
            }
        }

        // Check if the user has already liked the post
        let likesRef = Database.database().reference().child("posts").child(post.idText).child("Liked_By").child(SharedData.shared.userID!)
        likesRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                // The post is liked, change the button image to "heart.fill"
                cell.heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            }
        }

        return cell
    }
}
