//
//  SlashViewController.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/23.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import UIKit
import FirebaseAuth
import Lottie

final class SlashViewController: UIViewController {
  // MARK: Properties
  fileprivate var environment: Environment!
  fileprivate var appDelegate: AppDelegate!
  
  // MARK: UIControl
  @IBOutlet weak var containerView: UIView!
  private let animationView = AnimationView(name: "coffee-time")

  // MARK: View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    appDelegate = UIApplication.shared.delegate as? AppDelegate
    environment = generateEnvironment()
    
    dummyChild(env: environment)
    dummyChecklist(env: environment)
    loadAnimation()
  }
  
  fileprivate func loadAnimation() {
    animationView.frame = containerView.bounds
    animationView.loopMode = .playOnce
    containerView.addSubview(animationView)
    
    // 애니메이션을 1회 재생 후에 로그인을 시도한다.
    animationView.play { isEnd in
      self.animationView.loopMode = .loop
      self.animationView.play()
      
      guard isEnd else { return }
      self.tryAutoLogin()
    }
  }
  
  fileprivate func tryAutoLogin() {
    // 자동 로그인이 아니면, 로그인 화면으로
    guard environment.perferenceService.isAutoLogin else {
      self.navigateLoginNC()
      return
    }
    
    // 자동 로그인 시도
    if
      let email = environment.perferenceService.email,
      let password = environment.perferenceService.password {
      
      // 기존 사용자가 로그인양식을 작성하면 signIn 메서드를 호출.
      Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
        // 로그인에 실패하면 로그인 화면으로
        guard error == nil else {
          self.navigateLoginNC()
          return
        }
        
        self.environment?.teacherService.fetch(from: email, completion: { result in
          switch result {
          case .success:
            self.naviagteMainNC()
          case .failure:
            self.navigateLoginNC()
          }
        })
      }
    }
  }
  
  fileprivate func naviagteMainNC() {
    guard let mainNC = self.instantiateMainNC() else { return }
    animationView.stop()
    appDelegate.navigate(with: mainNC)
  }
  
  fileprivate func navigateLoginNC() {
    guard let loginNC = self.instantiateLoginNC() else { return }
    animationView.stop()
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
  
  fileprivate func instantiateMainNC() -> UIViewController? {
    guard
      let nc = storyboard?
        .instantiateViewController(withIdentifier: "MainNC")
        as? UINavigationController,
      let vc = nc.viewControllers.first as? ChildTableViewController else {
        return nil
    }
    vc.environment = environment
    return nc
  }
  
  fileprivate func generateEnvironment() -> Environment? {
    let firebaseStorageService = FirebaseStorageService()
    let environment = Environment(
      teacherService: TeacherService(firebaseStorageService),
      childrenService: ChildrenService(firebaseStorageService),
      childRepository: MemoryChildRepository(),
      checklistRepository: MemoryChecklistRepository(),
      perferenceService: PreferenceService())
    return environment
  }
  
  fileprivate func dummyChild(env: Environment) {
    guard
      let path = Bundle.main.path(forResource: "dummy_child", ofType: "json"),
      let data = FileManager.default.contents(atPath: path),
      let childList = try? JSONDecoder().decode(MemChildList.self, from: data) else {
        fatalError()
    }
    for child in childList {
      env.childRepository.add(child: child)
    }
  }
  
  fileprivate func dummyChecklist(env: Environment) {
    guard
      let path = Bundle.main.path(forResource: "dummy_checklist", ofType: "json"),
      let data = FileManager.default.contents(atPath: path),
      let reportList = try? JSONDecoder().decode([ChildReport].self, from: data) else {
        fatalError()
    }
    
    for report in reportList {
      env.checklistRepository.add(report)
    }
  }
}
