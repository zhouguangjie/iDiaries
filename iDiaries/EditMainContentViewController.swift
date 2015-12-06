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
    
    @IBOutlet weak var mainContentTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mainContentTextView.text = mainContentCell.mainContent
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        mainContentTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        mainContentCell.mainContent = mainContentTextView.text ?? ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
