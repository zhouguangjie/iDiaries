//
//  TimeMailTableViewCell.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/7.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import UIKit

class TimeMailTableViewCell: UITableViewCell {
    static let reuseId = "TimeMailTableViewCell"
    var timeMail:TimeMailModel!
    @IBOutlet weak var mailContent: UILabel!
    
    @IBOutlet weak var mailStatusImg: UIImageView!

    override func layoutSubviews() {
        mailContent.text = timeMail.msgContent
        let imageStatusName = timeMail.read ? "mail_read" : "mail_not_read"
        mailStatusImg.image = UIImage(named: imageStatusName)
        super.layoutSubviews()
    }
}
