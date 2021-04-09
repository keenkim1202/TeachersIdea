//
//  TeachersIdea+DateFormatter.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/23.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import Foundation

extension DateFormatter {
  static var birthday: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd"
    return formatter
  }
  
  static var korean: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }
}

extension String {
  var date: Date? {
    return DateFormatter.birthday.date(from: self)
  }
}

extension Date {
  var birthday: String {
    return DateFormatter.birthday.string(from: self)
  }
  
  var isToday: Bool {
    return DateFormatter.korean.string(from: self) == DateFormatter.korean.string(from: Date())
  }
  
  func equals(_ date: Date) -> Bool {
    return DateFormatter.korean.string(from: self) == DateFormatter.korean.string(from: date)
  }
}
