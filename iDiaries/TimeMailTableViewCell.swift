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
    var rootController:TimeMailTableViewController!
    var timeMail:TimeMailModel!
    @IBOutlet weak var mailContent: UILabel!
    
    @IBOutlet weak var mailStatusImg: UIImageView!{
        didSet{
            initCell()
        }
    }

    private func initCell()
    {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TimeMailTableViewCell.onCellTaped(_:))))
    }
    
    func onCellTaped(_:UITapGestureRecognizer)
    {
        timeMail.read = true
        timeMail.saveModel()
        PersistentManager.sharedInstance.saveAll()
        refresh()
        rootController.performSegueWithIdentifier(SegueShowMailDetailController, sender: self)
    }
    
    func refresh()
    {
        mailContent.text = timeMail.msgContent
        let imageStatusName = timeMail.read ? "mail_read" : "mail_not_read"
        mailStatusImg.image = UIImage(named: imageStatusName)
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
    }
}
