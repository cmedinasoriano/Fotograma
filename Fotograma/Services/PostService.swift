//
//  PostService.swift
//  Fotograma
//
//  Created by Erick Sauri on 10/18/17.
//  Copyright © 2017 Erick Sauri. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

struct PostService {
  static func create(for image: UIImage) {
    let imageRef = StorageReference.newPostImageReference()
    
    StorageService.uploadImage(image, at: imageRef, completion: { downloadURL in
      guard let downloadURL = downloadURL else { return }
      
      // Get the url for the image
      let urlString = downloadURL.absoluteString
      let aspectHeight = image.aspectHeight
      // Store post data in database
      create(forURLString: urlString, aspectHeight: aspectHeight)
    })
  }

  static func show(forKey postKey: String, posterUID: String, completion: @escaping (Post?) -> Void) {
    let ref = Database.database().reference().child("posts").child(posterUID).child(postKey)
    
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
      guard let post = Post(snapshot: snapshot) else {
        return completion(nil)
      }
      
      LikeService.isPostLiked(post) { (isLiked) in
        post.isLiked = isLiked
        return completion(post)
      }
    })
  }

  /**
   * Creates new post in database
   *
   */
  private static func create(forURLString urlString: String, aspectHeight: CGFloat) {
    // Create reference to the current user to access their user id
    let currentUser = User.current
    // Initialize a new post
    let post = Post(imageURL: urlString, imageHeight: aspectHeight)
    
    // Get reference to database root
    let rootRef = Database.database().reference()
    
    // Get reference to new post
    let newPostRef = rootRef.child("posts").child(currentUser.uid).childByAutoId()
    
    // Get new post id
    let newPostKey = newPostRef.key
    
    UserService.followers(for: currentUser) { (followerUIDs) in
      // Create timeline dictionary for new post
      let timelinePostDict = ["posted_uid": currentUser.uid]
      
      // Set updated data
      var updatedData: [String: Any] = ["timeline/\(currentUser.uid)/\(newPostKey)": timelinePostDict]
      
      // For every follower
      for uid in followerUIDs {
        // Update their timeline with new post
        updatedData["timeline/\(uid)/\(newPostKey)"] = timelinePostDict
      }
      
      // Get post as dictionary
      let postDict = post.dictValue
      // Update user posts with new post
      updatedData["posts/\(currentUser.uid)/\(newPostKey)"] = postDict
      
      // Update database
      rootRef.updateChildValues(updatedData)
    }
  }
}
