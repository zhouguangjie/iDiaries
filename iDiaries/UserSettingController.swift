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
        
        var propertySet = UIEditTextPropertySet()
        propertySet.propertyIdentifier = InfoIds.changePsw
        propertySet.propertyLabel = NSLocalizedString("CHANGE_PSW", comment: "Change Password")
        propertySet.propertyValue = ""
        textPropertyCells.append(TextPropertyCellModel(propertySet: propertySet, editable: true, selector: "changePassword:"))
        
        propertySet = UIEditTextPropertySet()
        propertySet.propertyIdentifier = InfoIds.backup
        propertySet.propertyLabel = NSLocalizedString("BACKUP_RESTORE", comment:"Back/Restore")
        propertySet.propertyValue = ""
        textPropertyCells.append(TextPropertyCellModel(propertySet:propertySet,editable:true, selector: "backOrRestore:"))
        
        propertySet = UIEditTextPropertySet()
        propertySet.propertyIdentifier = InfoIds.alarm
        propertySet.propertyLabel = NSLocalizedString("ALARM_WRITE_DIARY", comment:"Alarm Write Diary")
        propertySet.propertyValue = ""
        textPropertyCells.append(TextPropertyCellModel(propertySet:propertySet,editable:true, selector: "setAlarm:"))
        
    }
    
    func changePassword(_:UITapGestureRecognizer)
    {
        PasswordLocker.showSetPasswordLocker(self) { (newPsw) -> Void in
            self.showToast(NSLocalizedString("PSW_CHANGED", comment: "Password Changed!"))
        }
    }
    
    func backOrRestore(_:UITapGestureRecognizer)
    {
        
    }
    
    func setAlarm(_:UITapGestureRecognizer)
    {
        SelectDateController.showTimePicker(self, date: NSDate(), minDate: nil, maxDate: nil) { (dateTime) -> Void in
            
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
