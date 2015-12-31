//
//  NewDiaryTextContentCell.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/4.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import UIKit
import AudioToolbox

let mainContentPlaceHolderText = NSLocalizedString("MainContentPlaceHolderText", comment: "")

class NewDiaryTextContentCell: NewDiaryBaseCell,UITextViewDelegate {
    static let reuseId = "NewDiaryTextContentCell"
    
    @IBOutlet weak var mainContentTextView: UITextView!{
        didSet{
            mainContentTextView.delegate = self
            mainContentTextView.layer.cornerRadius = 7
            mainContentTextView.layer.borderWidth = 1
            mainContentTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
            let rec = UISwipeGestureRecognizer(target: self, action: "showEditContentController:")
            rec.direction = .Left
            mainContentTextView.addGestureRecognizer(rec)
            self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onViewTap:"))
        }
    }
    @IBOutlet weak var diaryMarkImgView: UIImageView!{
        didSet{
            if oldValue != nil
            {
                isMarkedDiary ? SystemSoundHelper.keyTink() : SystemSoundHelper.keyTock()
            }
            diaryMarkImgView.image = isMarkedDiary ? UIImage(named: "diary_mark") : UIImage(named: "diary_unmark")
            diaryMarkImgView.userInteractionEnabled = true
            diaryMarkImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapDiaryMark:"))
        }
    }
    
    @IBOutlet weak var mainContentPlaceHolder: UILabel!{
        didSet{
            mainContentPlaceHolder.text = mainContentPlaceHolderText
        }
    }
    
    var isMarkedDiary = false{
        didSet{
            if diaryMarkImgView != nil{
                diaryMarkImgView.image = isMarkedDiary ? UIImage(named: "diary_mark") : UIImage(named: "diary_unmark")
            }
        }
    }
    
    var mainContent:String{
        set{
            mainContentTextView.text = newValue
            updateMsgTxtPlaceHolder()
        }
        get{
            return mainContentTextView.text ?? ""
        }
    }
    
    func onViewTap(_:UITapGestureRecognizer)
    {
        self.rootController.hideKeyBoard()
    }
    
    func showEditContentController(_:UIGestureRecognizer)
    {
        self.rootController.performSegueWithIdentifier(SegueShowEditView, sender: self)
    }
    
    func clearContent()
    {
        mainContentTextView.text = ""
    }
    
    func tapDiaryMark(_:UITapGestureRecognizer)
    {
        isMarkedDiary = !isMarkedDiary
        isMarkedDiary ? SystemSoundHelper.keyTink() : SystemSoundHelper.keyTock()
    }
    
    private func updateMsgTxtPlaceHolder()
    {
        if mainContentPlaceHolder != nil && mainContentTextView != nil
        {
            mainContentPlaceHolder.hidden = !String.isNullOrEmpty(mainContentTextView?.text ?? nil)
        }
    }
    
    //MARK: text view delegate
    func textViewDidChange(textView: UITextView)
    {
        updateMsgTxtPlaceHolder()
    }
}
