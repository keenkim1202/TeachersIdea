//
//  ChildTableViewCell.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/17.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import UIKit
import Kingfisher

final class ChildTableViewCell: UITableViewCell {
  @IBOutlet weak var thumbnailView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var ageLabel: UILabel!
  @IBOutlet weak var bodyInfoLabel: UILabel!
  
  func config(_ child: ChildType) {
    nameLabel.text = child.name
    ageLabel.text = "만 \(toAge(from: child.birthday))세"
    bodyInfoLabel.text =
    "\(toString(from: child.height)) m / \(toString(from: child.weight)) kg"
    thumbnailView.contentMode = .scaleAspectFill
    thumbnailView.layer.cornerRadius = thumbnailView.frame.size.width / 2
    if let url = child.photoUrl {
      thumbnailView.kf.setImage(with: url)
    }
  }
  
  fileprivate func toAge(from birthday: String) -> Int {
    guard let date = birthday.date else { return .zero }
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year], from: date, to: Date())
    return components.year ?? .zero
  }
  
  fileprivate func toString(from num: Float) -> String {
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = 1
    formatter.maximumFractionDigits = 1
    return formatter.string(from: NSNumber(value: num)) ?? ""
  }
}
