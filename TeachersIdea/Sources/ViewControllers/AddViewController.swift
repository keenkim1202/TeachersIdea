//
//  AddViewController.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/23.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import UIKit
import Lottie

final class AddViewController : UIViewController {
  
  enum Item: String {
    case photo = "AddPhotoCell"
    case name = "AddNameCell"
    case birthday = "AddBirthdayCell"
    case height = "AddHeightCell"
    case weight = "AddWeightCell"
    case momPhone = "AddMomPhoneCell"
    case dadPhone = "AddDadPhoneCell"
    case comment = "AddCommentCell"
    
    func dequeueCell(_ tableView: UITableView) -> UITableViewCell? {
      let cell = tableView.dequeueReusableCell(withIdentifier: self.rawValue)
      return cell
    }
  }
  
  enum ViewType {
    case add
    case update
  }
  
  //
  // MARK: Properties
  
  var environment: Environment?
  var childType: ChildType?
  fileprivate let accountBoxImage = UIImage(named: "account_box")
  fileprivate var photo: UIImage? = UIImage(named: "account_box")
  fileprivate var items: [Item] = [
    .photo,
    .name,
    .birthday,
    .height,
    .weight,
    .momPhone,
    .dadPhone,
    .comment,
  ]
  fileprivate var itemInputs: [Item:String] = [:]
  fileprivate var viewType: ViewType = .add
  fileprivate var isLoading: Bool = false {
    didSet {
      loadingView.isHidden = isLoading.negate
      doneButton.isEnabled = isLoading.negate
    }
  }
  
  //
  // MARK: UI
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var loadingView: UIView!
  @IBOutlet weak var animationContainerView: UIView!
  @IBOutlet weak var doneButton: UIBarButtonItem!
  private let animationView: AnimationView = AnimationView(name: "loading-cloud")
  
  //
  // MARK: View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configure()
  }
  
  //
  // MARK: Configuriong
  fileprivate func configure() {
    loadingView.isHidden = isLoading.negate
    
    animationView.frame = animationContainerView.bounds
    animationView.loopMode = .loop
    animationContainerView.addSubview(animationView)
    
    tableView.tableFooterView
      = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
    
    // Configure Keyboard Event
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillChangeFrame(notification:)),
      name: UIResponder.keyboardWillChangeFrameNotification,
      object: nil)
    
    if self.childType != nil {
      title = "유아 정보"
      viewType = .update
    }
    
    for item in items {
      switch item {
      case .photo:
        photo = childType?.photo ?? accountBoxImage
        
      case .name:
        itemInputs[.name] = childType?.name
        
      case .birthday:
        itemInputs[.birthday] = childType?.birthday
        
      case .height:
        itemInputs[.height] = "\(childType?.height ?? 0)"
        
      case .weight:
        itemInputs[.weight] = "\(childType?.weight ?? 0)"
        
      case .momPhone:
        itemInputs[.momPhone] = childType?.momPhone
        
      case .dadPhone:
        itemInputs[.dadPhone] = childType?.dadPhone
        
      case .comment:
        itemInputs[.comment] = childType?.comment
      }
    }
  }
  
  //
  // MARK: UI Actions
  
  @IBAction func onDone(_ sender: Any) {
    self.tableView.endEditing(true)
    guard
      let childrenService = self.environment?.childrenService,
      let repo = self.environment?.childRepository,
      let teacher = self.environment?.teacherService.currentTeacher
      else { return }
    
    guard let name = itemInputs[.name] else {
      showAlert("이름을 입력해주세요.")
      return
    }
    guard let birthday = itemInputs[.birthday] else {
      showAlert("생년월일을 입력해주세요.")
      return
    }
    guard let height = itemInputs[.height] else {
      showAlert("아이의 키를 입력해주세요.")
      return
    }
    guard let weight = itemInputs[.weight] else {
      showAlert("아이의 몸무게를 입력해주세요.")
      return
    }
    
    isLoading = true
    animationView.play()
    let child = MemChild(
      group: teacher.group,
      birthday: birthday,
      comment: itemInputs[.comment],
      height: Float(height),
      id: self.childType?.id,
      name: name,
      photo: photo,
      weight: Float(weight),
      momPhone: itemInputs[.momPhone],
      dadPhone: itemInputs[.dadPhone])
    switch self.viewType {
    case .add:
      repo.add(child: child) //
      childrenService.add(child) { result in
        self.isLoading = false
        self.animationView.stop()
        switch result {
        case .success:
          self.navigationController?.popViewController(animated: true)
          
        case .failure(_):
          self.showAlert("추가에 실패했습니다.😞\n관리자에게 문의해주세요.")
        }
      }
      
    case .update:
      repo.update(child: child) //
      childrenService.update(child) { result in
        self.isLoading = false
        self.animationView.stop()
        switch result {
        case .success:
          self.navigationController?.popViewController(animated: true)
          
        case .failure(_):
          self.showAlert("업데이트에 실패했습니다.😞\n관리자에게 문의해주세요.")
        }
      }
    }
  }
  
  @objc fileprivate func imageChooser(_ sender: UIButton) {
    let imagePickerController = UIImagePickerController()
    imagePickerController.sourceType = .photoLibrary
    imagePickerController.delegate = self
    self.present(imagePickerController, animated: true, completion: nil)
  }
  
  //
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
  
  //
  // MARK: Configuring Alert
  
  fileprivate func showAlert(_ message: String) {
    UIAlertController
      .show(self, contentType: .error, message: message)
  }
}

