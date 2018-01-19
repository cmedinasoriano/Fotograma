//
//  ProfileViewController.swift
//  Fotograma
//
//  Created by Erick Sauri on 1/18/18.
//  Copyright © 2018 Erick Sauri. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ProfileViewController: UIViewController {

  // MARK - Subviews
  @IBOutlet weak var collectionView: UICollectionView!
  
  // MARK - Properties
  var user: User!
  var posts = [Post]()

  var authHandle: AuthStateDidChangeListenerHandle?
  var profileHandle: DatabaseHandle = 0
  var profileRef: DatabaseReference?

  // MARK - VC Lifecyle
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    user = user ?? User.current
    navigationItem.title = user.username
    
    if user.uid == User.current.uid {
      authHandle = Auth.auth().addStateDidChangeListener() { [unowned self] (auth, user) in
        guard user == nil else { return }
        
        let loginViewController = UIStoryboard.initialViewController(for: .login)
        self.view.window?.rootViewController = loginViewController
        self.view.window?.makeKeyAndVisible()
      }
    }
  
    profileHandle = UserService.observeProfile(for: user) { [unowned self] (ref, user, posts) in
      self.profileRef = ref
      self.user = user
      self.posts = posts
      
      DispatchQueue.main.async {
        self.collectionView.reloadData()
      }
    }
  }

  deinit {
    // Unsubscribe from observer when view controller is dismissed
    profileRef?.removeObserver(withHandle: profileHandle)
    
    if let authHandle = authHandle {
      Auth.auth().removeStateDidChangeListener(authHandle)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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

/*
 * UICollectionViewDelegateFlowLayout
 */
extension ProfileViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let columns: CGFloat = 3
    let spacing: CGFloat = 0.5
    let totalHorizontalSpacing = (columns - 1) * spacing
    
    let itemWidth = (collectionView.bounds.width - totalHorizontalSpacing) / columns
    let itemSize = CGSize(width: itemWidth, height: itemWidth)
    
    return itemSize
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0.5
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0.5
  }
}

/*
 * UICollectionViewDataSource
 */
extension ProfileViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return posts.count
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    guard kind == UICollectionElementKindSectionHeader else {
      fatalError("Unexpected element kind.")
    }
    
    let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ProfileHeaderView", for: indexPath) as! ProfileHeaderView
    
    let postCount = user.postCount ?? 0
    let followerCount = user.followerCount ?? 0
    let followingCount = user.followingCount ?? 0
    
    headerView.postCountLabel.text = "\(postCount)"
    headerView.followerCountLabel.text = "\(followerCount)"
    headerView.followingCountLabel.text = "\(followingCount)"

    // Set header view delegate as this view controller
    headerView.delegate = self

    return headerView
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostThumbImageCell", for: indexPath) as! PostThumbImageCell
    let post = posts[indexPath.row]
    let imageURL = URL(string: post.imageURL)
    
    cell.thumbImageView.kf.setImage(with: imageURL)
    
    return cell
  }
}

extension ProfileViewController: ProfileHeaderViewDelegate {
  func didTapSettingsButton(_ button: UIButton, on headerView: ProfileHeaderView) {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    let signOutAction = UIAlertAction(title: "Sign Out", style: .default) { _ in
      do {
        try Auth.auth().signOut()
      } catch let error as NSError {
        assertionFailure("Error signing out: \(error.localizedDescription)")
      }
    }

    if user.uid == User.current.uid {
      alertController.addAction(signOutAction)
    }
    
    alertController.addAction(cancelAction)

    present(alertController, animated: true)
  }
}
