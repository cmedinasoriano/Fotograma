//
//  DatabaseReference+Location.swift
//  Fotograma
//
//  Created by Erick Sauri on 1/17/18.
//  Copyright © 2018 Erick Sauri. All rights reserved.
//

import Foundation
import FirebaseDatabase

extension DatabaseReference {
  enum FGLocation {
    case root
    
    case posts(uid: String)
    case showPost(uid: String, postKey: String)
    case newPost(currentUID: String)
    
    case users
    case showUser(uid: String)
    case followerCount(uid: String)
    case followingCount(uid: String)
    case postCount(uid: String)
  
    case timeline(uid: String)
    
    case followers(uid: String)
    
    case likes(postKey: String, currentUID: String)
    case isLiked(postKey: String)
    case likesCount(posterUID: String, postKey: String)

    case flaggedPosts(postKey: String)
    case flagCount(postKey: String)
  
    func asDatabaseReference() -> DatabaseReference {
      let root = Database.database().reference()
      
      switch self {
      case .root:
        return root
      case .posts(let uid):
        return root.child("posts").child(uid)
      case let .showPost(uid, postKey):
        return root.child("posts").child(uid).child(postKey)
        
      case .newPost(let currentUID):
        return root.child("posts").child(currentUID).childByAutoId()
        
      case .users:
        return root.child("users")
        
      case .showUser(let uid):
        return root.child("users").child(uid)
        
      case .followerCount(let uid):
        return root.child("users").child(uid).child("follower_count")

      case .followingCount(let uid):
        return root.child("users").child(uid).child("following_count")
        
      case .postCount(let uid):
        return root.child("users").child(uid).child("post_count")

      case .timeline(let uid):
        return root.child("timeline").child(uid)
        
      case .followers(let uid):
        return root.child("followers").child(uid)
        
      case let .likes(postKey, currentUID):
        return root.child("postLikes").child(postKey).child(currentUID)
        
      case .isLiked(let postKey):
        return root.child("postLikes/\(postKey)")
        
      case let .likesCount(posterUID, postKey):
        return root.child("posts").child(posterUID).child(postKey).child("like_count")
        
      case .flaggedPosts(let postKey):
        return root.child("flagged_posts").child(postKey)
      
      case .flagCount(let postKey):
        return root.child("flagged_posts").child(postKey).child("flag_count")
      }
    }
  }

  static func toLocation(_ location: FGLocation) -> DatabaseReference {
    return location.asDatabaseReference()
  }
}
