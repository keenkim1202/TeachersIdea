//
//  Child.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/23.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import UIKit

protocol ChildType {
  var birthday: String { get set }
  var comment: String? { get set }
  var group: Group { get set }
  var height: Float { get set }
  var id: UUID { get set }
  var name: String { get set }
  var photo: UIImage? { get set }
  var photoUrl: URL? { get set }
  var weight: Float { get set }
  var momPhone: String? { get set }
  var dadPhone: String? { get set }
}

extension ChildType {
  static func==(lhs: ChildType, rhs: ChildType) -> Bool {
    return lhs.id == rhs.id
  }
}

struct MemChild: ChildType, Decodable {
  var birthday: String
  var comment: String?
  var group: Group
  var height: Float
  var id: UUID
  var name: String
  var photo: UIImage?
  var photoUrl: URL?
  var weight: Float
  var momPhone: String?
  var dadPhone: String?
  
  enum CodingKeys: String, CodingKey {
    case birthday
    case comment
    case group
    case height
    case id
    case name
    case photo
    case photoUrl
    case weight
    case momPhone
    case dadPhone
  }
  
  init(
    group: Group,
    birthday: String? = nil,
    comment: String? = nil,
    height: Float? = nil,
    id: UUID? = nil,
    name: String? = nil,
    photo: UIImage? = nil,
    photoUrl: URL? = nil,
    weight: Float? = nil,
    momPhone: String? = nil,
    dadPhone: String? = nil) {
    self.birthday = birthday ?? ""
    self.comment = comment ?? ""
    self.group = group
    self.height = height ?? .zero
    self.id = id ?? UUID()
    self.name = name ?? ""
    self.photo = photo ?? UIImage(named: "account_box")
    self.photoUrl = photoUrl
    self.weight = weight ?? .zero
    self.momPhone = momPhone
    self.dadPhone = dadPhone
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let uuidString = try container.decode(String.self, forKey: .id)
    guard let uuid = UUID(uuidString: uuidString) else { fatalError() }
    id = uuid
    
    let urlString = try container.decode(String.self, forKey: .photoUrl)
    guard let url = URL(string: urlString) else { fatalError() }
    photoUrl = url
    photo = nil
    
    name =  try container.decode(String.self, forKey: .name)
    group = try container.decode(Group.self, forKey: .group)
    birthday = try container.decode(String.self, forKey: .birthday)
    comment = try container.decode(String.self, forKey: .comment)
    height = try container.decode(Float.self, forKey: .height)
    weight = try container.decode(Float.self, forKey: .weight)
    momPhone =  try container.decode(String.self, forKey: .momPhone)
    dadPhone =  try container.decode(String.self, forKey: .dadPhone)
  }
}

typealias MemChildList = [MemChild]
