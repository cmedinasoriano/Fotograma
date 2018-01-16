//
//  FindFriendsViewController.swift
//  Fotograma
//
//  Created by Erick Sauri on 10/18/17.
//  Copyright © 2017 Erick Sauri. All rights reserved.
//

import UIKit
import FirebaseAuth

class FindFriendsViewController: UIViewController {
  
  // Mark: - Properties
  var users = [User]()
  
  // Mark - Subviews
  @IBOutlet weak var tableView: UITableView!
  
  // MARK - View Contoller Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Remove separators for empty cells
    tableView.tableFooterView = UIView()
    tableView.rowHeight = 71
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Get all users except current user
    UserService.usersExcludingCurrentUser(completion: { [unowned self] (users) in
      // Set users
      self.users = users
      
      // Update UI on main thread
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    })
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func logoutBtnTapped(_ sender: UIButton) {
    let firebaseAuth = Auth.auth()
    
    do {
      try firebaseAuth.signOut()
      let initialViewController = UIStoryboard.initialViewController(for: .login)
      self.view.window?.rootViewController = initialViewController
      self.view.window?.makeKeyAndVisible()
    } catch let error as NSError {
      print("Error signing out %@", error)
    }
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}

// MARK: - UITableViewDataSource
extension FindFriendsViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return users.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "FindFriendsCell") as! FindFriendsCell
    cell.delegate = self
    configure(cell: cell, atIndexPath: indexPath)

    return cell
  }
  
  func configure(cell: FindFriendsCell, atIndexPath indexPath: IndexPath) {
    let user = users[indexPath.row]
    
    cell.usernameLabel.text = user.username
    cell.followButton.isSelected = user.isFollowed
  }
}

extension FindFriendsViewController: FindFriendsCellDelegate {
  func didTapFollowButton(_ followButton: UIButton, on cell: FindFriendsCell) {
    guard let indexPath = tableView.indexPath(for: cell) else { return }
    
    followButton.isUserInteractionEnabled = false
    
    let followee = users[indexPath.row]
    
    FollowService.setIsFollowing(!followee.isFollowed, fromCurrentUserTo: followee, success: { (success) in
      defer {
        followButton.isUserInteractionEnabled = true
      }
      
      guard success else { return }
      
      followee.isFollowed = !followee.isFollowed
      self.tableView.reloadRows(at: [indexPath], with: .none)
    })
  }
}
