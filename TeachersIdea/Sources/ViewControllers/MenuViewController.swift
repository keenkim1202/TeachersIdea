//
//  MenuViewController.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/23.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import UIKit

final class MenuViewController: UIViewController {
  // MAKR: Properties
  var environment: Environment?
  var childType: ChildType?
  fileprivate let items: [String] = [
    "🧐 발달 목록",
    "👩‍🔬 관찰 목록",
    "🗓 월별 기록",
    "📊 영역별 성취도",
    "👶 유아 정보"]
  fileprivate var checklistViewType: ChecklistViewController.ViewType = .all
  
  // MARK: UI
  @IBOutlet weak var tableView: UITableView!
  
  // MARK: View Life Cycle
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "InfoVCSegue":
      if let vc = segue.destination as? AddViewController {
        vc.childType = self.childType
        vc.environment = self.environment
      }
      
    case "ChecklistVCSegue":
      if let vc = segue.destination as? ChecklistViewController {
        vc.childType = self.childType
        vc.environment = self.environment
        vc.viewType = self.checklistViewType
      }
      
    case "ChartsVCSegue":
      if
        let vc = segue.destination as? ChartsViewController,
        let env = self.environment,
        let child = self.childType,
        let report = env.checklistRepository.report(child.id, date: Date()) {
        vc.report = report
      }
      
    case "ReportsVCSegue":
      if let vc = segue.destination as? ReportsViewController {
        vc.childType = self.childType
        vc.environment = self.environment
      }
      
    default:
      return
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configure()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    title = self.childType?.name
  }
  
  fileprivate func configure() {
    tableView.tableFooterView = UIView()
  }
}

// MARK: UITableView DataSource

extension MenuViewController: UITableViewDataSource {
  func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let identifier: String
    switch indexPath.row {
    case 0, 1:   identifier = "MenuChecklistCell"
    case 2:   identifier = "MenuReportCell"
    case 3:   identifier = "MenuChartsCell"
    default:  identifier = "MenuInfoCell"
    }
    
    let cell = tableView.dequeueReusableCell(
      withIdentifier: identifier, for: indexPath) as! MenuTableViewCell
    cell.titleLabel.text = items[indexPath.row]
    return cell
  }
}

// MARK: UITableView Delegate
extension MenuViewController: UITableViewDelegate {
  func tableView(
    _ tableView: UITableView,
    willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    switch indexPath.row {
    case 0:
      checklistViewType = .all
    case 1:
      checklistViewType = .filtered
    default:
      break
    }
    return indexPath
  }
}
