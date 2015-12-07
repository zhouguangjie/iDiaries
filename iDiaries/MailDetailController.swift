//
//  MailDetailController.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/7.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import UIKit

//MARK:MailDetailCell
class MailDetailCell: UITableViewCell{
    static let reuseId = "MailDetailCell"
    var timeMail:TimeMailModel!
}

//MARK:MailDetailController
class MailDetailController: UITableViewController {
    var timeMail:TimeMailModel!
    
    //MARK: life process
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 48;
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    //MARK: table view delegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(MailDetailCell.reuseId, forIndexPath: indexPath) as! MailDetailCell
        cell.timeMail = self.timeMail
        return cell
    }
}
