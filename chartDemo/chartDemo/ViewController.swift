//
//  ViewController.swift
//  chartDemo
//
//  Created by Nexios02 on 26/07/23.
//

import UIKit
import Charts

class ViewController: UIViewController {
    @IBOutlet weak var singleBarChartView: BarChartView!
    @IBOutlet weak var doubleBarChartView: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.createSingleBarChart()
        self.setupGroupedBarChart()
    }
    
    func createSingleBarChart() {
        // Data entries for the single bar chart
        let dataEntries: [BarChartDataEntry] = [
            BarChartDataEntry(x: 1, y: 80), // First bar, value 10
            BarChartDataEntry(x: 2, y: 50), // Second bar, value 20
            BarChartDataEntry(x: 3, y: 80), // Third bar, value 30
            BarChartDataEntry(x: 4, y: 50), // Third bar, value 30
            BarChartDataEntry(x: 5, y: 80), // Third bar, value 30
            BarChartDataEntry(x: 6, y: 50), // Third bar, value 30
            BarChartDataEntry(x: 7, y: 60), // Third bar, value 30
        ]
        
        // Dataset with label "Data Set 1" for single bar chart
        let dataSet = BarChartDataSet(entries: dataEntries, label: "")
        dataSet.colors = [UIColor.black] // Customize bar colors
        dataSet.drawValuesEnabled = false
        
        // Create a data object with the dataset
        let data = BarChartData(dataSet: dataSet)
        data.barWidth = 0.14//0.1
        singleBarChartView.data = data
        singleBarChartView.rightAxis.enabled = false
        singleBarChartView.legend.drawInside = false
        singleBarChartView.legend.enabled = false
        singleBarChartView.drawValueAboveBarEnabled = false
        singleBarChartView.leftAxis.drawGridLinesEnabled = false
        singleBarChartView.xAxis.drawGridLinesEnabled = false
        
        let xaxis = singleBarChartView.xAxis
        xaxis.labelPosition = .bottom
        xaxis.labelTextColor = .clear
    }
    
    func setupGroupedBarChart() {
        let months = ["1", "2", "3", "4", "5", "6", "7"]
        let unitsSold = [80.0, 50.0, 80.0, 50.0, 80.0, 50.0, 60.0]
        let unitsBought = [50.0, 80.0, 50.0, 80.0, 50.0, 80.0, 40.0]

        //legend
        let legend = doubleBarChartView.legend
        legend.enabled = false
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .vertical
        legend.yOffset = 10.0;
        legend.xOffset = 10.0;
        legend.yEntrySpace = 0.0;
        
        let yaxis = doubleBarChartView.leftAxis
        yaxis.spaceTop = 0.35
        yaxis.axisMinimum = 0
        yaxis.drawGridLinesEnabled = false
        
        doubleBarChartView.rightAxis.enabled = false
                
        doubleBarChartView.delegate = self
        doubleBarChartView.noDataText = "You need to provide data for the chart."
        doubleBarChartView.chartDescription.textColor = UIColor.clear
                
        let xaxis = doubleBarChartView.xAxis
        xaxis.forceLabelsEnabled = false
        xaxis.drawGridLinesEnabled = false
        xaxis.labelPosition = .bottom
        xaxis.labelTextColor = .clear
        xaxis.centerAxisLabelsEnabled = false
        xaxis.valueFormatter = IndexAxisValueFormatter(values:months)
        xaxis.granularityEnabled = false
        xaxis.granularity = 1

        var dataEntries: [BarChartDataEntry] = []
        var dataEntries1: [BarChartDataEntry] = []
        
        for i in 0..<months.count {
            
            let dataEntry = BarChartDataEntry(x: Double(i) , y: Double(unitsSold[i]))
            dataEntries.append(dataEntry)
            
            let dataEntry1 = BarChartDataEntry(x: Double(i) , y: Double(unitsBought[i]))
            dataEntries1.append(dataEntry1)
            
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "unitsSold")
        let chartDataSet1 = BarChartDataSet(entries: dataEntries1, label: "unitsBought")
        chartDataSet.drawValuesEnabled = false
        chartDataSet1.drawValuesEnabled = false
        
        let dataSets: [BarChartDataSet] = [chartDataSet,chartDataSet1]
        chartDataSet.colors = [UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)]
        chartDataSet1.colors = [UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.2)]
        let chartData = BarChartData(dataSets: dataSets)
        
        let groupSpace = 2.5
        let barSpace = 0.05
        let barWidth = 0.3
        
        let groupCount = months.count
        let startYear = 0
        
        chartData.barWidth = barWidth
        doubleBarChartView.xAxis.axisMinimum = Double(startYear)
        let gg = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
        doubleBarChartView.xAxis.axisMaximum = Double(startYear) + gg * Double(groupCount)
        chartData.groupBars(fromX: Double(startYear), groupSpace: groupSpace, barSpace: barSpace)
        
        doubleBarChartView.data = chartData
        doubleBarChartView.setVisibleXRangeMaximum(15)
        doubleBarChartView.animate(yAxisDuration: 1.0, easingOption: .easeInOutBounce)
        
    }
    
}

extension ViewController: ChartViewDelegate {
    
}
