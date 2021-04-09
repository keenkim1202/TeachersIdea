//
//  ChildrenService.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/23.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import Foundation
import Firebase

protocol ChildrenServiceType {
  typealias VoidHandler = (Result<Void, AppError>) -> Void
  typealias FetchHandler = (Result<[ChildType], AppError>) -> Void
  
  func add(_ child: ChildType, completion: VoidHandler?)
  func fetch(group: Group, completion: FetchHandler?)
  func update(_ child: ChildType, completion: VoidHandler?)
}

final class ChildrenService: ChildrenServiceType {
  private let collectionName = "Children"
  private let db: Firestore
  private let firebaseStorageServiceType: FirebaseStorageServiceType
  
  init(_ firebaseStorageServiceType: FirebaseStorageServiceType) {
    self.firebaseStorageServiceType = firebaseStorageServiceType
    
    db = Firestore.firestore()
  }
  
  func add(_ child: ChildType, completion: VoidHandler?) {
    guard let pngData = child.photo?.pngData() else { return }
    firebaseStorageServiceType.upload(
      path: "images/\(child.id.uuidString)",
    data: pngData) { result in
      switch result {
      case .success(let url):
        let data: [String:Any] = [
          "uuid": child.id.uuidString,
          "group": child.group.rawValue,
          "name": child.name,
          "height": child.height,
          "weight": child.weight,
          "birthday": Timestamp(date: child.birthday.date ?? Date()),
          "momPhone": child.momPhone ?? "",
          "dadPhone": child.dadPhone ?? "",
          "comment": child.comment ?? "",
          "thumbnailUrl": url.absoluteString
        ]
        
        let doc = self.db.collection(self.collectionName).document(child.id.uuidString)
        doc.setData(data) { err in
          guard err == nil else { completion?(.failure(.addChildFail)); return }
          completion?(.success(Void()))
        }
        
      case .failure(let error):
        completion?(.failure(error))
      }
    }
  }
  
  func fetch(group: Group, completion: FetchHandler?) {
    let query = db.collection(collectionName).whereField("group", isEqualTo: group.rawValue)
    query.getDocuments { (snapshot, err) in
      guard err == nil, let documents = snapshot?.documents
        else { completion?(.failure(.fetchChildrenFail)); return }
      
      let children = documents.map { doc -> ChildType in
        let data = doc.data()
        let child = MemChild(
          group: Group(rawValue: data["group"] as! String)!,
          birthday: (data["birthday"] as? Timestamp)?.dateValue().birthday,
          comment: data["comment"] as? String,
          height: data["height"] as? Float,
          id: UUID(uuidString: data["uuid"] as! String),
          name: data["name"] as? String,
          photo: nil,
          photoUrl: URL(string: data["thumbnailUrl"] as! String),
          weight: data["weight"] as? Float,
          momPhone: data["momPhone"] as? String,
          dadPhone: data["dadPhone"] as? String)
        return child
      }
      
      completion?(.success(children))
    }
  }
  
  func update(_ child: ChildType, completion: VoidHandler?) {
    let data: [String:Any] = [
      "uuid": child.id.uuidString,
      "group": child.group.rawValue,
      "name": child.name,
      "height": child.height,
      "weight": child.weight,
      "birthday": Timestamp(date: child.birthday.date ?? Date()),
      "momPhone": child.momPhone ?? "",
      "dadPhone": child.dadPhone ?? "",
      "comment": child.comment ?? "",
    ]
    let doc = db.collection(collectionName).document(child.id.uuidString)
    doc.updateData(data) { error in
      guard error == nil else { completion?(.failure(.addChildFail)); return }
      completion?(.success(Void()))
    }
  }
}
