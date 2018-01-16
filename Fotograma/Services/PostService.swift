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
  
  /**
   * Creates new post in database
   *
   */
  private static func create(forURLString urlString: String, aspectHeight: CGFloat) {
    // Create reference to the current user to access their user id
    let currentUser = User.current
    // Initialize a new post
    let post = Post(imageURL: urlString, imageHeight: aspectHeight)
    // Convert the post object into a dictionary
    let dict = post.dictValue
    // Construct the relative path to the location where we want to store the new post data ("posts/${userId}/${postId}")
    let postRef = Database.database().reference().child("posts").child(currentUser.uid).childByAutoId()
    // Write post in location above
    postRef.updateChildValues(dict)
  }
}
