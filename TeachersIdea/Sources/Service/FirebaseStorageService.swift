//
//  FirebaseStorageService.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/23.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import Kingfisher

protocol FirebaseStorageServiceType {
  typealias VoidHandler = (Result<Void, AppError>) -> Void
  typealias UrlHandler = (Result<URL, AppError>) -> Void
  typealias ImageHandler = (Result<UIImage, AppError>) -> Void
  
  func upload(path: String, data: Data, completion: UrlHandler?)
  func toUrl(path: String, completion: UrlHandler?)
  func downloadImage(with url: URL, completion: ImageHandler?)
}

final class FirebaseStorageService: FirebaseStorageServiceType {
  let ref = Storage.storage().reference()
  
  func upload(path: String, data: Data, completion: UrlHandler?) {
    let imageRef = ref.child(path)
    imageRef.putData(data, metadata: nil) { (meta, err) in
      guard err == nil else { completion?(.failure(.uploadFail)); return }
      
      self.toUrl(path: path) { result in
        switch result {
        case .success(let url):
          completion?(.success(url))
          break
          
        case .failure(let error):
          completion?(.failure(error))
        }
      }
    }
  }
  
  func toUrl(path: String, completion: UrlHandler?) {
    let imageRef = ref.child(path)
    imageRef.downloadURL { (url, err) in
      guard err == nil, let url = url
        else { completion?(.failure(.downloadUrlFail)); return }
      
      completion?(.success(url))
    }
  }
  
  func downloadImage(with url: URL, completion: ImageHandler?) {
    KingfisherManager.shared.retrieveImage(with: url) { (result) in
      switch result {
      case .success(let res):
        completion?(.success(res.image));
        
      case .failure:
        completion?(.failure(.downloadImageFail));
      }
    }
  }
}
