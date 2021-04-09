//
//  ChecklistRepository.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/23.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import Foundation

protocol ChecklistRepository {
  func add(_ report: ChildReportType) -> ChildReportType
  func update(_ report: ChildReportType)
  func update(_ id: UUID, updatedBody: ChildChecklistDetailBody)
  func report(_ child: UUID, date: Date) -> ChildReportType?
  func report(_ id: UUID) -> ChildReportType?
  func report(childID: UUID) -> [ChildReportType]?
  func filteredReport(_ id: UUID) -> ChildReportType?
  func reportsOfMonthly(_ childID: UUID) -> [String:[ChildReportType]]?
}

final class MemoryChecklistRepository: ChecklistRepository {
  private var childReports: [UUID:[ChildReport]]  // child_id:reports
  private var reports: [UUID:ChildReport]
  
  init() {
    reports = [:]
    childReports = [:]
  }
  
  func add(_ report: ChildReportType) -> ChildReportType {
    guard let report = report as? ChildReport else { fatalError() }
    self.reports[report.id] = report
    if var arr = self.childReports[report.child] {
      arr.append(report)
      self.childReports[report.child] = arr
    } else {
      self.childReports[report.child] = [report]
    }
    return report
  }
  
  func update(_ report: ChildReportType) {
    guard let report = report as? ChildReport else { fatalError() }
    self.reports[report.id] = report
    if let arr = self.childReports[report.child] {
      let newArr = arr.map({ $0.id == report.id ? report : $0 })
      self.childReports[report.child] = newArr
    }
  }
  
  func update(_ id: UUID, updatedBody: ChildChecklistDetailBody) {
    guard var report = self.reports[id] else { return }
    
    var checklist = report.checklist
    for (i, section) in checklist.enumerated() {
      for (j, sub) in section.subtitles.enumerated() {
        for (k, body) in sub.body.enumerated() {
          if body.content == updatedBody.content {
            checklist[i].subtitles[j].body[k] = updatedBody
          }
        }
      }
    }
    report.checklist = checklist
    self.reports[id] = report
    
    if let arr = self.childReports[report.child] {
      let newArr = arr.map({ $0.id == report.id ? report : $0 })
      self.childReports[report.child] = newArr
    }
  }
  
  func report(_ id: UUID) -> ChildReportType? {
    return self.reports[id]
  }
  
  func report(_ child: UUID, date: Date) -> ChildReportType? {
    return self.childReports[child]?.first(where: { $0.date.equals(date) })
  }
  
  func report(childID: UUID) -> [ChildReportType]? {
    return self.childReports[childID]
  }
  
  func filteredReport(_ id: UUID) -> ChildReportType? {
    guard let report = self.reports[id] else { return nil }
    
    var filtered: ChildChecklist = []
    for section in report.checklist {
      var filteredSub: [ChildChecklistDetail] = []
      
      for sub in section.subtitles {
        var filteredBody: [ChildChecklistDetailBody] = []
        
        for body in sub.body {
          if body.score == .none { continue }
          filteredBody.append(body)
        }
        if filteredBody.isEmpty == false {
          filteredSub.append(ChildChecklistDetail(head: sub.head, body: filteredBody))
        }
      }
      if filteredSub.isEmpty == false {
        filtered.append(ChildChecklistSection(title: section.title, subtitles: filteredSub))
      }
    }
    return ChildReport(id: report.id, child: report.child, checklist: filtered, date: report.date)
  }
  
  func reportsOfMonthly(_ childID: UUID) -> [String:[ChildReportType]]? {
    guard let data = childReports[childID] else { return nil }
    
    let cal = Calendar.current
    var results: [String:[ChildReportType]] = [:]
    data.forEach { (chlid) in
      let components = cal.dateComponents([.year, .month], from: chlid.date)
      guard let year = components.year, let month = components.month else { return }
      
      let section = "\(year)-\(month)"
      var arr = results[section] ?? []
      arr.append(chlid)
      results[section] = arr
    }
    return results
  }
}
