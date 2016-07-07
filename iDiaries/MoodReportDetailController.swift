//
//  MoodReportDetailController.swift
//  iDiaries
//
//  Created by AlexChow on 16/1/15.
//  Copyright © 2016年 GStudio. All rights reserved.
//

import UIKit
import Charts

struct MonthMoodStat {
    var writeDiaryPersent:NSNumber = 0
    var avgMoodPointEmoji = ""
    var avgMoodPoint:NSNumber = 0
    
    var bestMood:NSNumber = 0
    var bestDay:Int = 1
    var bestMoodEmoji = ""
    
    var lowestMood:NSNumber = 0
    var lowestDay:Int = 1
    var lowestMoodEmoji = ""
    
}

class MoodReportDetailController: UITableViewController
{
    private var charts = [ChartViewBase]()
    private var lineChart:LineChartView{
        return charts[0] as! LineChartView
    }
    
    private var pieChart:PieChartView{
        return charts[1] as! PieChartView
    }
    
    private var barChart:BarChartView{
        return charts[2] as! BarChartView
    }
    
    var report:Report!
    private var lineChartViewData:[Float]!
    private var monthMoodStat = MonthMoodStat()
    private var viewIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        charts.append(LineChartView())
        charts.append(PieChartView())
        charts.append(BarChartView())
        
