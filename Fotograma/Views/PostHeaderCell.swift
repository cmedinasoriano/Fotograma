//
//  PostHeaderCell.swift
//  Fotograma
//
//  Created by Erick Sauri on 1/16/18.
//  Copyright © 2018 Erick Sauri. All rights reserved.
//

import UIKit

class PostHeaderCell: UITableViewCell {

  static let height: CGFloat = 54
  @IBOutlet weak var usernameLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  

  @IBAction func optionsButtonTapped(_ sender: UIButton) {
  }
}
