//
//  NewDiaryRemindFutureCell.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/4.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import UIKit

class NewDiaryRemindFutureCell: NewDiaryBaseCell {
    static let reuseId = "NewDiaryRemindFutureCell"
    
    @IBOutlet weak var futureReviewCheckImg: UIImageView!{
        didSet{
            futureReviewCheckImg.userInteractionEnabled = true
            futureReviewCheckImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "selectTimeReviewDiary:"))
        }
    }
    private(set) var futureReviewTime:NSDate!
    @IBOutlet weak var toFutureMe: UILabel!{
        didSet{
            toFutureMe.userInteractionEnabled = true
            toFutureMe.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "selectTimeReviewDiary:"))
        }
    }
    
    func selectTimeReviewDiary(_:UITapGestureRecognizer)
    {
        let now = NSDate()
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ONE_WEEK", comment: ""), style: .Default, handler: { (action) -> Void in
            self.setReviewDiaryTime(now.addWeeks(1))
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("ONE_MONTH", comment: ""), style: .Default, handler: { (action) -> Void in
            self.setReviewDiaryTime(now.addMonthes(1))
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("ONE_YEAR", comment: ""), style: .Default, handler: { (action) -> Void in
            self.setReviewDiaryTime(now.addYears(1))
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("SELECT_REVIEW_TIME", comment: ""), style: .Default, handler: { (action) -> Void in
            self.selectADate()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("CANCEL_REVIEW", comment: ""), style: .Default, handler: { (action) -> Void in
            self.setReviewDiaryTime(nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .Cancel, handler: { (action) -> Void in
        }))
        rootController.presentViewController(alert, animated: true, completion: nil)
    }
    
    func selectADate()
    {
        SelectDateController.showDatePicker(self.rootController, date: NSDate().addDays(1), minDate: NSDate().addDays(1), maxDate: nil) { (dateTime) -> Void in
            
            self.setReviewDiaryTime(dateTime)
        }
    }
    
    func setReviewDiaryTime(date:NSDate!)
    {
        self.futureReviewTime = date
        if futureReviewTime == nil{
            futureReviewCheckImg.image = UIImage(named: "unchecked")
            toFutureMe.text = NSLocalizedString("REMIND_FUTURE_ME_REVIEW", comment: "")
        }else{
            futureReviewCheckImg.image = UIImage(named: "checked")
            let dateStrformat = NSLocalizedString("REMIND_FUTURE_ME_REVIEW_AT", comment: "")
            toFutureMe.text = String(format: dateStrformat, date.toLocalDateString())
        }
    }
}
