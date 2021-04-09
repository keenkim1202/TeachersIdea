//
//  AppError.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/23.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import Foundation

enum AppError: Error {
  case addTeacherFail  // 회원가입 실패
  case addChildFail // 유아 추가 실패
  case fetchTeacherFail // 선생님 가져오기 실패
  case fetchChildrenFail // 유아 가져오기 실패
  case uploadFail // 이미지 업로드 실패
  case downloadUrlFail // 이미지 다운로드 경로 반환 실패
  case downloadImageFail // 이미지 다운로드 실패
  case updateChildFail // 유아 업데이트 실패
}
