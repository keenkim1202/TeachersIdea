//
//  ChecklistViewController.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/23.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import UIKit

final class ChecklistViewController: UIViewController {
  // MARK: Enum
  enum ViewType {
    case all
    case filtered
  }
  
  // MARK: Properties
  var childType: ChildType?
  var environment: Environment? = nil
  var viewType: ViewType = .all
  
  fileprivate var childChecklist: ChildChecklist? = nil
  fileprivate var selectedIndexPath: IndexPath? = nil
  fileprivate var reportID: UUID? = nil
  
  // MARK: View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configure()
  }
  
  // MARK: Configuring
  fileprivate func configure() {
    guard
      let path = Bundle.main.path(forResource: "checklist_3", ofType: "json"),
      let data = FileManager.default.contents(atPath: path),
      let checklist = try? JSONDecoder().decode(ChildChecklist.self, from: data) else {
        return
    }
    
    guard
      let child = self.childType,
      let env = self.environment else { return }
    
    let today = Date()
    if let report = env.checklistRepository.report(child.id, date: today) {
      // 발달목록이 한번 이상 설정된 경우,
      self.childChecklist = report.checklist
      reportID = report.id
    } else {
      // 처음 발달목록을 설정할 때,
      let report = env.checklistRepository.add(ChildReport(id: UUID(), child: child.id, checklist: checklist, date: today))
      self.childChecklist = checklist
      reportID = report.id
    }
    
    if let reportID = self.reportID, viewType == .filtered {
      self.childChecklist = env.checklistRepository.filteredReport(reportID)?.checklist
    }
  }
  
  // MARK: Navigate
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else { return }
    switch identifier {
    case "ChecklistDetailSegue":
      if let vc = segue.destination as? DetailChecklistViewController {
        vc.viewType = self.viewType == .all ? .all : .filtered
        vc.reportID = self.reportID
        vc.environment = self.environment
        vc.selectedIndexPath = self.selectedIndexPath
      }
    default:
      break
    }
  }
}

//MARK: Datasource
extension ChecklistViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return childChecklist?.count ?? 0
  }
  
  func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
    guard let childChecklist = self.childChecklist else { return 0 }
    return childChecklist[section].subtitles.count
  }
  
  func tableView(
    _ tableView: UITableView,
    titleForHeaderInSection section: Int) -> String? {
    guard let childChecklist = self.childChecklist else { return nil }
    return childChecklist[section].title
  }
  
  
  func tableView(
    _ tableView: UITableView,
    willDisplayHeaderView view: UIView, forSection section: Int) {
    guard let header = view as? UITableViewHeaderFooterView else { return }
    header.tintColor = .white
    header.textLabel?.textColor = UIColor.primaryText
  }
  
  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistTitleCell", for: indexPath)
    guard let childChecklist = self.childChecklist else { return cell }
    let section = childChecklist[indexPath.section]
    cell.textLabel?.text = section.subtitles[indexPath.row].head
    return cell
  }
  
}

//MARK: Delegate
extension ChecklistViewController: UITableViewDelegate {
  func tableView(
    _ tableView: UITableView,
    willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    self.selectedIndexPath = indexPath
    return indexPath
  }
}