        self.tableView.allowsSelection = false
        self.tableView.separatorStyle = .None
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let date = DateHelper.generateDate(report.year,month: report.month)
        self.navigationItem.title = MoodReportCell.titleFormatter.stringFromDate(date)
        self.tableView.reloadData()
        let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(MoodReportDetailController.nextPage(_:)))
        leftGesture.direction = .Up
        let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(MoodReportDetailController.previousPage(_:)))
        rightGesture.direction = .Down
        self.tableView.addGestureRecognizer(leftGesture)
        self.tableView.addGestureRecognizer(rightGesture)
    }
    
    private var hasPrivious:Bool{
        return viewIndex > 0
    }
    
    private var hasNext:Bool{
        return viewIndex < 4
    }
    
    //MARK: inits
    
    private func generateLineChartData() -> LineChartData
    {
        let days = DateHelper.daysOfMonth(report.year, month: report.month)
        var data = [Double]()
        let xs = (1...days).map { return Double($0) }
        let ys = xs.map { (d) -> Double in
            var moodPoint:Double = 0.0
            let moods = report.moods.filter{$0.day == Int(d)}
            moods.forEach({ (mood) -> () in
                moodPoint += Double(mood.mark.info as! Float)
            })
            
            if moodPoint > 0
            {
                let yPoint = moodPoint / Double(moods.count)
                data.append(yPoint)
                return yPoint
            }else{
                return data.last ?? 60
            }
        }
        self.lineChartViewData = data.map{Float($0)}
        let yse1 = ys.enumerate().map { idx, i in return ChartDataEntry(value: i, xIndex: idx) }
        
        let result = LineChartData(xVals: xs)
        
        let ds1 = LineChartDataSet(yVals: yse1, label: "MOOD_VALUE".localizedString())
        ds1.mode = .CubicBezier
        ds1.cubicIntensity = 0.2
        ds1.drawCirclesEnabled = false
        ds1.lineWidth = 1.8
        ds1.circleRadius = 4.0
        ds1.setCircleColor(UIColor.redColor())
        ds1.highlightColor = UIColor(colorLiteralRed:244/255.0 ,green:117/255.0 ,blue:117/255.0 ,alpha:1.0)
        ds1.setColor(UIColor.greenColor())
        ds1.fillColor = UIColor.greenColor()
        ds1.fillAlpha = 0.6
        ds1.drawHorizontalHighlightIndicatorEnabled = false;
        ds1.drawValuesEnabled = false
        ds1.drawFilledEnabled = true
        result.addDataSet(ds1)
        return result
        
    }
    
    private func refreshMoodTrendsChart()
    {
        
        let chart = self.lineChart
        chart.data = generateLineChartData()
        chart.gridBackgroundColor = NSUIColor.whiteColor()
        chart.descriptionText = "MOOD_TRENDS_TITLE".localizedString()
        chart.descriptionFont = chart.descriptionFont?.fontWithSize(13)
        chart.xAxis.drawGridLinesEnabled = false
        chart.leftAxis.setLabelCount(5, force: true)
        chart.leftAxis.valueFormatter = CustomValueEmojiFormatter()
        chart.leftAxis.drawGridLinesEnabled = false
        chart.leftAxis.axisMinValue = 0
        chart.leftAxis.axisMaxValue = 100
        chart.rightAxis.axisMinValue = 0
        chart.rightAxis.axisMaxValue = 100
        chart.rightAxis.setLabelCount(5, force: true)
        chart.animate(xAxisDuration: 0.8, yAxisDuration: 0.8)
    }
    
    private func initStatData()
    {
        let monthDays = DateHelper.daysOfMonth(report.year, month: report.month)
        monthMoodStat.writeDiaryPersent = Double(report.diariesCount) / Double(monthDays) * 100
        
        var avgMoodPoint:Float = 0
        lineChartViewData.forEach{avgMoodPoint += $0}
        
        monthMoodStat.avgMoodPoint = avgMoodPoint / Float(lineChartViewData.count)
        
        monthMoodStat.avgMoodPointEmoji = moodValueEmoji(CGFloat(monthMoodStat.avgMoodPoint))
        
        monthMoodStat.bestMood = lineChartViewData.maxElement() ?? 60
        monthMoodStat.bestDay = (lineChartViewData.indexOf(monthMoodStat.bestMood.floatValue) ?? 0) + 1
        monthMoodStat.bestMoodEmoji = moodValueEmoji(CGFloat(monthMoodStat.bestMood))
        
        monthMoodStat.lowestMood = lineChartViewData.minElement() ?? 60
        monthMoodStat.lowestDay = (lineChartViewData.indexOf(monthMoodStat.lowestMood.floatValue) ?? 0) + 1
        monthMoodStat.lowestMoodEmoji = moodValueEmoji(CGFloat(monthMoodStat.lowestMood))
        
    }
    
    private class CustomValueEmojiFormatter:NSNumberFormatter{
        override func stringFromNumber(number: NSNumber) -> String? {
            return moodValueEmoji(CGFloat(number.floatValue))
        }
    }
    
    class CustomPieNumberFormatter:NSNumberFormatter{
        private var count:NSNumber = 0
        init(count:NSNumber) {
            super.init()
            self.count = count
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func stringFromNumber(number: NSNumber) -> String? {
            let persent = String(format: "%.0f", number.doubleValue / count.doubleValue * 100)
            return "\(number.intValue)\n\(persent)%"
        }
    }
    
    private func generatePieChartData() -> PieChartData{
        let xVals = report.moodsMap.map { (id,value) -> String? in
            return getDiaryMark("\(id)")?.emoji ?? ""
        }
        var i = 0
        let yValus = report.moodsMap.map { (id,value) -> ChartDataEntry in
            let c =  ChartDataEntry(value: Double(value), xIndex: i)
            i+=1
            return c
        }
        let ds = PieChartDataSet(yVals: yValus, label: "")
        ds.colors = barChartColors.messArrayUp()
        ds.xValuePosition = .InsideSlice
        ds.yValuePosition = .OutsideSlice
        let data = PieChartData(xVals: xVals)
        data.addDataSet(ds)
        data.setValueFormatter(CustomPieNumberFormatter(count: report.moods.count))
        data.setValueTextColor(UIColor.blackColor())
        
        return data
    }
    
    private func refreshMoodStatisticsChart()
    {
        let chart = pieChart
        chart.descriptionText = "MOOD_PERSENT".localizedString()
        chart.descriptionFont = chart.descriptionFont?.fontWithSize(13)
        chart.data = generatePieChartData()
        chart.drawCenterTextEnabled = true
        chart.centerText = "\(report.diariesCount) 篇日记"
        chart.drawSliceTextEnabled = true
        chart.animate(xAxisDuration: 0.8, yAxisDuration: 0.8)
    }
    
    private func generateBarChartData() -> BarChartData{
        initStatData()
        var yVals = [ChartDataEntry]()
        yVals.append(BarChartDataEntry(value: monthMoodStat.bestMood.doubleValue, xIndex: 0,data: 0))
        yVals.append(BarChartDataEntry(value: monthMoodStat.lowestMood.doubleValue, xIndex: 1,data: 1))
        yVals.append(BarChartDataEntry(value: monthMoodStat.avgMoodPoint.doubleValue, xIndex: 2,data: 2))
        let ds = BarChartDataSet(yVals: yVals, label: "")
        
        ds.colors = [barChartColors[2],UIColor.lightGrayColor(),barChartColors[0]]
        let bestStr = String(format: "BEST_MOOD_VALUE_DAY_FORMAT".localizedString(), monthMoodStat.bestDay)
        let lowStr = String(format: "LOW_MOOD_VALUE_DAY_FORMAT".localizedString(), monthMoodStat.lowestDay)
        let avgStr = "AVG_MOOD_VALUE_FORMAT".localizedString()
        
        let result = BarChartData(xVals: [bestStr,lowStr,avgStr])
        result.addDataSet(ds)
        return result
    }
    
    private func refreshBoardChart()
    {
        let chart = barChart
        chart.data = generateBarChartData()
        chart.leftAxis.valueFormatter = CustomValueEmojiFormatter()
        chart.leftAxis.setLabelCount(5, force: true)
        chart.leftAxis.axisMaxValue = 110
        chart.leftAxis.axisMinValue = 0
        chart.leftAxis.drawGridLinesEnabled = false
        chart.xAxis.labelPosition = .Bottom
        chart.descriptionText = ""
        chart.animate(xAxisDuration: 0.8, yAxisDuration: 0.8)
    }
    
    @IBAction func nextPage(sender:AnyObject?) {
        if hasNext{
            viewIndex+=1
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Top)
        }
    }

    @IBAction func previousPage(sender:AnyObject?) {
        if hasPrivious {
            viewIndex-=1
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Bottom)
        }
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.report == nil ? 0 : 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.charts.count > 0 ? 1 : 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if viewIndex == 0{
            let cell = tableView.dequeueReusableCellWithIdentifier(MoodReportStartCell.reuseId, forIndexPath: indexPath) as! MoodReportStartCell
            let date = DateHelper.generateDate(report.year, month: report.month, day: 0, hour: 0, minute: 0, second: 0)
            cell.titleLabel.text = String(format: "MOOD_REPORT_TITLE_FORMAT".localizedString(),MoodReportCell.titleFormatter.stringFromDate(date))
            cell.nextButton.startFlash()
            return cell
        }else if viewIndex >= 1 && viewIndex <= 3{
            let cell = tableView.dequeueReusableCellWithIdentifier(MoodReportDetailCell.reuseId, forIndexPath: indexPath) as! MoodReportDetailCell
            let frame = CGRectMake(0, 0, cell.frame.size.width - 20, cell.frame.size.width - 20)
            let chart = charts[viewIndex - 1]
            chart.frame = frame
            chart.center = CGPointMake(cell.center.x, cell.center.y - 30)
            charts.forEach{$0.removeFromSuperview()}
            cell.chartContainer.addSubview(chart)
            cell.nextButton.hidden = !hasNext
            cell.nextButton.startFlash()
            return cell
        }else{
            initStatData()
            let cell = tableView.dequeueReusableCellWithIdentifier(MoodReportSummaryCell.reuseId, forIndexPath: indexPath) as! MoodReportSummaryCell
            cell.rootController = self
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if viewIndex == 1 {
            refreshMoodTrendsChart()
        }else if viewIndex == 2{
            refreshMoodStatisticsChart()
        }else if viewIndex == 3{
            refreshBoardChart()
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.height
    }
    
    static func showReport(rootController:UIViewController, report:Report)
    {
        let controller = instanceFromStoryBoard("MoodReport", identifier: "MoodReportDetailController") as! MoodReportDetailController
        controller.report = report
        rootController.presentViewController(controller, animated: true){
            
        }
        //rootController.navigationController!.pushViewController(controller, animated: true)
    }

}
