//
//  ChildChecklist.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/23.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import Foundation

// codable : 프로토콜. 여기서는 json형식으로 인코딩, 디코딩 할 수 있도록 하기 위해 채택.
enum ChecklistScore: String, Codable {
  case high   = "우수"
  case mid    = "보통"
  case low    = "미흡"
  case none   = "없음"
  
  func toInt() -> Int { // 체크항목을 정수타입으로 환산.
    switch self {
    case .high: return 10
    case .mid:  return 5
    case .low:  return 2
    case .none: return 0
    }
  }
}

// json 형식으로 받은 체크리스트에서 가져올 정보들을 선언.
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
