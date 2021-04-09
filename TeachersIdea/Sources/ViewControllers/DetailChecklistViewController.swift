//
//  DetailChecklistViewController.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/23.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import UIKit

final class DetailChecklistViewController: UIViewController {
  
  enum ViewType {
    case all
    case filtered
  }
  
  //
  // MARK: UI
  
  @IBOutlet weak var tableView: UITableView!
  
  //
  // MARK: Properties
  
  var viewType: ViewType = .all
  var reportID: UUID? = nil
  var environment: Environment? = nil
  var selectedIndexPath: IndexPath? = nil
  
  fileprivate var items: [ChildChecklistDetailBody] = []
  
  //
  // MARK: View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configure()
  }

  //
  // MARK: Configuring
  
  fileprivate func configure() {
    tableView.tableFooterView = UIView()
    
    guard
      let reportID = self.reportID,
      let env = self.environment,
      let indexPath = self.selectedIndexPath
      else { return }
    
    let checklist: ChildChecklist
    switch viewType {
    case .all:
      checklist = env.checklistRepository.report(reportID)?.checklist ?? []
      
    case .filtered:
      checklist = env.checklistRepository.filteredReport(reportID)?.checklist ?? []
    }
    
    self.items = checklist[indexPath.section]
      .subtitles[indexPath.row]
      .body
  }
  
  //
  // MARK: Actions
  
  @IBAction func onScoreButton(_ sender: Any) {
    guard let button = sender as? UIButton else { return }
    guard
      let text = button.titleLabel?.text,
      let score = ChecklistScore(rawValue: text) else { return }
    
    let indexRow = button.tag
    if let cell = tableView.cellForRow(at: IndexPath(row: indexRow, section: 0)) as? DetailChecklistTableViewCell {
      cell.updateScore(score)
    }
    self.updateReport(indexRow: indexRow, score: score)
  }
  
  fileprivate func updateReport(indexRow: Int, score: ChecklistScore) {
    guard
      let reportID = self.reportID,
      let env = self.environment,
      let indexPath = self.selectedIndexPath else { return }
    
    switch viewType {
    case .all:
      if var report = env.checklistRepository.report(reportID) {
        report
          .checklist[indexPath.section]
          .subtitles[indexPath.row]
          .body[indexRow].score = score
        env.checklistRepository.update(report)
      }
      
    case .filtered:
      if let report = env.checklistRepository.filteredReport(reportID) {
        var updatedBody = report
          .checklist[indexPath.section]
          .subtitles[indexPath.row]
          .body[indexRow]
        updatedBody.score = score
        env.checklistRepository.update(report.id, updatedBody: updatedBody)
      }
    }
  }
}

//
//MARK: Datasource
extension DetailChecklistViewController: UITableViewDataSource {
  
  func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: "DetailChecklistCell", for: indexPath)
      as! DetailChecklistTableViewCell
    let item = items[indexPath.row]
    cell.configure(indexRow: indexPath.row, title: item.content, score: item.score)
    return cell
  }
}

//
//MARK: Delegate
extension DetailChecklistViewController: UITableViewDelegate {
}
