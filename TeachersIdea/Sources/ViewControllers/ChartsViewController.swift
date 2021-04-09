//
//  ChartsViewController.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/23.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import UIKit
import Charts

final class ChartsViewController: UIViewController {
  // MARK: UI
  @IBOutlet weak var radarChartView: RadarChartView!
  
  // MARK: Properties
  var report: ChildReportType? = nil
  fileprivate var activities: [String] = []
  
  // MARK: View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configure()
  }
  
  // MARK: Configuring
  fileprivate func configure() {
    radarChartView.noDataFont = UIFont.systemFont(ofSize: CGFloat(15), weight: .bold)
    radarChartView.noDataText = "평가된 발달목록이 없습니다."
    radarChartView.noDataTextColor = .primaryText
    
    guard let report = self.report else { return }
    
    activities = report.checklist.map { $0.title }
    
    var values: [Int] = []
    for section in report.checklist {
      let total = section.subtitles.reduce(0) { (rst, next) -> Int in
        return rst + next.body.reduce(0) { $0 + $1.score.toInt() }
      }
      values.append(total)
    }
    configureCharts(values)
  }
  
  fileprivate func configureCharts(_ values: [Int]) {
    radarChartView.xAxis.valueFormatter = self
    
    let entires = values.map { RadarChartDataEntry(value: Double($0)) }
    let dataSet = RadarChartDataSet(entries: entires)
    dataSet.colors = [UIColor.primaryText]
    dataSet.fillColor = UIColor.primaryText
    dataSet.drawFilledEnabled = true
    dataSet.drawIconsEnabled = true
    dataSet.drawValuesEnabled = false
    dataSet.label = "발달목록"
    
    let data = RadarChartData(dataSet: dataSet)
    radarChartView.data = data
    radarChartView.innerWebColor = .primaryText
    radarChartView.innerWebLineWidth = CGFloat(1.5)
    radarChartView.webColor = .primaryText
    radarChartView.webLineWidth = CGFloat(1.5)
    
    let xAxis = radarChartView.xAxis
    xAxis.labelFont = UIFont.systemFont(ofSize: CGFloat(13), weight: .bold)
    xAxis.labelTextColor = .primaryText
    
    let yAxis = radarChartView.yAxis
    yAxis.labelFont = UIFont.systemFont(ofSize: CGFloat(11), weight: .bold)
    yAxis.labelTextColor = .primaryText
    yAxis.axisMinimum = .zero
  }
}

extension ChartsViewController: AxisValueFormatter {
  func stringForValue(_ value: Double, axis: AxisBase?) -> String {
    return activities[Int(value) % activities.count]
  }
}
