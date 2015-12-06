//
//  NewDiaryDateCell.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/4.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import UIKit

let WeekNames = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]

class NewDiaryDateCell: NewDiaryBaseCell {
    static let reuseId = "NewDiaryDateCell"
    var diaryDate = NSDate(){
        didSet{
            if dateLabel != nil
            {
                updateDateLable()
            }
        }
    }
    @IBOutlet weak var dateLabel: UILabel!{
        didSet{
            updateDateLable()
            self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "selectDate:"))
        }
    }
    
    private func updateDateLable()
    {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd EEE"
        formatter.timeZone = NSTimeZone()
        dateLabel.text = formatter.stringFromDate(diaryDate)
    }
    
    func selectDate(_:UITapGestureRecognizer)
    {
        SelectDateController.showDatePicker(self.rootController,date: diaryDate, minDate: NSDate(timeIntervalSince1970: 0), maxDate: NSDate()) { (dateTime) -> Void in
            if dateTime != nil
            {
                self.diaryDate = dateTime
            }
        }
    }
}
