//
//  ChildChecklist.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/23.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import Foundation

enum ChecklistScore: String, Codable {
  case high   = "우수"
  case mid    = "보통"
  case low    = "미흡"
  case none   = "없음"
  
  func toInt() -> Int {
    switch self {
    case .high: return 10
    case .mid:  return 5
    case .low:  return 2
    case .none: return 0
    }
  }
}

struct ChildChecklistSection : Codable {
  var title: String
  var subtitles: [ChildChecklistDetail]
}

struct ChildChecklistDetail : Codable {
  var head: String
  var body: [ChildChecklistDetailBody]
}

struct ChildChecklistDetailBody: Codable {
  var content: String
  var score: ChecklistScore
}

typealias ChildChecklist = [ChildChecklistSection]
