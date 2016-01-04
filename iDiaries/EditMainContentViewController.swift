//
//  EditMainContentViewController.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/7.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import UIKit

class EditMainContentViewController: UIViewController,UITextViewDelegate {

    var mainContentCell:NewDiaryTextContentCell!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainContentTextView: UITextView!{
        didSet{
            mainContentTextView.delegate = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        mainContentTextView.text = mainContentCell.mainContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onKeyBoardSFrameChanged:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        mainContentTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        mainContentCell.mainContent = mainContentTextView.text ?? ""
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func onKeyBoardSFrameChanged(aNotification:NSNotification)
    {
        if let userInfo = aNotification.userInfo
        {
            if let beginKeyboardRect = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue
            {
                if let endKeyboardRect = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue
                {
                    let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! CGFloat
                    let yOffset = beginKeyboardRect.origin.y - endKeyboardRect.origin.y
                    UIView.animateWithDuration(Double(duration)) { () -> Void in
                        self.bottomConstraint.constant += yOffset
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var originBottom:CGFloat = 0
    func textViewDidBeginEditing(textView: UITextView) {
    }
    
    func textViewDidEndEditing(textView: UITextView) {
    }

}
