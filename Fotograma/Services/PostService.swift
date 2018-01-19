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
    let ref = DatabaseReference.toLocation(.showPost(uid: posterUID, postKey: postKey))
    
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

  static func flag(_ post: Post) {
    // Check the the post is an existing post by confirming that it has a key.
    guard let postKey = post.key else { return }
    
    // Build a reference to the DatabaseReference path for flagged posts.
    let flaggedPostRef = DatabaseReference.toLocation(.flaggedPosts(postKey: postKey))
    
    // Create a dictionary with relevant information for the specific flagged post.
    let flaggedDict = [
      "image_url": post.imageURL,
      "poster_uid": post.poster.uid,
      "reporter_uid": User.current.uid
    ]
    
    // Write to the database.
    flaggedPostRef.updateChildValues(flaggedDict)
    
    // Increment a flag count for each time a specific post is flagged.
    let flagCountRef = DatabaseReference.toLocation(.flagCount(postKey: postKey))
    flagCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
      let currentCount = mutableData.value as? Int ?? 0
      
      mutableData.value = currentCount + 1
      
      return TransactionResult.success(withValue: mutableData)
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
    let rootRef = DatabaseReference.FGLocation.root.asDatabaseReference()
    
    // Get reference to new post
    let newPostRef = DatabaseReference.toLocation(.newPost(currentUID: currentUser.uid))
    
    // Get new post id
    let newPostKey = newPostRef.key
    
    UserService.followers(for: currentUser) { (followerUIDs) in
      // Create timeline dictionary for new post
      let timelinePostDict = ["poster_uid": currentUser.uid]
      
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
      rootRef.updateChildValues(updatedData, withCompletionBlock: { (error, ref) in
        // Reference to user post_count
        let postCountRef = DatabaseReference.toLocation(.postCount(uid: currentUser.uid))
        
        // Run transaction block
        postCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
          // Get current post count, otherwise start at 0
          let currentCount = mutableData.value as? Int ?? 0
          // Increase post count
          mutableData.value = currentCount + 1
          // Return post count
          return TransactionResult.success(withValue: mutableData)
        })
      })
    }
  }

}
