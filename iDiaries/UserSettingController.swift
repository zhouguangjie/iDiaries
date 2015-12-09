//
//  UserSettingController.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/7.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import UIKit

class UIEditTextPropertySet
{
    var isOneLineValue:Bool = true
    var valueRegex:String!
    var illegalValueMessage:String!
    
    var propertyValue:String!
    var propertyLabel:String!
    var propertyIdentifier:String!
}

struct TextPropertyCellModel
{
    var propertySet:UIEditTextPropertySet!
    var editable:Bool = false
    var selector:Selector!
}


class TextPropertyCell:UITableViewCell
{
    static let reuseIdentifier = "TextPropertyCell"
    var info:TextPropertyCellModel!{
        didSet{
            if propertyNameLabel != nil
            {
                propertyNameLabel.text = info?.propertySet?.propertyLabel
            }
            
            if propertyValueLabel != nil
            {
                propertyValueLabel.text = info?.propertySet?.propertyValue
            }
            
            if editableMark != nil
            {
                editableMark.hidden = !info!.editable
            }
        }
    }
    @IBOutlet weak var propertyNameLabel: UILabel!{
        didSet{
            propertyNameLabel.text = info?.propertySet?.propertyLabel
        }
    }
    @IBOutlet weak var propertyValueLabel: UILabel!{
        didSet{
            propertyValueLabel.text = info?.propertySet?.propertyValue
        }
    }
    @IBOutlet weak var editableMark: UIImageView!{
        didSet{
            if let i = info
            {
                editableMark.hidden = !i.editable
            }
        }
    }
    
    func refresh()
    {
        propertyNameLabel.text = info?.propertySet?.propertyLabel
        propertyValueLabel.text = info?.propertySet?.propertyValue
        editableMark.hidden = !info.editable
    }
}

class UserSettingController: UITableViewController
{
    struct InfoIds
    {
        static let changePsw = "changePassword"
        static let backup = "backup"
        static let alarm = "alarm"
    }
    
    override func viewDidLoad() {
        initPropertySet()
        tableView.tableFooterView = UIView()
        tableView.tableFooterView?.backgroundColor = UIColor.clearColor()
        tableView.reloadData()
    }
    
    //MARK: Property Cell
    var textPropertyCells:[TextPropertyCellModel] = [TextPropertyCellModel]()
    
    private func initPropertySet()
    {
        textPropertyCells.append(TextPropertyCellModel(propertySet: changePswPropertySet, editable: true, selector: "changePassword:"))
        textPropertyCells.append(TextPropertyCellModel(propertySet:backUp_resotrePropertySet,editable:true, selector: "backupOrRestore:"))
        textPropertyCells.append(TextPropertyCellModel(propertySet:writeDiaryAlarmPropertySet,editable:true, selector: "setAlarm:"))
    }
    
    private var changePswPropertySet:UIEditTextPropertySet
    {
        let propertySet = UIEditTextPropertySet()
        propertySet.propertyIdentifier = InfoIds.changePsw
        propertySet.propertyLabel = NSLocalizedString("CHANGE_PSW", comment: "Change Password")
        propertySet.propertyValue = ""
        return propertySet
    }
    
    private var backUp_resotrePropertySet:UIEditTextPropertySet
    {
        let propertySet = UIEditTextPropertySet()
        propertySet.propertyIdentifier = InfoIds.backup
        propertySet.propertyLabel = NSLocalizedString("BACKUP_RESTORE", comment:"Back/Restore")
        propertySet.propertyValue = ""
        return propertySet
    }
    
    private var writeDiaryAlarmPropertySet:UIEditTextPropertySet
    {
        let propertySet = UIEditTextPropertySet()
        propertySet.propertyIdentifier = InfoIds.alarm
        propertySet.propertyLabel = NSLocalizedString("ALARM_WRITE_DIARY", comment:"Alarm Write Diary")
        if let alarmTime = DiaryService.sharedInstance.hasWriteDiaryAlarm()
        {
            propertySet.propertyValue = "\(alarmTime.hour):\(alarmTime.minute)"
        }else
        {
            propertySet.propertyValue = NSLocalizedString("NO_ALARM", comment: "")
        }
        return propertySet
    }
    
    func changePassword(_:UITapGestureRecognizer)
    {
        PasswordLocker.showSetPasswordLocker(self) { (newPsw) -> Void in
            self.showToast(NSLocalizedString("PSW_CHANGED", comment: "Password Changed!"))
        }
    }
    
    func backupOrRestore(_:UITapGestureRecognizer)
    {
        
    }
    
    func setAlarm(tap:UITapGestureRecognizer)
    {
        let cell = tap.view as! TextPropertyCell
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("SELECT_ALARM_TIME", comment: "Select Alarm Time"), style: .Default, handler: { (action) -> Void in
            SelectDateController.showTimePicker(self, date: NSDate(), minDate: nil, maxDate: nil) { (dateTime) -> Void in
                DiaryService.sharedInstance.setWriteDiaryAlarm(dateTime)
                cell.info.propertySet.propertyValue = self.writeDiaryAlarmPropertySet.propertyValue
                cell.refresh()
            }
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("CLEAR_ALARM", comment: "Clear Alarm"), style: .Default, handler: { (action) -> Void in
            DiaryService.sharedInstance.clearDiaryAlarm()
            cell.info.propertySet.propertyValue = self.writeDiaryAlarmPropertySet.propertyValue
            cell.refresh()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true) { () -> Void in
            
        }
    }
    
    func about(_:UITapGestureRecognizer)
    {
        AboutViewController.showAbout(self)
    }
    
    //MARK: tableview delegate
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //user infos + about
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0
        {
            //textPropertyCells.count
            return textPropertyCells.count
        }else
        {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 23
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0
        {
            return getTextPropertyCell(indexPath.row)
        }else
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("aboutAppCell",forIndexPath: indexPath)
            cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "about:"))
            return cell
        }
    }
    
    func getTextPropertyCell(index:Int) -> TextPropertyCell
    {
        let info = textPropertyCells[index]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TextPropertyCell.reuseIdentifier) as! TextPropertyCell
        if info.selector != nil
        {
            cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: info.selector))
        }
        cell.info = info
        return cell
    }

}
