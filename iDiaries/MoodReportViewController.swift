//
//  MoodReportViewController.swift
//  iDiaries
//
//  Created by AlexChow on 16/1/14.
//  Copyright © 2016年 GStudio. All rights reserved.
//

import UIKit
import MBProgressHUD

//MARK: MoodReportCell
class MoodReportCell : UITableViewCell
{
    static let titleFormatter:NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "YEAR_MONTH_FORMAT".localizedString()
        formatter.timeZone = NSTimeZone.systemTimeZone()
        return formatter
    }()
    
    @IBOutlet weak var reportTitleLabel: UILabel!{
        didSet{
            self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onClick:"))
        }
    }
    static let reuseId = "MoodReportCell"
    
    var rootController:MoodReportViewController!
    var report:Report!
    
    func onClick(_:UITapGestureRecognizer)
    {
        MoodReportDetailController.showReport(rootController, report: self.report)
    }
    
    func refresh()
    {
        if report != nil && reportTitleLabel != nil
        {
            let date = DateHelper.generateDate(report.year,month: report.month)
            reportTitleLabel.text = MoodReportCell.titleFormatter.stringFromDate(date)
        }
    }
}

//MARK: MoodReportViewController
class MoodReportViewController: UITableViewController
{

    private var reportsLoaded = false
    override func viewDidLoad() {
        super.viewDidLoad()
        initTableView()
    }

    private var refreshReportsHud:MBProgressHUD!
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if self.reportsLoaded == false
        {
            refreshReportsHud = self.showActivityHud()
            let allDiaries = DiaryListManager.sharedInstance.diaries
            if allDiaries.count == 0
            {
                DiaryService.sharedInstance.getAllDiaries({ (diaries) -> Void in
                    self.refreshReports(diaries)
                })
            }else
            {
                self.refreshReports(allDiaries)
            }
        }
    }
    
    private func refreshReports(allDiaries:[DiaryModel])
    {
        ReportService.sharedInstance.refreshReports(allDiaries, callback: { () -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
                self.refreshReportsHud.hideAsync(true)
                self.reportsLoaded = true
                self.updateTableViewFooter()
            })
        })
    }
    
    private func updateTableViewFooter()
    {
        if ReportService.sharedInstance.allReports.count == 0
        {
            let footer = NothingViewFooter.instanceFromXib()
            footer.messageLabel.text = "NO_MONTH_MOOD_REPORT".localizedString()
            footer.frame = tableView.bounds
            tableView.tableFooterView = footer
            self.view.backgroundColor = footer.backgroundColor
        }else
        {
            tableView.tableFooterView = UIView()
        }
    }

    private func initTableView()
    {
        self.tableView.allowsMultipleSelection = false
        self.tableView.allowsSelection = false
        self.tableView.tableFooterView = UIView()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return ReportService.sharedInstance.allReports.count > 0 ? 1 : 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReportService.sharedInstance.allReports.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(MoodReportCell.reuseId, forIndexPath: indexPath) as! MoodReportCell
        cell.report = ReportService.sharedInstance.allReports[indexPath.row]
        cell.rootController = self
        cell.refresh()
        return cell
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

}
