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

//MARK: UserSettingController
class UserSettingController: UITableViewController
{
    struct InfoIds
    {
        static let changePsw = "changePassword"
        static let syncDiaries = "syncDiaries"
        static let alarm = "alarm"
    }
    
    private var shownVoteMeAlert:Bool = false
    
    private var votedMe:Bool{
        get{
            return NSUserDefaults.standardUserDefaults().boolForKey("votedMe")
        }
        set{
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "votedMe")
        }
    }
    
    override func viewDidLoad() {
        initPropertySet()
        tableView.tableFooterView = UIView()
        tableView.tableFooterView?.backgroundColor = UIColor.clearColor()
        tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        MobClick.beginLogPageView("UserSetting")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        MobClick.endLogPageView("UserSetting")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if shownVoteMeAlert == false &&  votedMe == false{
            voteMe()
        }
    }
    
    //MARK: Property Cell
    private var textPropertyCells:[TextPropertyCellModel] = [TextPropertyCellModel]()
    
    private func voteMe()
    {
        let alert = UIAlertController(title: NSLocalizedString("INVITE_TO_VOTE_TITLE", comment: ""), message: NSLocalizedString("INVITE_TO_VOTE_MSG", comment: ""), preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("NO_THANKS", comment: "No Thanks"), style: .Default, handler: { (action) -> Void in
            self.votedMe = true
            MobClick.event("Reject Vote")
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("NEXT_TIME", comment: "Busy Now! Next Time"), style: .Default, handler: { (action) -> Void in
            
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("YES_I_LOVE_TO", comment: "No Thanks"), style: .Default, handler: { (action) -> Void in
            self.votedMe = true
            let url = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=\(iDiariesConfig.appStoreId)"
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }))
        self.showAlert(self, alertController: alert)
        shownVoteMeAlert = true
    }
    
    private func initPropertySet()
    {
        textPropertyCells.append(TextPropertyCellModel(propertySet: changePswPropertySet, editable: true, selector: "changePassword:"))
        textPropertyCells.append(TextPropertyCellModel(propertySet:syncDiariesPropertySet,editable:true, selector: "syncDiaries:"))
        textPropertyCells.append(TextPropertyCellModel(propertySet:writeDiaryAlarmPropertySet,editable:true, selector: "setAlarm:"))
    }
    
    //MARK: property set
    private var changePswPropertySet:UIEditTextPropertySet
    {
        let propertySet = UIEditTextPropertySet()
        propertySet.propertyIdentifier = InfoIds.changePsw
        propertySet.propertyLabel = NSLocalizedString("CHANGE_PSW", comment: "Change Password")
        propertySet.propertyValue = ""
        return propertySet
    }
    
    private var syncDiariesPropertySet:UIEditTextPropertySet
    {
        let propertySet = UIEditTextPropertySet()
        propertySet.propertyIdentifier = InfoIds.syncDiaries
        propertySet.propertyLabel = NSLocalizedString("SYNC_DIARIES", comment:"Sync Diaries")
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
            let formatter = NSDateFormatter()
            formatter.dateFormat = "hh:mm"
            formatter.timeZone = NSTimeZone()
            propertySet.propertyValue = formatter.stringFromDate(alarmTime)
        }else
        {
            propertySet.propertyValue = NSLocalizedString("NO_ALARM", comment: "")
        }
        return propertySet
    }
    
    //MARK: actions
    func changePassword(_:UITapGestureRecognizer)
    {
        PasswordLocker.showSetPasswordLocker(self) { (newPsw) -> Void in
            self.showToast(NSLocalizedString("PSW_CHANGED", comment: "Password Changed!"))
        }
    }
    
    func syncDiaries(_:UITapGestureRecognizer)
    {
        SyncDiariesViewController.showSyncDiariesViewController(self.navigationController!)
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
    
    func getSharelink(_:UITapGestureRecognizer)
    {
        let url = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=1059287119"
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }
    
    //MARK: tableview delegate
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //user infos + about + sharelink
        return 3
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
        }else if indexPath.section == 1
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("aboutAppCell",forIndexPath: indexPath)
            cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "about:"))
            return cell
        }else{
            MobClick.event("GetSharelink")
            let cell = tableView.dequeueReusableCellWithIdentifier("GetSharelinkCell",forIndexPath: indexPath)
            cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "getSharelink:"))
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
