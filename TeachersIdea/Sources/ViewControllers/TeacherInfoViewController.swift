//
//  TeacherInfoViewController.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/23.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import UIKit

final class TeacherInfoViewController: UIViewController {
  // MARK: CellType
  private enum CellType {
    case name(value: String)
    case email(value: String)
    case birthday(value: String)
    case phoneNumber(value: String)
  }
  
  // MARK: UI
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var tableView: UITableView!
  
  // MARK: Properties
  private let titleFont = UIFont.systemFont(ofSize: 18, weight: .bold)
  private let contentFont = UIFont.systemFont(ofSize: 17, weight: .medium)
  private var cells: [CellType] = []
  var environment: Environment? = nil
  
  // MARK: View - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    config()
  }

  // MARK: Configuring
  fileprivate func config() {
    tableView.tableFooterView = UIView()
    guard let teacher = environment?.teacherService.currentTeacher else { return }
    profileImageView.image = teacher.thumbnail
    cells = [
      .name(value: teacher.name),
      .email(value: teacher.id),
      .birthday(value: teacher.birthday),
      .phoneNumber(value: teacher.phoneNumber),
    ]
  }
  
  // MARK: Actions
  @IBAction func onLogout(_ sender: Any) {
    guard
      let appDelegate = UIApplication.shared.delegate as? AppDelegate,
      let loginNC = instantiateLoginNC()
      else { return }
    appDelegate.navigate(with: loginNC)
  }
  
  fileprivate func instantiateLoginNC() -> UIViewController? {
    guard
      let nc = storyboard?
        .instantiateViewController(withIdentifier: "LoginNC")
        as? UINavigationController,
      let vc = nc.viewControllers.first as? LoginViewController else {
        return nil
    }
    vc.environment = environment
    return nc
  }
}

// MARK: TeacherInfoViewController + UITableViewDataSource
extension TeacherInfoViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return cells.count
  }
  
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "TeacherInfoCell",
                                             for: indexPath)
    let cellType = cells[indexPath.row]
    cell.backgroundColor = .clear
    cell.textLabel?.font = titleFont
    cell.textLabel?.textColor = UIColor.primaryText
    cell.detailTextLabel?.font = contentFont
    cell.detailTextLabel?.textColor = UIColor.primaryText
    
    switch cellType {
    case .name(let value):
      cell.textLabel?.text = "이름"
      cell.detailTextLabel?.text = value
    case .email(let value):
      cell.textLabel?.text = "이메일 주소"
      cell.detailTextLabel?.text = value
    case .birthday(let value):
      cell.textLabel?.text = "생년월일"
      cell.detailTextLabel?.text = value
    case .phoneNumber(let value):
      cell.textLabel?.text = "전화번호"
      cell.detailTextLabel?.text = value
    }
    return cell
  }
}

// MARK: TeacherInfoViewController + UITableViewDelegate
extension TeacherInfoViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView,
                 heightForRowAt indexPath: IndexPath) -> CGFloat {
    return CGFloat(70)
  }
}
