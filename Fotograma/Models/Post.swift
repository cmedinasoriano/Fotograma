//
//  Post.swift
//  Fotograma
//
//  Created by Erick Sauri on 1/15/18.
//  Copyright © 2018 Erick Sauri. All rights reserved.
//

import UIKit
import FirebaseDatabase.FIRDataSnapshot

class Post {
  var key: String?
  let imageURL: String
  let imageHeight: CGFloat
  let creationDate: Date
  let poster: User
  var likeCount: Int
  var isLiked: Bool = false
  
  var dictValue: [String: Any] {
    let timestamp = creationDate.timeIntervalSince1970
    let userDict = ["uid": poster.uid, "username": poster.username]
    return [
      "image_url": imageURL,
      "image_height": imageHeight,
      "created_at": timestamp,
      "like_count": likeCount,
      "poster": userDict
    ]
  }

  init(imageURL: String, imageHeight: CGFloat) {
    self.likeCount = 0
    self.imageURL = imageURL
    self.imageHeight = imageHeight
    self.creationDate = Date()
    self.poster = User.current
  }
  
  init?(snapshot: DataSnapshot) {
    guard let dict = snapshot.value as? [String: Any],
      let imageURL = dict["image_url"] as? String,
      let imageHeight = dict["image_height"] as? CGFloat,
      let createdAgo = dict["created_at"] as? TimeInterval,
      let likeCount = dict["like_count"] as? Int,
      let userDict = dict["poster"] as? [String: Any],
      let uid = userDict["uid"] as? String,
      let username = userDict["username"] as? String
  
      else { return nil }
    
    self.key = snapshot.key
    self.imageURL = imageURL
    self.likeCount = likeCount
    self.imageHeight = imageHeight
    self.poster = User(uid: uid, username: username)
    self.creationDate = Date(timeIntervalSince1970: createdAgo)
  }
}
