//
//  ChildReportRepository.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/23.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import Foundation

protocol ChildReportRepositoryType {
  func add(_ report: ChildReportType)
  func update(_ report: ChildReportType)
  func update(_ id: UUID, updatedBody: ChildChecklistDetailBody)
  func report(_ id: UUID) -> ChildReportType?
  func filteredReport(_ id: UUID) -> ChildReportType?
}
