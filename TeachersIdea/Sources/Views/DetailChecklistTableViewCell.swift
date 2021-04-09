//
//  DetailChecklistTableViewCell.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/23.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import UIKit

final class DetailChecklistTableViewCell: UITableViewCell {
  
  //
  // MARK: UI Properties
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var badButton: UIButton!
  @IBOutlet weak var normalButton: UIButton!
  @IBOutlet weak var goodButton: UIButton!
  
  //
  // MARK: Configuring
  
  func configure(indexRow: Int, title: String, score: ChecklistScore = .none) {
    titleLabel.text = title
    configureButtons(indexRow)
    updateScore(score)
  }
  
  fileprivate func configureButtons(_ indexRow: Int) {
    badButton.applyPrimaryRoundStyle()
    normalButton.applyPrimaryRoundStyle()
    goodButton.applyPrimaryRoundStyle()
    
    badButton.tag = indexRow
    normalButton.tag = indexRow
    goodButton.tag = indexRow
  }
  
  fileprivate func updateSubviews() {
    badButton.backgroundColor = badButton.isSelected ? .primary : .white
    normalButton.backgroundColor = normalButton.isSelected ? .primary : .white
    goodButton.backgroundColor = goodButton.isSelected ? .primary : .white
  }
  
  func updateScore(_ score: ChecklistScore) {
    switch score {
    case .low:
      badButton.isSelected = true
      normalButton.isSelected = false
      goodButton.isSelected = false
      
    case .mid:
      badButton.isSelected = false
      normalButton.isSelected = true
      goodButton.isSelected = false
      
    case .high:
      badButton.isSelected = false
      normalButton.isSelected = false
      goodButton.isSelected = true
      
    case .none:
      badButton.isSelected = false
      normalButton.isSelected = false
      goodButton.isSelected = false
    }
    updateSubviews()
  }
}
