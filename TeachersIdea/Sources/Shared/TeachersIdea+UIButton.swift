//
//  TeachersIdea+UIButton.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/23.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import UIKit

extension UIButton {
  func applyPrimaryRoundStyle() {
    self.layer.borderColor = UIColor.primary.cgColor
    self.layer.borderWidth = CGFloat(3)
    self.layer.cornerRadius = CGFloat(5)
  }
}
