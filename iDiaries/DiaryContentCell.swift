//
//  DailyContentCell.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/3.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import UIKit

class DiaryContentCell: UITableViewCell {
    static let reuseId = "DiaryContentCell"
    
    var rootController:ViewController!
    var diary:DiaryModel!
    @IBOutlet weak var diaryMarkImgView: UIImageView!
    @IBOutlet weak var daySummaryLabel: UILabel!
    @IBOutlet weak var weatherAndMoodLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mainContentTextView: UILabel!{
        didSet{
            self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapCell:"))
        }
    }
    
    func tapCell(_:UITapGestureRecognizer)
    {
        rootController.performSegueWithIdentifier(SegueShowDairyDetailViewController, sender: self)
    }
    
    func update(){
        diaryMarkImgView.hidden = !diary.diaryMarked
        daySummaryLabel.text = diary.summary.map{$0.displayName}.joinWithSeparator(" ")
        weatherAndMoodLabel.text = diary.weathers.map{$0.emoji!}.joinWithSeparator("") + diary.moods.map{$0.emoji!}.joinWithSeparator("")
        updateDateLable()
        mainContentTextView.text = diary.mainContent
    }
    
    private func updateDateLable()
    {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd EEE"
        formatter.timeZone = NSTimeZone()
        let date = NSDate(timeIntervalSince1970: diary.dateTime.doubleValue)
        dateLabel.text = formatter.stringFromDate(date)
        
    }
}
