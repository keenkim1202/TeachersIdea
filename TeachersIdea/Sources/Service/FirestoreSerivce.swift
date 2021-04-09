//
//  FirestoreSerivce.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/23.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import Foundation
import Firebase

protocol FirestoreServiceType {
  func add(_ data: [String:Any])
  func fetch(completion: @escaping (_ children: [ChildType]) -> Void)
}

final class ChildFirestoreService: FirestoreServiceType {
  
  private let collectionName = "Children"
  private let db: Firestore
  
  init() {
    self.db = Firestore.firestore()
  }
  
  func add(_ data: [String:Any]) {
    db.collection(collectionName).addDocument(
      data: data,
      completion: { err in
        print(err)
    })
  }
  
  func fetch(completion: @escaping (_ children: [ChildType]) -> Void) {
    db.collection(collectionName).getDocuments { (snapshot, err) in
      guard err == nil, let snapshot = snapshot else { return }
      let children = snapshot.documents
        .map { $0.data() }
        .map { json -> ChildType? in
          guard
            let name = json["name"] as? String,
            let birthday = json["birthday"] as? String,
            let photoUrl = json["photoUrl"] as? String,
            let height = json["height"] as? String,
            let weight = json["weight"] as? String else {
              return nil
          }
          return MemChild(
            group: .moon,
            birthday: birthday,
            height: Float(height),
            name: name,
            weight: Float(weight))
      }
      .compactMap { $0 }
      completion(children)
    }
  }
}