//
// MARK: UITextFieldDelegate
extension AddViewController: UITextFieldDelegate {
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    let item = items[textField.tag]
    itemInputs[item] = textField.text
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    switch textField.returnKeyType {
    case .next:
      tableView.viewWithTag(textField.tag + 1)?.becomeFirstResponder()
      
    default:
      tableView.endEditing(true)
    }
    return false
  }
}

//
// MARK: UITableViewDataSource

extension AddViewController: UITableViewDataSource {
  func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let item = items[indexPath.row]
    let cell = item.dequeueCell(tableView) as! AddTableViewCell
    if let textField = cell.textField {
      textField.delegate = self
      textField.tag = indexPath.row
    }
    
    switch item {
    case .photo:
      cell.photoView.layer.cornerRadius = CGFloat(15)
      cell.photoView.image = photo
      
      // 사진은 유아 추가시에만 제공하고, 유아 편집시에는 제공하지 않는다.
      if viewType == .update {
        cell.chooser.isHidden = true
      } else {
        cell.chooser.isHidden = false
        cell.chooser.addTarget(self, action: #selector(imageChooser(_:)), for: .touchUpInside)
      }
      
    case .name:
      cell.textField.text = itemInputs[.name]
      
    case .birthday:
      cell.textField.text = itemInputs[.birthday]
      
    case .height:
      cell.textField.text = itemInputs[.height]
      
    case .weight:
      cell.textField.text = itemInputs[.weight]
      
    case .momPhone:
      cell.textField.text = itemInputs[.momPhone]
      
    case .dadPhone:
      cell.textField.text = itemInputs[.dadPhone]
      
    case .comment:
      cell.textField.text = itemInputs[.comment]
    }
    cell.selectionStyle = .none
    return cell
  }
}

//
// MARK: UITableViewDelegate

extension AddViewController: UITableViewDelegate {
  func tableView(
    _ tableView: UITableView,
    heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch items[indexPath.row] {
    case .photo:  return CGFloat(216)
    default:      return CGFloat(96)
    }
  }
  
  func tableView(
    _ tableView: UITableView,
    estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    switch items[indexPath.row] {
    case .photo:  return CGFloat(216)
    default:      return CGFloat(96)
    }
  }
  
  func tableView(
    _ tableView: UITableView,
    didSelectRowAt indexPath: IndexPath) {
    tableView.endEditing(true)
  }
}

//
// MARK: UINavigationControllerDelegate

extension AddViewController: UINavigationControllerDelegate {
}

//
// MARK: UIImagePickerControllerDelegate

extension AddViewController: UIImagePickerControllerDelegate {
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    // Disniss the picker if the user canceled.
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    //The info dictionary may contain multiple representations of the image. You want to use the original.
    guard let selectedImage = info[.originalImage] as?
      UIImage else {
        fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
    }
    
    //set PhotoImageView to display the selected image.
    self.photo = selectedImage
    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    
    //Dismiss the picker.
    dismiss(animated: true, completion: nil)
  }
}
