//
//  ChildReport.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/23.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import Foundation

protocol ChildReportType {
  var id: UUID { get set }
  var child: UUID { get set }
  var checklist: ChildChecklist { get set }
  var date: Date { get set }
}

struct ChildReport: ChildReportType, Decodable {
  var id: UUID
  var child: UUID
  var checklist: ChildChecklist
  var date: Date
  
  enum CodingKeys: String, CodingKey {
    case id
    case child
    case checklist
    case date
  }
  
  init(id: UUID, child: UUID, checklist: ChildChecklist, date: Date) {
    self.id = id
    self.child = child
    self.checklist = checklist
    self.date = date
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let uuidString = try container.decode(String.self, forKey: .id)
    guard let uuid = UUID(uuidString: uuidString) else { fatalError() }
    id = uuid
    
    let childUuidString = try container.decode(String.self, forKey: .child)
    guard let childUuid = UUID(uuidString: childUuidString) else { fatalError() }
    child = childUuid
    
    checklist = try container.decode(ChildChecklist.self, forKey: .checklist)
    
    let dateString = try container.decode(String.self, forKey: .date)
    guard let dateKR = DateFormatter.korean.date(from: dateString) else { fatalError() }
    date = dateKR
  }
}
