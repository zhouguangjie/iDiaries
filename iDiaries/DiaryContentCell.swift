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
    
    var diary:DiaryModel!
    @IBOutlet weak var diaryMarkImgView: UIImageView!
    @IBOutlet weak var daySummaryLabel: UILabel!
    @IBOutlet weak var weatherAndMoodLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mainContentTextView: UILabel!
    
    func update(){
        diaryMarkImgView.hidden = !diary.diaryMarked
        daySummaryLabel.text = diary.summary.map{NSLocalizedString($0.name!, comment: "")}.joinWithSeparator(" ")
        weatherAndMoodLabel.text = diary.weathers.map{$0.emoji!}.joinWithSeparator("") + diary.moods.map{$0.emoji!}.joinWithSeparator("")
        updateDateLable()
        mainContentTextView.text = diary.mainContent
    }
    
    private func updateDateLable()
    {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd EEE"
        formatter.timeZone = NSTimeZone()
        let date = DateHelper.stringToDateTime(diary.dateTime)
        dateLabel.text = formatter.stringFromDate(date)
        
    }
}
