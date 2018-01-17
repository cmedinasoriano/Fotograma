//
//  LikeService.swift
//  Fotograma
//
//  Created by Erick Sauri on 1/16/18.
//  Copyright © 2018 Erick Sauri. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct LikeService {
  
  static func create(for post: Post, success: @escaping (Bool) -> Void) {
    // Make sure we get the post id
    guard let key = post.key else {
      return success(false)
    }
    
    // Create reference to user id
    let currentUserId = User.current.uid
    
    // Like post
    let likesRef = DatabaseReference.toLocation(.likes(postKey: key, currentUID: currentUserId))
    
    
    likesRef.setValue(true) { (error, _) in
      if let error = error {
        assertionFailure(error.localizedDescription)
        return success(false)
      }
      
      let likeCountRef = DatabaseReference.toLocation(.likesCount(posterUID: post.poster.uid, postKey: key))
      
      
      likeCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
        let currentCount = mutableData.value as? Int ?? 0
        
        mutableData.value = currentCount + 1
        
        return TransactionResult.success(withValue: mutableData)
      }, andCompletionBlock: { (error, _, _) in
        if let error = error {
          assertionFailure(error.localizedDescription)
          success(false)
        } else {
          success(true)
        }
      })
    }
  }
  
  static func delete(for post: Post, success: @escaping (Bool) -> Void) {
    // Make sure to get the post id
    guard let key = post.key else {
      return success(false)
    }
    
    // Create reference to user id
    let currentUserId = User.current.uid
    
    // Remove post like
    let likesRef = DatabaseReference.toLocation(.likes(postKey: key, currentUID: currentUserId))
    
    likesRef.setValue(nil) { (error, _) in
      if let error = error {
        assertionFailure(error.localizedDescription)
        return success(false)
      }
      
      let likeCountRef = DatabaseReference.toLocation(.likesCount(posterUID: post.poster.uid, postKey: key))
      
      likeCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
        let currentCount = mutableData.value as? Int ?? 0
        
        mutableData.value = currentCount - 1
        
        return TransactionResult.success(withValue: mutableData)
      }, andCompletionBlock: { (error, _, _) in
        if let error = error {
          assertionFailure(error.localizedDescription)
          success(false)
        } else {
          success(true)
        }
      })
    }

  }

  static func setIsLiked(_ isLiked: Bool, for post: Post, success: @escaping (Bool) -> Void) {
    if isLiked {
      create(for: post, success: success)
    } else {
      delete(for: post, success: success)
    }
  }
  
  static func isPostLiked(_ post: Post, byCurrentUserWithCompletion completion: @escaping (Bool) -> Void) {
    // Make sure post has a key
    guard let postKey = post.key else {
      assertionFailure("Error: post must have key")
      return completion(false)
    }
    
    // Get reference to post likes
    let likesRef = DatabaseReference.toLocation(.isLiked(postKey: postKey))
    
    // Query likes for user id
    likesRef.queryEqual(toValue: nil, childKey: User.current.uid).observeSingleEvent(of: .value, with: { (snapshot) in
      // If it exists
      if let _ = snapshot.value as? [String: Bool] {
        // Then post is liked
        completion(true)
      } else {
        // Otherwise it hasn't been liked
        completion(false)
      }
    })
  }
}
