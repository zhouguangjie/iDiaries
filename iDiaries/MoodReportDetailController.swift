//
//  MoodReportDetailController.swift
//  iDiaries
//
//  Created by AlexChow on 16/1/15.
//  Copyright © 2016年 GStudio. All rights reserved.
//

import UIKit
import TEAChart
import FSLineChart

class MoodReportDetailCell:UITableViewCell
{
    static let reuseId = "MoodReportDetailCell"
    @IBOutlet weak var chartContainer: UIView!
}

class MoodReportDetailController: UITableViewController
{
    var charts = [UIView]()
    var report:Report!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsSelection = false
        self.tableView.separatorStyle = .None
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.initCharts()
        self.navigationItem.title = String(format: "YEAR_MONTH_FORMAT".localizedString, "\(report.year)","\(report.month)")
        self.tableView.reloadData()
    }
    
    //MARK: inits
    
    private func initCharts()
    {
        initMoodTrendsChart()
        initMoodStatisticsChart()
    }
    
    private func initMoodTrendsChart()
    {
        let lineChartTitle = UILabel()
        lineChartTitle.text = "MOOD_TRENDS_TITLE".localizedString
        lineChartTitle.sizeToFit()
        lineChartTitle.textColor = UIColor.lightGrayColor()
        lineChartTitle.center = CGPointMake(tableView.center.x, -7)
        let frame = CGRectMake(10, 23, tableView.contentSize.width - 20, tableView.contentSize.width - 56)
        let lineChart = FSLineChart(frame: frame)
        lineChart.addSubview(lineChartTitle)
        lineChart.displayDataPoint = true
        func getLabel(index:UInt) -> String{
            return "\(index + 1)"
        }
        
        func labelForValue(value:CGFloat) -> String{
            if value < 30
            {
                return "😞"
            }else if value < 60
            {
                return "☹️"
            }else if value < 70
            {
                return "🙂"
            }else if value < 88
            {
                return "😀"
            }else
            {
                return "😄"
            }
        }
        lineChart.horizontalGridStep = 7
        lineChart.verticalGridStep = 5
        lineChart.labelForIndex = getLabel
        lineChart.labelForValue = labelForValue
        lineChart.fillColor = nil
        
        charts.append(lineChart)
    }
    
    private func initMoodStatisticsChart()
    {
        let barWidth:CGFloat = 23
        let chartTitle = UILabel()
        let barChart = TEABarChart()
        let cellHeight = tableView.contentSize.width
        let cellWidth = tableView.contentSize.width + 4
        chartTitle.text = "MOOD_STATISTICS_TITLE".localizedString
        chartTitle.sizeToFit()
        chartTitle.textColor = UIColor.lightGrayColor()
        chartTitle.center = CGPointMake(tableView.center.x, -13)
        
        barChart.addSubview(chartTitle)
        let barChartFormatter = NSNumberFormatter()
        barChartFormatter.numberStyle = .CurrencyStyle
        barChartFormatter.allowsFloats = false
        barChartFormatter.maximumFractionDigits = 0;
        
        func getValue(yValue:CGFloat) -> NSString
        {
            return barChartFormatter.stringFromNumber(yValue)!
        }
        
        let arr = MoodMarks.map{$0.id}
        
        barChart.data = arr.map{report.moodsMap[$0] ?? 0}
        
        barChart.xLabels = arr.map{ id -> String in
            if let mark = getDiaryMark("\(id)")
            {
                return "\(mark.emoji)"
            }else
            {
                return ""
            }
            }.filter{String.isNullOrEmpty($0) == false}
        let barSpace = (cellWidth - CGFloat(arr.count) * barWidth) / CGFloat(arr.count)
        barChart.barSpacing = Int(barSpace)
        
        barChart.barColors = arr.map({ (c) -> UIColor in
            return UIColor.getRandomTextColor()
        })
        
        var i:CGFloat = 0
        let _ = arr.map { (id) -> UILabel in
            
            let cl = UILabel()
            let count = report.moodsMap[id] ?? 0
            cl.text = "\(count)"
            cl.textColor = UIColor.whiteColor()
            cl.sizeToFit()
            let adjust = (barWidth - cl.frame.width) / 2
            let origin = CGPointMake(i  * (barSpace + barWidth) + adjust, cellHeight - 117)
            cl.frame.origin = origin
            i += 1
            barChart.addSubview(cl)
            return cl
        }
        charts.append(barChart)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.report == nil ? 0 : 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(MoodReportDetailCell.reuseId, forIndexPath: indexPath) as! MoodReportDetailCell

        // Configure the cell...
        if indexPath.row < charts.count
        {
            let chart = charts[indexPath.row]
            cell.addSubview(chart)
        }
        return cell
    }

    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < charts.count
        {
            let frame = CGRectMake(10, 23, cell.frame.size.width - 20, cell.frame.size.width - 67)
            if let chart = charts[indexPath.row] as? TEABarChart
            {
                chart.frame = frame
                chart.layoutSubviews()
            }else if let chart = charts[indexPath.row] as? FSLineChart
            {
                chart.frame = frame
                let days = DateHelper.daysOfMonth(report.year, month: report.month)
                var data = [Float]()
                
                for d in 1...days
                {
                    var moodPoint:Float = 0.0
                    let moods = report.moods.filter{$0.day == d}
                    moods.forEach({ (mood) -> () in
                        moodPoint += (mood.mark.info as! Float)
                    })
                    
                    if moodPoint > 0
                    {
                        let yPoint = moodPoint / Float(moods.count)
                        data.append(yPoint)
                    }else{
                        data.append(data.last ?? 60)
                    }
                }
                chart.setChartData(data)
            }
            
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.contentSize.width
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    static func showReport(rootController:UIViewController, report:Report)
    {
        let controller = instanceFromStoryBoard("MoodReport", identifier: "MoodReportDetailController") as! MoodReportDetailController
        controller.report = report
        rootController.navigationController!.pushViewController(controller, animated: true)
    }

}
