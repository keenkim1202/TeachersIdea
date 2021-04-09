//
//  Environment.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/23.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import Foundation

final class Environment {
  let teacherService: TeacherServiceType
  let childrenService: ChildrenServiceType
  let childRepository: ChildRepository
  let checklistRepository: ChecklistRepository
  let perferenceService: PreferenceService
  
  init(
    teacherService: TeacherServiceType,
    childrenService: ChildrenServiceType,
    childRepository: ChildRepository,
    checklistRepository: ChecklistRepository,
    perferenceService: PreferenceService) {
    self.teacherService = teacherService
    self.childrenService = childrenService
    self.childRepository = childRepository
    self.checklistRepository = checklistRepository
    self.perferenceService = perferenceService
  }
}
