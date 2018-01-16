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
    let ref = Database.database().reference().child("followers").child(user.uid)
    
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
    
    let ref = Database.database().reference()
    
    ref.updateChildValues(followData) { (error, _) in
      if let error = error {
        assertionFailure(error.localizedDescription)
      }
      
      success(error == nil)
    }
  }
  
  private static func unFollowUser(_ user: User, forCurrentUserWithSuccess success: @escaping (Bool) -> Void) {
    // Create a dictionary for the multiple locations which will be updated
    let currentUID = User.current.uid
    let followData = [
      "followers/\(user.uid)/\(currentUID)": NSNull(),
      "following/\(currentUID)/\(user.uid)": NSNull(),
      ]
    
    let ref = Database.database().reference()
    
    ref.updateChildValues(followData) { (error, _) in
      if let error = error {
        assertionFailure(error.localizedDescription)
      }
      
      success(error == nil)
    }
  }
}
