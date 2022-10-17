//
//  FeedViewController.swift
//  Parstagram
//
//  Created by 洪裕權 on 10/7/22.
//

import UIKit
import Parse
import AlamofireImage
import CryptoKit
class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	

	@IBOutlet weak var tableView: UITableView!
	var posts = [PFObject]()
	
	override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		let query = PFQuery(className: "Posts")
		query.includeKey("author")
		// get 20 posts
		query.limit = 20
		// store the data
		query.findObjectsInBackground { (posts, error) in
			if posts != nil {
				self.posts = posts!
				self.tableView.reloadData()
			}
		}
	}
    

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
		let post = posts[indexPath.row]
		let user = post["author"] as! PFUser
		print(post)
		cell.usernameLabel.text = user.username
        cell.captionLabel.text = post["caption"] as? String
		let imageFile = post["image"] as! PFFileObject
		let urlString = imageFile.url!
		let url = URL(string: urlString)!
		// cell.posterView.af_setImage -> deprecated
		cell.photoView.af.setImage(withURL: url)
		return cell
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return posts.count
	}

    @IBAction func onLogoutButton(_ sender: Any) {
        print("logout triggered!")
        PFUser.logOut()
        // parse the xml
        let main = UIStoryboard(name: "Main", bundle: nil)
        // get the loginViewController
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        // get the shared object
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windowScene.delegate as? SceneDelegate else { return }
        delegate.window?.rootViewController = loginViewController
    }
    // Implenent comments
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        let comment = PFObject(className: "Comments")
        comment["text"] = "This is a random comment"
        comment["post"] = post
        comment["author"] = PFUser.current()!
        // add a commnets column in the post table and add the comment id
        post.add(comment, forKey: "comments")
        // save the post
        post.saveInBackground { (success, error) in
            if success {
                print("Comment saved")
            } else {
                print("Error saving comment")
            }
        }
        
    }
}
