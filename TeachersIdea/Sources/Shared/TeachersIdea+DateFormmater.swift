//
//  TeachersIdea+DateFormmater.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/23.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import Foundation

extension DateFormatter {
  func toDate(date: String) -> Date {
    self.dateFormat = "yyyy/MM/dd"
    return self.date(from: date)!
  }
  
  func toString(date: Date) -> String {
    self.dateFormat = "yyyy/MM/dd"
    return self.string(from: date)
  }
}
