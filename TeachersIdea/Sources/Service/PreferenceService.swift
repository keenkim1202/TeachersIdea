//
//  PreferenceService.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/23.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import Foundation

private let MemberEmailKey = "MemberEmailKey"
private let IsSaveEmailKey = "IsSaveEmailKey"
private let MemberPasswordKey = "MemberPasswordKey"
private let IsAutoLoginKey = "IsAutoLoginKey"

final class PreferenceService {
  private let userDefaults: UserDefaults
  
  init() {
    userDefaults = UserDefaults.standard
  }
  
  var email: String? {
    get {
      return userDefaults
        .string(forKey: MemberEmailKey)
    }
    set {
      userDefaults.set(newValue, forKey: MemberEmailKey)
    }
  }
  
  var isSaveEmail: Bool {
    get {
      return userDefaults
        .bool(forKey: IsSaveEmailKey)
    }
    set {
      userDefaults.set(newValue, forKey: IsSaveEmailKey)
    }
  }
  
  var password: String? {
    get {
      return userDefaults.string(forKey: MemberPasswordKey)
    }
    set {
      userDefaults.set(newValue, forKey: MemberPasswordKey)
    }
  }
  
  var isAutoLogin: Bool {
    get {
      return userDefaults.bool(forKey: IsAutoLoginKey)
    }
    set {
      userDefaults.set(newValue, forKey: IsAutoLoginKey)
    }
  }
}

