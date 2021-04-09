//
//  AnalysisViewController.swift
//  TeachersIdea
//
//  Created by 김혜진's MAC on 2020/04/23.
//  Copyright © 2020 homurahomu. All rights reserved.
//

import UIKit
import Charts

final class AnalysisViewController: UIViewController {
  
  //
  // MARK: Properties
  
  var environment: Environment? = nil
  
  //
  // MARK: UI Control
  
  @IBOutlet weak var chartView: LineChartView!
  
  //
  // MARK: View Life-Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configure()
    loadData()
  }
  
  fileprivate func loadData() {
    guard let env = environment, let teacher = env.teacherService.currentTeacher else { return }
    var sections: [Int:[Int]] = [:]
    let children = env.childRepository.fetch(group: teacher.group)
    for child in children {
      if let reports = env.checklistRepository.report(childID: child.id) {
        for report in reports {
          let t = Int(report.date.timeIntervalSince1970)
          var value = sections[t] ?? Array(repeating: 0, count: 5)
          for (index, elem) in report.checklist.enumerated() {
            value[index] += sectionScore(section: elem)
          }
          sections[t] = value
        }
      }
    }
    
    var data: [Int:[(Int, Int)]] = [:]
    for key in sections.keys.sorted() {
      let value = sections[key] ?? []
      for (index, elem) in value.enumerated() {
        var v = data[index] ?? []
        let score = elem / 60
        v.append((key, score))
        data[index] = v
      }
    }
    
    var dataSets: [LineChartDataSet] = []
    for (i, v) in data.values.enumerated() {
      let color: UIColor
      let label: String
      switch i {
      case 0:     color = .healthColor; label = "신체운동건강"
      case 1:     color = .communicationColor; label = "의사소통"
      case 2:     color = .socialColor; label = "사회관계"
      case 3:     color = .artistColor; label = "예술경험"
      case 4:     color = .scienceColor; label = "자연탐구"
      default:    color = .black; label = ""
      }
      
      let entries = v.map { ChartDataEntry(x: Double($0.0), y: Double($0.1)) }
      let set = LineChartDataSet(entries: entries, label: label)
      set.axisDependency = .left
      set.setColor(color)
      set.lineWidth = 1.5
      set.drawCirclesEnabled = false
      set.drawValuesEnabled = false
      set.drawCircleHoleEnabled = false
      dataSets.append(set)
    }
    
    chartView.data = LineChartData(dataSets: dataSets)
  }
  
  fileprivate func sectionScore(section: ChildChecklistSection) -> Int {
    let max = section.subtitles.count * 10
    let total = section.subtitles
      .flatMap { $0.body }
      .flatMap { $0.score.toInt() }
      .reduce(0, +)
    return total / max * 100
  }
  
  fileprivate func configure() {
    self.title = "반 통계(전체 유아 날짜별 성취도)"
    
    chartView.backgroundColor = .primary
    chartView.chartDescription?.enabled = false
    chartView.dragEnabled = true
    chartView.setScaleEnabled(true)
    chartView.pinchZoomEnabled = true
    chartView.rightAxis.enabled = false
    
    let legend = chartView.legend
    legend.form = .line
    legend.font = .systemFont(ofSize: 9, weight: .bold)
    legend.textColor = .black
    legend.orientation = .horizontal
    legend.verticalAlignment = .top
    legend.horizontalAlignment = .right
    
    let xAxis = chartView.xAxis
    xAxis.labelFont = .systemFont(ofSize: 9, weight: .bold)
    xAxis.labelTextColor = .black
    xAxis.labelPosition = .bottom
    xAxis.drawAxisLineEnabled = false
    xAxis.valueFormatter = DateValueFormatter()
    
    let leftAxis = chartView.leftAxis
    leftAxis.labelFont = .systemFont(ofSize: 9, weight: .bold)
    leftAxis.drawGridLinesEnabled = true
    leftAxis.granularityEnabled = true
    leftAxis.axisMinimum = Double.zero
    leftAxis.axisMaximum = Double(100)
    leftAxis.labelTextColor = UIColor.black
  }
}
