//
//  ReportsViewController.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/23.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import UIKit

final class ReportsViewController: UIViewController {
  // MARK: Properties
  var environment: Environment?
  var childType: ChildType?
  private var keys: [String] = []
  private var data: [String:[ChildReportType]] = [:]
  private var selectedDate: Date? = nil
  
  // MARK: UI
  @IBOutlet weak var tableView: UITableView!
  
  // MARK: View Life-Cycle
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else { return }
    switch identifier {
    case "ChartsVCSegue":
      if
        let vc = segue.destination as? ChartsViewController,
        let date = selectedDate,
        let env = self.environment,
        let child = self.childType,
        let report = env.checklistRepository.report(child.id, date: date) {
        vc.report = report
      }
    default:
      break
    }
  }
  
  // MARK: View-Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configure()
  }
  
  fileprivate func configure() {
    tableView.tableFooterView = UIView()
    guard let child = childType, let env = environment else { return }
    data = env.checklistRepository.reportsOfMonthly(child.id) ?? [:]
    keys = Array(data.keys)
    tableView.reloadData()
  }
}

// MARK: UITableViewDataSource
extension ReportsViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return keys.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return data[keys[section]]?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ReportTableViewCell", for: indexPath)
    let key = keys[indexPath.section]
    guard let values = data[key] else { return cell }
    let date = values[indexPath.row].date
    let day = Calendar.current.dateComponents([.day], from: date).day ?? .zero
    cell.textLabel?.text = "\(day) 일"
    return cell
  }
}

// MARK: UITableViewDelegte
extension ReportsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return keys[section]
  }
  
  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    let key = keys[indexPath.section]
    guard let values = data[key] else { return indexPath }
    selectedDate = values[indexPath.row].date
    
    return indexPath
  }
}
