//
//  MemberJoinViewController.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/07/25.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import UIKit
import Lottie
import FirebaseAuth

final class MemberJoinViewController: UIViewController {
  //MARK: Enum
  enum CellType: String {
    case email = "이메일"
    case name = "이름"
    case phone = "전화번호"
    case password = "비밀번호"
    case birthday = "생년월일"
    case profileImage = "프로필 사진"
  }
  
  // MARK: Properties
  var environment: Environment?
  fileprivate var cells: [CellType] = [.profileImage, .email, .password, .name, .phone, .birthday]
  fileprivate var profileImage: UIImage? = nil
  fileprivate var isLoading: Bool = false {
    didSet {
      loadingView.isHidden = isLoading.negate
      doneButton.isEnabled = isLoading.negate
    }
  }
  
  // MARK: UI
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var loadingView: UIView!
  @IBOutlet weak var containerAnimationView: UIView!
  @IBOutlet weak var doneButton: UIBarButtonItem!
  private let animationView = AnimationView(name: "loading-cloud")
  
  // MARK: Life View Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configure()
    configureAnimationView()
  }
  
  fileprivate func configure() {
    self.title = "회원가입"
    self.navigationController?.navigationBar.isHidden = false
    self.tableView.tableFooterView = UIView()
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillChangeFrame(notification:)),
      name: UIResponder.keyboardWillChangeFrameNotification,
      object: nil)
  }
  
  fileprivate func configureAnimationView() {
    isLoading = false
    animationView.frame = containerAnimationView.bounds
    animationView.loopMode = .loop
    containerAnimationView.addSubview(animationView)
  }
  
  // MARK: Configuring Alert
  fileprivate func showAlert(_ message: String) {
    UIAlertController
      .show(self, contentType: .error, message: message)
  }
  
  @IBAction func onDone(_ sender: Any) {
    view.endEditing(true)
    let contents = cells
      .enumerated()
      .map { elem -> String? in
        let cell = self.tableView.cellForRow(at: IndexPath(row: elem.offset, section: 0)) as? MemberJoinTableViewCell
        switch cells[elem.offset] {
        case .profileImage:
          return nil
          
        case .birthday:
          return cell?.contentDatePicker.date.birthday
          
        default:
          return cell?.contentTextField.text
        }
      }
    
    // firebase 계정 생성
    guard
      let profileImage = profileImage,
      let email = contents[1],
      let password = contents[2],
      let name = contents[3],
      let phoneNumber = contents[4],
      let birthday = contents[5],
      email.isEmpty == false,
      password.isEmpty == false,
      name.isEmpty == false,
      phoneNumber.isEmpty == false,
      birthday.isEmpty == false else {
      self.showAlert("모든 칸을 입력해주세요.")
      return
    }
    
    isLoading = true
    animationView.play()
    // 신규 사용자가 양식을 작성하면 유효성을 검사한 후 createUser 메소드에 전달.
    Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
      guard error == nil else { // error 발생 여부를 확인하기 위해서.
        self.isLoading = false
        self.animationView.stop()
        self.showAlert(error?.localizedDescription ?? "")
        return
      }
      
      let newTeacher = Teacher(
        id: email,
        name: name,
        birthday: birthday,
        phoneNumber: phoneNumber,
        group: .star,
        thumbnail: profileImage)
      self.environment?.teacherService.add(newTeacher) { result in
        self.isLoading = false
        self.animationView.stop()
        switch result {
        case .success:
          // 회원가입 정보를 입력한 후 Done 버튼을 눌렀을 떄 이전화면을 띄워준다.
          self.navigationController?.popViewController(animated: true)
          
        case .failure:
          self.showAlert("회원가입에 실패했습니다.😞\n관리자에게 문의해주세요.🙏")
        }
      }
    }
  }
  
  @objc private func presentPickerImage(_ sender: UIButton) {
    let imagePickerController = UIImagePickerController()
    imagePickerController.sourceType = .photoLibrary
    imagePickerController.delegate = self
    self.present(imagePickerController, animated: true, completion: nil)
  }
  
  // MARK: Configure Keyboard
  @objc fileprivate func keyboardWillChangeFrame(notification: Notification) {
    guard
      let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
        as? CGRect,
      let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey]
        as? TimeInterval
    else { return }
    
    let keyboardVisibleHeight = UIScreen.main.bounds.height - keyboardFrame.origin.y
    UIView.animate(withDuration: duration) {
      self.tableView.contentInset.bottom = keyboardVisibleHeight
    }
  }
}

//MARK: Datasource
extension MemberJoinViewController: UITableViewDataSource {
  func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
    return cells.count
  }
  
  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cellType = cells[indexPath.row]
    let cell: MemberJoinTableViewCell?
    switch cellType {
    case .profileImage:
      cell = tableView.dequeueReusableCell(withIdentifier: "MemberJoinImageCell",
                                           for: indexPath) as? MemberJoinTableViewCell
      cell?.thumbnailView.image = self.profileImage ?? UIImage(named: "account_box")
      cell?.thumbnailPickerButton
        .addTarget(self, action: #selector(presentPickerImage(_:)), for: .touchUpInside)
      
    case .birthday:
      cell = tableView.dequeueReusableCell(withIdentifier: "MemberJoinPickerCell",
                                           for: indexPath) as? MemberJoinTableViewCell
      
    default:
      cell = tableView.dequeueReusableCell(withIdentifier: "MemberJoinCell",
                                           for: indexPath) as? MemberJoinTableViewCell
      cell?.contentTextField.placeholder = cellType.rawValue
    }
    cell?.titleLabel.text = cellType.rawValue
    return cell!
  }
}

//MARK: Delegate
extension MemberJoinViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let cell = cells[indexPath.row]
    switch cell {
    case .profileImage:
      return CGFloat(230)
    default:
      return UITableView.automaticDimension
    }
  }
}

// MARK: UINavigationControllerDelegate
extension MemberJoinViewController: UINavigationControllerDelegate {
}

// MARK: UIImagePickerControllerDelegate
extension MemberJoinViewController: UIImagePickerControllerDelegate {
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard let selectedImage = info[.originalImage] as?
            UIImage else {
      fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
    }
    self.profileImage = selectedImage
    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    
    dismiss(animated: true, completion: nil)
  }
}
