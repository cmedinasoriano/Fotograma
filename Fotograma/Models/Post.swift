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
  
  var dictValue: [String: Any] {
    let timestamp = creationDate.timeIntervalSince1970
    return [
      "image_url": imageURL,
      "image_height": imageHeight,
      "created_at": timestamp,
    ]
  }

  init(imageURL: String, imageHeight: CGFloat) {
    self.imageURL = imageURL
    self.imageHeight = imageHeight
    self.creationDate = Date()
  }
}
