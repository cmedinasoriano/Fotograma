//
//  UIButton_Utility.swift
//  Fotograma
//
//  Created by Erick Sauri on 1/18/18.
//  Copyright © 2018 Erick Sauri. All rights reserved.
//

import UIKit

extension UIButton {

//  override open var isHighlighted: Bool {
//    didSet {
//      backgroundColor = isHighlighted ? UIColor.fgLightGray : UIColor.clear
//    }
//  }
  
  /*
   * Sets button background color for state
   *
   */
  func setBackgroundColor(_ color: UIColor, for state: UIControlState) {
    UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
    UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
    UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
    let colorImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    setBackgroundImage(colorImage, for: state)
  }
}
