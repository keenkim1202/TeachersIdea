//
//  TeacherService.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/23.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import Foundation
import Firebase
import Kingfisher

protocol TeacherServiceType {
  typealias Handler = (_ result: Result<Teacher, AppError>) -> Void
  
  var currentTeacher: Teacher? { get set }
  func add(_ data: Teacher, completion: Handler?)
  func fetch(from email: String, completion: Handler?)
}

final class TeacherService: TeacherServiceType {
  private let collectionName = "Teacher"
  private let db: Firestore
  private let firebaseStorageService: FirebaseStorageServiceType
  
  init(_ firebaseStorageService: FirebaseStorageServiceType) {
    self.firebaseStorageService = firebaseStorageService
    
    db = Firestore.firestore()
    currentTeacher = nil
  }
  
  var currentTeacher: Teacher?
  
  func add(_ data: Teacher, completion: Handler?) {
    guard let thumbnailData = data.thumbnail?.pngData() else {
      completion?(.failure(.addTeacherFail))
      return
    }
    
    let path = "images/\(data.id)"
    firebaseStorageService.upload(path: path, data: thumbnailData) { result in
      switch result {
      case .success(let url):
        self.db
          .collection(self.collectionName)
          .addDocument(data: [
            "id": data.id,
            "name": data.name,
            "birthday": data.birthday,
            "phoneNumber": data.phoneNumber,
            "group": data.group.rawValue,
            "thumbnailUrl": url.absoluteString
            ], completion: { err in
              guard err == nil else {
                completion?(.failure(.addTeacherFail))
                return
              }
              completion?(.success(data))
          })
      case .failure(let error):
        completion?(.failure(error))
      }
    }
  }
  
  func fetch(from email: String, completion: Handler?) {
    let query = db.collection(collectionName).whereField("id", isEqualTo: email)
    query.getDocuments { (snapshot, err) in
      guard err == nil else { completion?(.failure(.fetchTeacherFail)); return }
      guard let data = snapshot?.documents.first?.data() else {
        completion?(.failure(.fetchTeacherFail));
        return
      }
      let url = URL(string: data["thumbnailUrl"] as! String)!
      
      self.firebaseStorageService.downloadImage(with: url) { result in
        switch result {
        case .success(let image):
          let teacher = Teacher(
            id: data["id"] as! String,
            name: data["name"] as! String,
            birthday: data["birthday"] as! String,
            phoneNumber: data["phoneNumber"] as! String,
            group: Group(rawValue: data["group"] as! String)!,
            thumbnail: image)
          self.currentTeacher = teacher
          completion?(.success(teacher));
          
        case .failure(let error):
          completion?(.failure(error));
        }
      }
    }
  }
}
