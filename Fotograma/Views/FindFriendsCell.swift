//
//  FindFriendsCell.swift
//  Fotograma
//
//  Created by Erick Sauri on 1/16/18.
//  Copyright © 2018 Erick Sauri. All rights reserved.
//

import UIKit

protocol FindFriendsCellDelegate: class {
  func didTapFollowButton(_ followButton: UIButton, on cell: FindFriendsCell)
}

class FindFriendsCell: UITableViewCell {

  weak var delegate: FindFriendsCellDelegate?
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var followButton: UIButton!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    
    followButton.clipsToBounds = true
    followButton.layer.borderWidth = 1
    followButton.layer.cornerRadius = 24
    followButton.layer.borderColor = UIColor.fgLightGray.cgColor
    followButton.setTitle("Follow", for: .normal)
    followButton.setTitle("Following", for: .selected)
    followButton.setBackgroundColor(UIColor.fgBlue, for: .selected)
    followButton.setBackgroundColor(UIColor.fgLightGray, for: .highlighted)
  }

  @IBAction func followButtonTapped(_ sender: UIButton) {
    delegate?.didTapFollowButton(sender, on: self)
  }
}
