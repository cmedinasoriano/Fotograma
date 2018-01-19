//
//  FollowService.swift
//  Fotograma
//
//  Created by Erick Sauri on 1/16/18.
//  Copyright © 2018 Erick Sauri. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct FollowService {
  
  static func setIsFollowing(_ isFollowing: Bool, fromCurrentUserTo followee: User, success: @escaping (Bool) -> Void) {
    if isFollowing {
      followUser(followee, forCurrentUserWithSuccess: success)
    } else {
      unFollowUser(followee, forCurrentUserWithSuccess: success)
    }
  }

  static func isUserFollowed(_ user: User, byCurrentUserWithSuccess completion: @escaping (Bool) -> Void) {
    let currentUID = User.current.uid
    let ref = DatabaseReference.toLocation(.followers(uid: user.uid))
    
    
    ref.queryEqual(toValue: nil, childKey: currentUID).observeSingleEvent(of: .value, with: { (snapshot) in
      if let _ = snapshot.value as? [String : Bool] {
        completion(true)
      } else {
        completion(false)
      }
    })
  }

  private static func followUser(_ user: User, forCurrentUserWithSuccess success: @escaping (Bool) -> Void) {
    // Create a dictionary for the multiple locations which will be updated
    let currentUID = User.current.uid
    let followData = [
      "followers/\(user.uid)/\(currentUID)": true,
      "following/\(currentUID)/\(user.uid)": true,
    ]
    
    let ref = DatabaseReference.FGLocation.root.asDatabaseReference()
    
    ref.updateChildValues(followData) { (error, _) in
      if let error = error {
        assertionFailure(error.localizedDescription)
        success(false)
      }
      
      // Create dispatch group to handle multiple asynchrous operations
      let dispatchGroup = DispatchGroup()
      
      // Enter the dispatch group to watch current user following count
      dispatchGroup.enter()
      
      // Create reference to current user following count
      let followingCountRef = DatabaseReference.toLocation(.followingCount(uid: currentUID))
      followingCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
        // Get the current number of people user follows
        let currentCount = mutableData.value as? Int ?? 0
        // Increase user followings count
        mutableData.value = currentCount + 1
        return TransactionResult.success(withValue: mutableData)
      }, andCompletionBlock: { (error, _, _) in
        if let error = error {
          assertionFailure(error.localizedDescription)
        }
        
        dispatchGroup.leave()
      })
      
      // Enter dispatch group again to watch user follower count
      dispatchGroup.enter()
      
      // Get a reference to the followers of a user
      let followerCountRef = DatabaseReference.toLocation(.followerCount(uid: user.uid))
      followerCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
        // Get the number of followers
        let currentCount = mutableData.value as? Int ?? 0
        // Increase followers
        mutableData.value = currentCount + 1
        return TransactionResult.success(withValue: mutableData)
      }, andCompletionBlock: { (error, _, _) in
        if let error = error {
          assertionFailure(error.localizedDescription)
        }
        
        dispatchGroup.leave()
      })
      
      // Enter dispatch group again to watch user timeline updates
      dispatchGroup.enter()
    
      UserService.posts(for: user) { (posts) in
        // Get all the post ids for the user
        let postKeys = posts.flatMap { $0.key }
        
        // Build multi location dictionary
        var followData = [String: Any]()
        let timelinePostDict = ["poster_uid": user.uid]
        
        // Update each post
        postKeys.forEach { followData["timeline/\(currentUID)/\($0)"] = timelinePostDict }
        
        // Write the dictionary to database
        ref.updateChildValues(followData, withCompletionBlock: { (error, ref) in
          if let error = error {
            assertionFailure(error.localizedDescription)
          }
          
          dispatchGroup.leave()
        })
      }
      
      // Once every request has been executed call success
      dispatchGroup.notify(queue: .main) {
        success(true)
      }
    }
  }
  
  private static func unFollowUser(_ user: User, forCurrentUserWithSuccess success: @escaping (Bool) -> Void) {
    // Create a dictionary for the multiple locations which will be updated
    let currentUID = User.current.uid
    let followData = [
      "followers/\(user.uid)/\(currentUID)": NSNull(),
      "following/\(currentUID)/\(user.uid)": NSNull(),
      ]
    
    let ref = DatabaseReference.FGLocation.root.asDatabaseReference()

    ref.updateChildValues(followData) { (error, _) in
      if let error = error {
        assertionFailure(error.localizedDescription)
        return success(false)
      }
      
      let dispatchGroup = DispatchGroup()
      
      // Watch current user following count
      dispatchGroup.enter()
      
      // Get reference to current user following count
      let followingCountRef = DatabaseReference.toLocation(.followingCount(uid: currentUID))
      // Run transaction
      followingCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
        // Get current number of users followed
        let currentCount = mutableData.value as? Int ?? 0
        // Decrease number of users followed
        mutableData.value = currentCount - 1
        
        return TransactionResult.success(withValue: mutableData)
      }, andCompletionBlock: { (error, _, _) in
        if let error = error {
          assertionFailure(error.localizedDescription)
        }
        
        dispatchGroup.leave()
      })
      
      // Watch user followers count
      dispatchGroup.enter()
      
      // Get reference to user followers count
      let followerCountRef = DatabaseReference.toLocation(.followerCount(uid: user.uid))
      // Run transaction
      followerCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
        // Get current number of user followers
        let currentCount = mutableData.value as? Int ?? 0
        // Decrease number of user followers
        mutableData.value = currentCount - 1
        
        return TransactionResult.success(withValue: mutableData)
      }, andCompletionBlock: { (error, _, _) in
        if let error = error {
          assertionFailure(error.localizedDescription)
        }
        
        dispatchGroup.leave()
      })
      
      // Watch user posts
      dispatchGroup.enter()
      UserService.posts(for: user, completion: { (posts) in
        var unfollowData = [String: Any]()
        let postKeys = posts.flatMap { $0.key }
        
        // Update unfollow data
        postKeys.forEach {
          unfollowData["timeline/\(currentUID)/\($0)"] = NSNull()
        }
        
        ref.updateChildValues(unfollowData, withCompletionBlock: { (error, ref) in
          if let error = error {
            assertionFailure(error.localizedDescription)
          }
          
          dispatchGroup.leave()
        })
      })
      
      // Success
      dispatchGroup.notify(queue: .main) {
        success(true)
      }
    }
  }
}
