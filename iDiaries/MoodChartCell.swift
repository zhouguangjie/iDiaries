//
//  MoodChartCell.swift
//  iDiaries
//
//  Created by AlexChow on 16/7/6.
//  Copyright © 2016年 GStudio. All rights reserved.
//
import UIKit
import Charts

let barChartColors:[UIColor] = {
    var colors = [UIColor]()
    colors.appendContentsOf(ChartColorTemplates.vordiplom())
    colors.appendContentsOf(ChartColorTemplates.joyful())
    colors.appendContentsOf(ChartColorTemplates.liberty())
    colors.appendContentsOf(ChartColorTemplates.pastel())
    return colors
    
}()

func moodValueEmoji(value:CGFloat) -> String
{
    if value <= 30
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

class MoodReportStartCell: UITableViewCell {
    static let reuseId = "MoodReportStartCell"
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
}

class MoodReportDetailCell:UITableViewCell
{
    var rootController:MoodReportDetailController!
    static let reuseId = "MoodReportDetailCell"
    @IBOutlet weak var chartContainer: UIView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
}

class MoodReportSummaryCell:UITableViewCell
{
    var rootController:MoodReportDetailController!
    @IBAction func shareFriends() {
        UIPasteboard.generalPasteboard().setValue("itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=1065482853", forPasteboardType: "public.utf8-plain-text")
        self.rootController.playToast("SHARE_URL_COPIED".localizedString())
    }
    
    @IBAction func newDiary() {
        rootController.dismissViewControllerAnimated(true) { 
            MainViewController.instance.navigationController?.popToViewController(MainViewController.instance, animated: true)
            MainViewController.instance.mode = .NewDiaryMode
        }
    }
    
    @IBAction func back() {
        rootController.dismissViewControllerAnimated(true, completion: nil)
    }
    static let reuseId = "MoodReportSummaryCell"
}