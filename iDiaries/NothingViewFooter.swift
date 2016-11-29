//
//  NothingViewFooter.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/7.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import UIKit

class NothingViewFooter: UIView {

    static func instanceFromXib() -> NothingViewFooter
    {
        return NSBundle.mainBundle().loadNibNamed("NothingViewFooter", owner: nil, options: nil)!.filter{$0 is NothingViewFooter}.first as! NothingViewFooter
    }
    @IBOutlet weak var messageLabel: UILabel!

}
