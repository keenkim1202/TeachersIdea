//
//  LoginViewController.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/17.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAuth
import Firebase

final class LoginViewController: UIViewController {
  
  // MARK: UI
  
  @IBOutlet weak var loginButton: UIButton?
  @IBOutlet weak var joinButton: UIButton?
  @IBOutlet weak var idTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var saveEmailButton: UIButton!
  @IBOutlet weak var saveAutoLoginButton: UIButton!
  
  //
  // MARK: Properties
  
  fileprivate var teacher: Teacher?
  var environment: Environment?
  
  // TODO: Temporary code...
  fileprivate var tiChildren: [NSManagedObject] = []
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else { return }
    switch identifier {
    case "JoinVCSegue":
      if let vc = segue.destination as? MemberJoinViewController {
        vc.environment = self.environment
      }
      
    default:
      break
    }
  }
  
  //
  // MARK: View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configure()
    loadUserDefaults()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.navigationBar.isHidden = true
  }
  
  //
  // MARK: Configuring
  
  fileprivate func configure() {
    loginButton?.layer.cornerRadius = CGFloat(5)
    loginButton?.layer.borderColor = UIColor.black.cgColor
    loginButton?.layer.borderWidth = CGFloat(1)
    
    joinButton?.layer.cornerRadius = CGFloat(5)
    joinButton?.layer.borderColor = UIColor.black.cgColor
    joinButton?.layer.borderWidth = CGFloat(1)
    
    passwordTextField.isSecureTextEntry = true // 비밀번호안보이게.
    saveEmailButton.isSelected = false // 이메일 저장버튼 관련
    
    saveAutoLoginButton.isSelected = false
  }
  
  fileprivate func loadUserDefaults(){
    guard let env = self.environment else { return }
    
    if env.perferenceService.isSaveEmail { // 저장되어있으면
      idTextField.text = env.perferenceService.email
    }
    saveEmailButton.isSelected = env.perferenceService.isSaveEmail
    
    if env.perferenceService.isAutoLogin {
      passwordTextField.text = env.perferenceService.password
    }
    saveAutoLoginButton.isSelected = env.perferenceService.isAutoLogin
  }
  
  //
  // MARK: Configuring Alert
  
  fileprivate func showAlert(_ message: String) {
    let alert = UIAlertController(
      title: "⚠️ 오류 �",
      message: message,
      preferredStyle: .alert)
    let okAction = UIAlertAction(
      title: "확인", style: .default, handler: nil)
    alert.addAction(okAction)
    self.present(alert, animated: true, completion: nil)
  }
  
  //
  // MARK: UI Actions
  
  @IBAction func onLogin(_ sender: Any) {
    signIn()
  }
  
  @IBAction func onSaveEmail(_ sender: Any) { // 이메일 주소를 저장해두는 버튼
    saveEmailButton.isSelected.toggle()
    saveEmail()
  }
  
  @IBAction func onSaveAutoLogin(_ sender: Any) {
    saveAutoLoginButton.isSelected.toggle()
    savePassword()
  }
  
  fileprivate func saveEmail() {
    guard let env = environment else { return }
    if saveEmailButton.isSelected {
      env.perferenceService.email = idTextField.text
    }
    env.perferenceService.isSaveEmail = saveEmailButton.isSelected
  }
  
  fileprivate func savePassword() {
    guard let env = environment else { return }
    if saveAutoLoginButton.isSelected {
      saveEmailButton.isSelected = true
      saveEmail()
      env.perferenceService.password = passwordTextField.text
    }
    env.perferenceService.isAutoLogin = saveAutoLoginButton.isSelected
  }
  
  fileprivate func signIn() {
    guard
      let email = idTextField.text,
      let password = passwordTextField.text,
      email.isEmpty == false,
      password.isEmpty == false else { // 비어있는 경우 로그인이 안되도록 else구문
        self.showAlert("올바른 아이디,비밀번호를 입력해주세요.")
        return
    }
    
    saveEmail()
    savePassword()
    // 기존 사용자가 로그인양식을 작성하면 signIn 메서드를 호출.
    Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
      guard error == nil else {
        self.showAlert(error?.localizedDescription ?? "")
        return
      }
      
      self.environment?.teacherService.fetch(from: email, completion: { result in
        switch result {
        case .success:
          guard
            let mainNC = self.storyboard?
              .instantiateViewController(withIdentifier: "MainNC") as? UINavigationController,
            let vc = mainNC.viewControllers.first as? ChildTableViewController,
            let app = UIApplication.shared.delegate as? AppDelegate
            else {
              fatalError("Not found AppDelegate")
          }
          vc.environment = self.environment
          app.navigate(with: mainNC)
          
        case .failure:
          break
        }
      })
    }
  }
}
