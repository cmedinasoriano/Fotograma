//
//  UIImage+Size.swift
//  Fotograma
//
//  Created by Erick Sauri on 1/15/18.
//  Copyright © 2018 Erick Sauri. All rights reserved.
//

import UIKit

extension UIImage {
  var aspectHeight: CGFloat {
    let heightRatio = size.height / 736
    let widthRatio = size.width / 414
    let aspectRatio = fmax(heightRatio, widthRatio)
    
    return size.height / aspectRatio
  }
}
