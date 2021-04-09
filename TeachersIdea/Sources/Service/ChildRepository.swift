//
//  ChildRepository.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/17.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import Foundation

protocol ChildRepository {
  func add(child: ChildType)
  func entry(group: Group, indexRow: Int) -> ChildType?
  func fetch(group: Group?) -> [ChildType]
  func numberOfEntries(group: Group?) -> Int
  func remove(child: ChildType)
  func update(child: ChildType) -> ChildType
}

class MemoryChildRepository: ChildRepository {
  fileprivate var children: [MemChild] = []
  
  func add(child: ChildType) {
    children.append(child as! MemChild)
  }
  
  func fetch(group: Group?) -> [ChildType] {
    guard let group = group else { return children }
    return children.filter { $0.group == group }
  }
  
  func entry(group: Group, indexRow: Int) -> ChildType? {
    return children.filter({ $0.group == group })[indexRow]
  }
  
  func numberOfEntries(group: Group?) -> Int {
    guard let group = group else { return children.count }
    return children.filter{ $0.group == group }.count
  }
  
  func remove(child: ChildType) {
    children = children.filter { $0.id != child.id }
  }
  
  func update(child: ChildType) -> ChildType {
    children = children.filter { $0.id != child.id }
    children.append(child as! MemChild)
    return child
  }
}
