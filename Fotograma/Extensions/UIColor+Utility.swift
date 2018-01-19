//
//  UIColor+Utility.swift
//  Fotograma
//
//  Created by Erick Sauri on 1/18/18.
//  Copyright © 2018 Erick Sauri. All rights reserved.
//

import UIKit

extension UIColor {
  
  static var fgRed: UIColor {
    return UIColor(hex: 0xE74C3C)
  }

  static var fgGreen: UIColor {
    return UIColor(hex: 0x7DCF85)
  }

  static var fgBlue: UIColor {
    return UIColor(hex: 0x5480F1)
  }
  
  static var fgPurple: UIColor {
    return UIColor(hex: 0xB062EA)
  }
  
  static var fgGray: UIColor {
    return UIColor(hex: 0xDDDCDC)
  }
  
  static var fgLight: UIColor {
    return UIColor(hex: 0xF3F4Fa)
  }
  
  static var fgLightGray: UIColor {
    return UIColor(hex: 0xE4E4E4)
  }

  /*
   * Converts hex integer into UIColor
   */
  private convenience init(hex: Int) {
    let hexColor = (
      R: CGFloat((hex >> 16) & 0xff) / 255,
      G: CGFloat((hex >> 08) & 0xff) / 255,
      B: CGFloat((hex >> 00) & 0xff) / 255
    )
    
    self.init(red: hexColor.R, green: hexColor.G, blue: hexColor.B, alpha: 1)
  }
}
