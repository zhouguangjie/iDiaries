//
//  DiaryService.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/3.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import Foundation

//MARK: models
class DiaryMark: BahamutObject
{
    override func getObjectUniqueIdName() -> String {
        return "markId"
    }
    var markId:String!
    var name:String!
    var emoji:String!
    
    init(markStruct:MarkStruct) {
        super.init()
        self.markId = "\(markStruct.id)"
        self.name = markStruct.name
        self.emoji = markStruct.emoji
    }

    required init() {
        super.init()
    }
}

class DiaryTypedMarks: BahamutObject
{
    var typeName:String!
    var marks:[DiaryMark]!
}

class DiaryModel: BahamutObject
{
    override func getObjectUniqueIdName() -> String {
        return "diaryId"
    }
    
    var diaryId:String!
    var dateTime:NSNumber!
    var mainContent:String!
    var weathers:[DiaryMark]!
    var moods:[DiaryMark]!
    var summary:[DiaryMark]!
    var diaryType:String!
    var diaryMarked:Bool = false
    var lastModifiedTime:NSNumber!
}

class TimeMailModel : BahamutObject
{
    override func getObjectUniqueIdName() -> String {
        return "mailId"
    }
    var mailId:String!
    var sendMailTime:NSNumber!
    var mailReceiveDateTime:NSNumber!
    var msgContent:String!
    var diary:DiaryModel!
    var read:Bool = false
    var lastModifiedTime:NSNumber!
    var calendarIdentifier:String!
}

enum DiaryType : String
{
    case Normal = "normal"
}

//MARK: DiaryService
class DiaryService: NSNotificationCenter {
    static var sharedInstance = {
       return DiaryService()
    }()
    
    override init() {
        
    }
    
    var newestDiaryDateTimeInterval:NSTimeInterval{
        get{
            return NSUserDefaults.standardUserDefaults().doubleForKey("newestDiaryDateTimeInterval") ?? 0
        }
        set{
            NSUserDefaults.standardUserDefaults().setDouble(newValue, forKey: "newestDiaryDateTimeInterval")
        }
    }
    
    //MARK: alarm write diary
    let ALARM_WRITE_DIARY_TIME_KEY = "ALARM_WRITE_DIARY_TIME_KEY"
    func hasWriteDiaryAlarm() -> NSDate!
    {
        if let time = NSUserDefaults.standardUserDefaults().objectForKey(ALARM_WRITE_DIARY_TIME_KEY) as? NSDate{
            return time
        }
        return nil
    }
    
    func setWriteDiaryAlarm(alarmTime:NSDate)
    {
        clearDiaryAlarm()
        NSUserDefaults.standardUserDefaults().setObject(alarmTime, forKey: ALARM_WRITE_DIARY_TIME_KEY)
        let localNotification = UILocalNotification()
        localNotification.fireDate = alarmTime
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.repeatInterval = NSCalendarUnit.Day
        localNotification.alertBody = NSLocalizedString("TIME_TO_WRITE_DIARY", comment: "")
        localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        localNotification.hasAction = false
        localNotification.userInfo = ["type":"write_diary"]
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    func clearDiaryAlarm()
    {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: ALARM_WRITE_DIARY_TIME_KEY)
        UIApplication.sharedApplication().scheduledLocalNotifications?.removeElement{$0.userInfo != nil && ("write_diary" == $0.userInfo!["type"] as? String)}
    }
    
    //MARK: password
    let PSW_STORE_KEY = "PSW_STORE_KEY"
    func hasPassword() -> Bool
    {
        if let psw = NSUserDefaults.standardUserDefaults().objectForKey(PSW_STORE_KEY) as? String{
            return String.isNullOrWhiteSpace(psw) == false
        }
        return false
    }
    
    func setPassword(psw:String)
    {
        NSUserDefaults.standardUserDefaults().setObject(psw, forKey: PSW_STORE_KEY)
    }
    
    func checkPswCorrent(psw:String) -> Bool
    {
        if let pswStored = NSUserDefaults.standardUserDefaults().objectForKey(PSW_STORE_KEY) as? String{
            return psw == pswStored
        }
        return false
    }
    
    //MARK: diary
    
    func addDiary(diaryModel:DiaryModel)
    {
        let now = NSDate().timeIntervalSince1970
        newestDiaryDateTimeInterval = now
        diaryModel.lastModifiedTime = now
        diaryModel.saveModel()
        PersistentManager.sharedInstance.saveAll()
    }
    
    func deleteDiary(diary:DiaryModel)
    {
        PersistentManager.sharedInstance.removeModel(diary)
        PersistentManager.sharedInstance.saveAll()
    }
    
    func getDiariesOfMonth(year:Int,month:Int,callback:([DiaryModel])->Void)
    {
        getAllDiaries { (diaries) -> Void in
            let result = diaries.filter({ (diary) -> Bool in
                let date = NSDate(timeIntervalSince1970: diary.dateTime.doubleValue)
                return date.yearOfDate == year && date.monthOfDate == month
            })
            callback(result)
        }
    }
    
    func getAllDiaries(callback:([DiaryModel])->Void)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            let diaries = PersistentManager.sharedInstance.getAllModel(DiaryModel)
            let sorted = diaries.sort({ (a, b) -> Bool in
                a.dateTime.doubleValue > b.dateTime.doubleValue
            })
            callback(sorted)
        }
        
    }
}