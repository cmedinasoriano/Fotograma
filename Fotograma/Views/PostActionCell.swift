//
//  PostActionCell.swift
//  Fotograma
//
//  Created by Erick Sauri on 1/16/18.
//  Copyright © 2018 Erick Sauri. All rights reserved.
//

import UIKit

protocol PostActionCellDelegate: class {
  func didTapLikeButton(_ likeButton: UIButton, on cell: PostActionCell)
}

class PostActionCell: UITableViewCell {

  // MARK: - Properties
  static let height: CGFloat = 46
  weak var delegate: PostActionCellDelegate?

  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var likesLabel: UILabel!
  @IBOutlet weak var likeButton: UIButton!

  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

  @IBAction func likeButtonTapped(_ sender: UIButton) {
    delegate?.didTapLikeButton(sender, on: self)
  }
}
