//
//  AppDelegate.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/17.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import UIKit
import CoreData
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions
    launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // Use Firebase library to configure APIs
    FirebaseApp.configure()
    
    return true
  }
  
  func navigate(with vc: UIViewController?) {
    guard
      let app = UIApplication.shared.delegate as? AppDelegate,
      let window = app.window
      else {
        fatalError("Not found UIWindow")
    }
    window.rootViewController = vc
    window.makeKeyAndVisible()
  }
}

