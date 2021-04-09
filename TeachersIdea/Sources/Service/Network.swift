//
//  Network.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/07/04.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import Foundation

class Network {
  var host: String
  var apikey: String
  let session = URLSession.shared
  
  init() {
    host = "https://dapi.kakao.com"
    apikey = "KakaoAK ffc99e4c3f57d361f451ac394f9d6a6e"
  }
  
  func searchImage(query: String) { // 이미지 검색 기능을 따로 빼기
    let path = "/v2/search/image?\(query)"
    guard
      let urlString = "\(host)\(path)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
      let url = URL(string: urlString)
      else { return }
    
    var request = URLRequest(url: url)
    request.addValue(apikey, forHTTPHeaderField: "Authorization")
    
    let task = session.dataTask(with: request) { data, res, err in
      print(data)
    }
    task.resume()
  }
}
