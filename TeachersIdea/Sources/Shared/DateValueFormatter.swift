//
//  DateValueFormatter.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/23.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import Foundation
import Charts

public class DateValueFormatter: NSObject, AxisValueFormatter {
  private let dateFormatter = DateFormatter()
  
  override init() {
    super.init()
    dateFormatter.dateFormat = "MM/dd"
  }
  
  public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
    return dateFormatter.string(from: Date(timeIntervalSince1970: value))
  }
}
