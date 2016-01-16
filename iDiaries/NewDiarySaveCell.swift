//
//  NewDiarySaveCell.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/4.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import UIKit

class NewDiarySaveCell: NewDiaryBaseCell {
    static let reuseId = "NewDiarySaveCell"
    @IBAction func save(sender: AnyObject) {
        let btn = sender as! UIView
        btn.animationMaxToMin()
        rootController.saveDiary()
    }
}
