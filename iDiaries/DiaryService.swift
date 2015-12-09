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
        self.markId = markStruct.name
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
    var dateTime:String!
    var mainContent:String!
    var weathers:[DiaryMark]!
    var moods:[DiaryMark]!
    var summary:[DiaryMark]!
    var diaryType:String!
    var diaryMarked:Bool = false
}

class TimeMailModel : BahamutObject
{
    override func getObjectUniqueIdName() -> String {
        return "futureMsgId"
    }
    var futureMsgId:String!
    var sendMailTime:String!
    var mailReceiveDateTime:String!
    var msgContent:String!
    var diary:DiaryModel!
    var read:Bool = false
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
    
    //MARK:
    let ALARM_WRITE_DIARY_TIME_KEY = "ALARM_WRITE_DIARY_TIME_KEY"
    func hasWriteDiaryAlarm() -> (hour:Int,minute:Int)?
    {
        if let time = NSUserDefaults.standardUserDefaults().objectForKey(ALARM_WRITE_DIARY_TIME_KEY) as? NSDate{
            return (hour:time.hourOfDate,minute:time.minuteOfDate)
        }
        return nil
    }
    
    func setWriteDiaryAlarm(alarmTime:NSDate)
    {
        NSUserDefaults.standardUserDefaults().setObject(alarmTime, forKey: ALARM_WRITE_DIARY_TIME_KEY)
    }
    
    func clearDiaryAlarm()
    {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: ALARM_WRITE_DIARY_TIME_KEY)
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
        diaryModel.saveModel()
        PersistentManager.sharedInstance.saveAll()
    }
    
    func addFutureMessage(msg:TimeMailModel)
    {
        msg.saveModel()
        PersistentManager.sharedInstance.saveAll()
    }
    
    func deleteDiary(diary:DiaryModel)
    {
        PersistentManager.sharedInstance.removeModel(diary)
        PersistentManager.sharedInstance.saveAll()
    }
    
    func getAllDailies(callback:([DiaryModel])->Void)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            let diaries = PersistentManager.sharedInstance.getAllModel(DiaryModel)
            let sorted = diaries.sort({ (a, b) -> Bool in
                a.dateTime!.dateTimeOfString.timeIntervalSince1970 > b.dateTime!.dateTimeOfString.timeIntervalSince1970
            })
            callback(sorted)
        }
        
    }
}