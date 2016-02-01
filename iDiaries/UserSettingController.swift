//
//  UserSettingController.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/7.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import UIKit
import LocalAuthentication

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
        static let alarmSync = "alarmSync"
        static let alarm = "alarm"
        static let useTouchId = "useTouchId"
    }
    
    private var shownVoteMeAlert:Bool = false
    
    private var notShowGetSharelink:Bool{
        return false
    }
    
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
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 48;
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
        textPropertyCells.append(TextPropertyCellModel(propertySet: useTouchIdPropertySet, editable: true, selector: "useTouchId:"))
        textPropertyCells.append(TextPropertyCellModel(propertySet:syncDiariesPropertySet,editable:true, selector: "syncDiaries:"))
        textPropertyCells.append(TextPropertyCellModel(propertySet:alarmSyncPropertySet,editable:true, selector: "alarmSync:"))
        textPropertyCells.append(TextPropertyCellModel(propertySet:writeDiaryAlarmPropertySet,editable:true, selector: "setAlarm:"))
    }
    
    //MARK: property set
    private var changePswPropertySet:UIEditTextPropertySet
    {
        let propertySet = UIEditTextPropertySet()
        propertySet.propertyIdentifier = InfoIds.changePsw
        propertySet.propertyLabel = "CHANGE_PSW".localizedString
        propertySet.propertyValue = ""
        return propertySet
    }
    
    private var useTouchIdPropertySet:UIEditTextPropertySet
        {
            let propertySet = UIEditTextPropertySet()
            propertySet.propertyIdentifier = InfoIds.useTouchId
            propertySet.propertyLabel = "USE_TOUCH_ID".localizedString
            if isTouchIdAvailable
            {
                propertySet.propertyValue = UserSetting.isSettingEnable("USE_TOUCH_ID") ? "ON".localizedString : "OFF".localizedString
            }else
            {
                propertySet.propertyValue = "NOT_AVAILABLE".localizedString
            }
            return propertySet
    }
    
    private var alarmSyncPropertySet:UIEditTextPropertySet
    {
        let propertySet = UIEditTextPropertySet()
        propertySet.propertyIdentifier = InfoIds.alarmSync
        propertySet.propertyLabel = "ALARM_SYNC".localizedString
        propertySet.propertyValue = SyncService.sharedInstance.remindSyncInterval.nameForShow
        return propertySet
    }
    
    private var syncDiariesPropertySet:UIEditTextPropertySet
    {
        let propertySet = UIEditTextPropertySet()
        propertySet.propertyIdentifier = InfoIds.syncDiaries
        propertySet.propertyLabel = "SYNC_DIARIES".localizedString
        propertySet.propertyValue = ""
        return propertySet
    }
    
    private var writeDiaryAlarmPropertySet:UIEditTextPropertySet
    {
        let propertySet = UIEditTextPropertySet()
        propertySet.propertyIdentifier = InfoIds.alarm
        propertySet.propertyLabel = "ALARM_WRITE_DIARY".localizedString
        if let alarmTime = DiaryService.sharedInstance.hasWriteDiaryAlarm()
        {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "hh:mm"
            formatter.timeZone = NSTimeZone()
            propertySet.propertyValue = formatter.stringFromDate(alarmTime)
        }else
        {
            propertySet.propertyValue = "NO_ALARM".localizedString
        }
        return propertySet
    }
    
    private var isTouchIdAvailable:Bool={
        let lactx = LAContext()
        let policy = LAPolicy.DeviceOwnerAuthenticationWithBiometrics
        if lactx.canEvaluatePolicy(policy, error: nil)
        {
            return true
        }else
        {
            return false
        }
    }()
    
    //MARK: actions
    
    func useTouchId(tap:UITapGestureRecognizer)
    {
        if isTouchIdAvailable
        {
            let cell = tap.view as! TextPropertyCell
            let alert = UIAlertController(title: "USE_TOUCH_ID".localizedString, message: nil, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "ON".localizedString, style: .Default, handler: { (action) -> Void in
                
                UserSetting.enableSetting("USE_TOUCH_ID")
                cell.info.propertySet.propertyValue = "ON".localizedString
                cell.refresh()
            }))
            alert.addAction(UIAlertAction(title: "OFF".localizedString, style: .Default, handler: { (action) -> Void in
                UserSetting.disableSetting("USE_TOUCH_ID")
                cell.info.propertySet.propertyValue = "OFF".localizedString
                cell.refresh()
            }))
            alert.addAction(UIAlertAction(title: "CANCEL".localizedString, style: .Cancel, handler: { (action) -> Void in
            }))
            self.presentViewController(alert, animated: true){ action in
            }
        }else
        {
            self.playToast("TouchID \("NOT_AVAILABLE".localizedString)!")
        }
    }
    
    func changePassword(_:UITapGestureRecognizer)
    {
        PasswordLocker.showSetPasswordLocker(self) { (newPsw) -> Void in
            let msg = NSLocalizedString("PSW_CHANGED", comment: "Password Changed!")
            self.playCheckMark(msg)
        }
    }
    
    func alarmSync(tap:UITapGestureRecognizer)
    {
        let cell = tap.view as! TextPropertyCell
        let alert = UIAlertController(title: "ALARM_SYNC".localizedString, message: nil, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "EVERY_WEEK".localizedString, style: .Default, handler: { (action) -> Void in
            self.setSyncAlarm(.oneWeek)
            cell.refresh()
        }))
        alert.addAction(UIAlertAction(title: "EVERY_MONTH".localizedString, style: .Default, handler: { (action) -> Void in
            self.setSyncAlarm(.oneMonth)
            cell.refresh()
        }))
        
        alert.addAction(UIAlertAction(title: "NO_ALARM".localizedString, style: .Default, handler: { (action) -> Void in
            self.setSyncAlarm(.noAlarm)
            cell.refresh()
        }))
        alert.addAction(UIAlertAction(title: "CANCEL".localizedString, style: .Cancel, handler: { (action) -> Void in
        }))
        self.presentViewController(alert, animated: true){ action in
        }
    }
    
    private func setSyncAlarm(interval:SyncAlarmInterval)
    {
        alarmSyncPropertySet.propertyValue = interval.nameForShow
        SyncService.sharedInstance.remindSyncInterval = interval
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
                let msg = NSLocalizedString("REMINDER_CHANGED", comment: "Reminder Changed!")
                self.playCheckMark(msg)
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
    
    func supportDeveloper(_:UITapGestureRecognizer)
    {
        
    }
    
    //MARK: tableview delegate
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //user infos + about + sharelink
        return 2 + (notShowGetSharelink ? 0 : 1)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0
        {
            return textPropertyCells.count
        }else
        {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1
        {
            return UITableViewAutomaticDimension
        }
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
        }else {
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
