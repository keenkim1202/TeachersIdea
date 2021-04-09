//
//  ChildTableViewController.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/17.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher

final class ChildTableViewController: UIViewController {
  
  //
  // MARK: Properties
  
  var environment: Environment?
  fileprivate var entries: [ChildType] = []
  fileprivate var filterEntries: [ChildType] = []
  fileprivate var selectedChildType: ChildType?
  fileprivate var searchWord: String? = nil
  fileprivate var filtered: Bool = false
  
  //
  // MARK: UI
  
  @IBOutlet weak var tableView: UITableView!
  private let searchController: UISearchController = UISearchController()
  
  //
  // MARK: View Life Cycle
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "AddVCSegue":
      if let vc = segue.destination as? AddViewController {
        vc.environment = self.environment
      }
      
    case "MenuVCSegue":
      if let vc = segue.destination as? MenuViewController {
        vc.environment = self.environment
        vc.childType = self.selectedChildType
      }
      
    case "TeacherInfoVCSegue":
      if let vc = segue.destination as? TeacherInfoViewController {
        vc.environment = self.environment
      }
      
    case "AnalysisVCSegue":
      if let vc = segue.destination as? AnalysisViewController {
        vc.environment = self.environment
      }
      
    default:
      break
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    guard let teacher = environment?.teacherService.currentTeacher else { return }
    title = "\(teacher.group.rawValue) 목록"
    tableView.tableFooterView = UIView()
    
    // Setup the search controller
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "이름으로 검색을 할 수 있습니다."
    navigationItem.searchController = searchController
    definesPresentationContext = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    fetch()
  }
  
  //
  // MARK: Fetching
  
  fileprivate func fetch() {
    guard
      let childrenService = environment?.childrenService,
      let teacher = environment?.teacherService.currentTeacher else { return }
    //
    //        childrenService.fetch(group: teacher.group, completion: { result in
    //            switch result {
    //            case .success(let children):
    //
    //                DispatchQueue.main.async {
    //                    self.entries = children
    //                    self.tableView.reloadData()
    //                }
    //
    //            case .failure(_):
    //                break
    //            }
    //        })
    
    // MemoryRepository
    self.entries = environment?.childRepository.fetch(group: teacher.group) ?? []
  }
}

//
// MARK: - Table view data source

extension ChildTableViewController: UITableViewDataSource {
  func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
    return filtered ? filterEntries.count : entries.count
  }
  
  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: "ChildTableViewCell", for: indexPath) as! ChildTableViewCell
    
    let child = filtered ? filterEntries[indexPath.row] : entries[indexPath.row]
    cell.config(child)
    return cell
  }
}

extension ChildTableViewController: UITableViewDelegate {
  
  func tableView(
    _ tableView: UITableView,
    willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    selectedChildType = filtered ? filterEntries[indexPath.row] : entries[indexPath.row]
    if let cell = tableView.cellForRow(at: indexPath) as? ChildTableViewCell {
      selectedChildType?.photo = cell.thumbnailView.image
    }
    return indexPath
  }
}

extension ChildTableViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchWord = searchController.searchBar.text
    
    guard self.searchWord != searchWord else { return }
    filtered = (searchWord?.isEmpty ?? true).negate
    
    if filtered {
      filterEntries = entries.filter { $0.name.contains(searchWord ?? "") }
    }
    tableView.reloadData()
  }
}
