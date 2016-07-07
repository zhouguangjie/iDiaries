//
//  TimeMailTableViewController.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/7.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import UIKit

let SegueShowMailDetailController = "ShowMailDetailController"

//MARK:TimeMailTableViewController
class TimeMailTableViewController: UITableViewController {

    private var mailsLoaded = false
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 48;
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func updateTableViewFooter()
    {
        if ServiceContainer.getTimeMailService().timeMails.count == 0
        {
            let footer = NothingViewFooter.instanceFromXib()
            footer.messageLabel.text = NSLocalizedString("NO_MAIL_HERE", comment: "")
            footer.frame = tableView.bounds
            tableView.tableFooterView = footer
        }else
        {
            tableView.tableFooterView = UIView()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if mailsLoaded == false
        {
            let hud = self.showActivityHud()
            ServiceContainer.getTimeMailService().refreshTimeMailBox { () -> Void in
                hud.hideAsync(true)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.updateTableViewFooter()
                    self.tableView.reloadData()
                    self.mailsLoaded = true
                })
            }
        }
    }
    
    //MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueShowMailDetailController
        {
            let mdc = segue.destinationViewController as! MailDetailController
            let cell = sender as! TimeMailTableViewCell
            mdc.timeMail = cell.timeMail
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return ServiceContainer.getTimeMailService().timeMails.count > 0 ? 1 : 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ServiceContainer.getTimeMailService().timeMails.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TimeMailTableViewCell.reuseId, forIndexPath: indexPath) as! TimeMailTableViewCell

        // Configure the cell...
        cell.timeMail = ServiceContainer.getTimeMailService().timeMails[indexPath.row]
        cell.rootController = self
        cell.refresh()
        return cell
    }

}
