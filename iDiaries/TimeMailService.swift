//
//  TimeMailService.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/7.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import Foundation
import EventKit

//MARK: TimeMailService
class TimeMailService: NSNotificationCenter
{
    static var sharedInstance = {
        return TimeMailService()
    }()
    
    private(set) var timeMails = [TimeMailModel]()
    
    var newestTimeMailDateTimeInterval:NSTimeInterval{
        get{
            return NSUserDefaults.standardUserDefaults().doubleForKey("newestTimeMailDateTimeInterval") ?? 0
        }
        set{
            NSUserDefaults.standardUserDefaults().setDouble(newValue, forKey: "newestTimeMailDateTimeInterval")
        }
    }
    
    var notReadMailCount:Int{
        return timeMails.filter{$0.read == false}.count
    }
    
    
    func addTimeMail(mail:TimeMailModel)
    {
        mail.lastModifiedTime = NSDate().timeIntervalSince1970
        mail.saveModel()
        PersistentManager.sharedInstance.saveAll()
        addTimeMailNotification(mail)
        addTimeMailsCalendarEvent([mail])
    }
    
    
    func getAllTimeMail(callback:([TimeMailModel])->Void)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            let mails = PersistentManager.sharedInstance.getAllModel(TimeMailModel)
            callback(mails)
        }
    }
    
    func refreshTimeMailBox(refreshedCallback:()->Void)
    {
        getAllTimeMail { (mails) -> Void in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
                self.timeMails.removeAll()
                var receivedMails = [TimeMailModel]()
                var notSendMails = [TimeMailModel]()
                let now = NSDate()
                for m in mails
                {
                    if m.mailReceiveDateTime.doubleValue <= now.timeIntervalSince1970
                    {
                        receivedMails.append(m)
                    }else
                    {
                        notSendMails.append(m)
                    }
                }
                self.addTimeMailsCalendarEvent(notSendMails)
                self.addTimeMailsNotification(notSendMails)
                PersistentManager.sharedInstance.saveAll()
                self.timeMails.appendContentsOf(receivedMails)
                refreshedCallback()
            }
        }
    }
    
    //MARK: - Time mail notification
    let mailReceivedNotificationId = "timeMailReceivedId"
    private func addTimeMailsNotification(mails:[TimeMailModel])
    {
        let mailNotifications = UIApplication.sharedApplication().scheduledLocalNotifications?.filter({ (notify) -> Bool in
            if let uinfo = notify.userInfo{
                if uinfo[mailReceivedNotificationId] != nil{
                    return true
                }
            }
            return false
        }) ?? []
        
        let map = mailNotifications.toMap {
            return $0.userInfo![self.mailReceivedNotificationId] as! String
        }
        
        for m in mails{
            if map[m.mailId] == nil{
                addTimeMailNotification(m)
            }
        }
    }
    
    private func addTimeMailNotification(mail:TimeMailModel)
    {
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSince1970: mail.mailReceiveDateTime.doubleValue)
        notification.userInfo = [mailReceivedNotificationId:mail.mailId,"type":"time_mail_received"]
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.alertBody = NSLocalizedString("YOU_HAVE_A_NEW_TIME_MAIL", comment: "")
        notification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    //MARK: - Calendar time mail reminder
    
    func requestReminderPermission()
    {
        let eventStore = EKEventStore()
        eventStore.requestAccessToEntityType(.Event, completion: { (result, error) -> Void in
        })
    }
    
    private func addTimeMailsCalendarEvent(mails:[TimeMailModel])
    {
        let eventStore = EKEventStore()
        eventStore.requestAccessToEntityType(.Event, completion: { (result, error) -> Void in
            if result == true
            {
                for m in mails
                {
                    self.addTimeMailCalendarEvent(eventStore, mail: m)
                }
            }
        })
    }

    private func addTimeMailCalendarEvent(eventStore:EKEventStore,mail:TimeMailModel)
    {
        if String.isNullOrWhiteSpace(mail.calendarIdentifier)
        {
            let event = EKEvent(eventStore: eventStore)
            let msg = NSLocalizedString("YOU_HAVE_A_NEW_TIME_MAIL", comment: "")
            let datetime = NSDate(timeIntervalSince1970: mail.mailReceiveDateTime.doubleValue)
            let alarm = EKAlarm(absoluteDate: datetime)
            event.title = iDiariesConfig.appTitle + ":" + msg
            event.notes = iDiariesConfig.appTitle
            event.timeZone = NSTimeZone.defaultTimeZone()
            event.allDay = true
            event.startDate = datetime
            event.endDate = datetime.addDays(1)
            event.addAlarm(alarm)
            event.calendar = eventStore.defaultCalendarForNewEvents
            
            do{
                try eventStore.saveEvent(event, span: EKSpan.ThisEvent, commit: true)
                mail.calendarIdentifier = event.calendarItemIdentifier
                mail.saveModel()
            }catch let err as NSError
            {
                NSLog("Add Calendar Event Error: %@", err.debugDescription)
            }
        }
    }

}