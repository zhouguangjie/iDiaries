//
//  SyncService.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/18.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import Foundation
import EVReflection

//MARK: SyncAlarmInterval
enum SyncAlarmInterval:Int
{
    case noAlarm = 0
    case oneWeek = 7
    case oneMonth = 30
    
    var nameForShow:String{
        var value = ""
        switch self
        {
            case .noAlarm: value = NSLocalizedString("NO_REMIDER", comment: "No Alarm")
            case .oneMonth:value = NSLocalizedString("EVARY_MONTH", comment: "Every Month")
            case .oneWeek:value = NSLocalizedString("EVARY_WEEK", comment: "Every Week")
        }
        return value
    }
}

//MARK: sync model
class LockFileModel: EVObject
{
    var version:String! = LockFileVersion
    var syncDates:[NSNumber]! = [NSNumber]()
    var syncFiles:[String]! = [String]()
}

class SyncFileModel: EVObject
{
    var version:String! = SyncFileVersion
    var mails:[TimeMailModel]!
    var diaries:[DiaryModel]!
}

class SyncService:NSNotificationCenter
{
    static var sharedInstance = {
        return SyncService()
    }()
    
    //MARK: alarm diary sync
    var remindSyncInterval:SyncAlarmInterval{
        get{
            let setting = NSUserDefaults.standardUserDefaults().integerForKey("remindSyncInterval")
            return SyncAlarmInterval(rawValue: setting)!
        }
        
        set{
            NSUserDefaults.standardUserDefaults().setInteger(newValue.rawValue, forKey: "remindSyncInterval")
        }
    }
    
    var isRemindSyncNow:Bool{
        if abs(lastSyncDate.totalDaysSinceNow) > 0
        {
            switch remindSyncInterval
            {
            case .oneMonth:
                return NSDate().dayOfDate == 1
            case .oneWeek:
                return NSDate().weekDayOfDate == 0
            default:break
            }
        }
        return false
    }
    
    //MARK: status
    static let syncStatusChanged = "syncStatusChanged"
    
    private(set) var syncStatus:SyncDiariesStatus = .CheckingiCloud{
        didSet{
            self.postNotificationName(SyncService.syncStatusChanged, object: self)
        }
    }
    
    private(set) var lastSyncDate:NSDate{
        get{
            if let date = NSUserDefaults.standardUserDefaults().objectForKey("lastSyncDate") as? NSDate
            {
                return date
            }else{
                let date = NSDate()
                NSUserDefaults.standardUserDefaults().setObject(date, forKey: "lastSyncDate")
                return date
            }
        }
        
        set{
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "lastSyncDate")
        }
    }
    
    private var lockFile:LockFileModel!
    func initStatus()
    {
        syncStatus = .CheckingiCloud
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            let icloud = iCloudExtension.defaultInstance.iCloudManager
            if icloud.checkCloudAvailability(){
                if icloud.doesFileExistInCloud(LockFileName)
                {
                    icloud.retrieveCloudDocumentWithName(LockFileName, completion: { (doc, data, error) -> Void in
                        if error == nil
                        {
                            doc.closeWithCompletionHandler(nil)
                            let lockFileJson = String(data: data, encoding: NSUTF8StringEncoding)
                            self.lockFile = LockFileModel(json: lockFileJson)
                            self.updateSyncStatus()
                        }else
                        {
                            self.syncStatus = .iCloudUnavailable
                        }
                        
                    })
                }else
                {
                    self.lockFile = LockFileModel()
                    self.updateSyncStatus()
                }
            }else
            {
                self.syncStatus = .iCloudUnavailable
            }
        }
    }
    
    func sync()
    {
        syncStatus = .Syncing
        syncTime = NSDate().timeIntervalSince1970
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            self.syncingState == 0
            self.fetchFromiCloud()
            self.sendLocalToiCloud()
        }
    }
    
    private func updateSyncStatus()
    {
        self.syncStatus = (needFetch() || needSend()) ? .NeedToSync : .SyncUpToDate
    }
    
    private func needFetch() -> Bool
    {
        
        let serverNewest = self.lockFile.syncDates.last?.doubleValue ?? 0
        let lastetFetch = self.lastetFetchServerDate?.timeIntervalSince1970 ?? 0
        if IntMax(lastetFetch) < IntMax(serverNewest)
        {
            return true
        }else{
            return false
        }
    }
    
    private func needSend() -> Bool
    {
        let serverNewest = IntMax(self.lockFile.syncDates.last?.doubleValue ?? 0)
        let newDiary = IntMax(DiaryService.sharedInstance.newestDiaryDateTimeInterval)
        let newMail = IntMax(TimeMailService.sharedInstance.newestTimeMailDateTimeInterval)
        return newDiary > serverNewest || newMail > serverNewest
    }
    
    //MARK: sync
    private var syncTime:NSTimeInterval = 0
    private let syncingStateLock = NSRecursiveLock()
    private var syncingState = 0{
        didSet{
            //magic number *_*||
            switch syncingState
            {
            case 0,1,2,4,8:break
            case 5:syncStatus = .SyncUpToDate
            default:syncStatus = .SyncError
            }
        }
    }
    
    //MARK: fetch iCloud files
    enum FetchingSyncFileStatus:Int
    {
        case Fetching = 0
        case Fetched = 1
        case Failed = 2
    }
    private var fetchingSyncFiles = [String:(status:FetchingSyncFileStatus,syncFile:SyncFileModel!)]()
    private var fetchingSyncFilesQueue = [String]()
    
    private var lastetFetchServerDate:NSDate!{
        get{
            if let date = NSUserDefaults.standardUserDefaults().objectForKey(LastestFetchServerDateKey) as? NSDate
            {
                return date
            }else
            {
                return nil
            }
        }
        set{
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: LastestFetchServerDateKey)
        }
    }
    
    //result
    private var fetchedDiaries = [DiaryModel]()
    private var fetchedTimeMails = [TimeMailModel]()
    
    private func fetchFromiCloud()
    {
        fetchingSyncFilesQueue.removeAll()
        let lastSyncTime = self.lastetFetchServerDate?.timeIntervalSince1970 ?? 0
        for var i = self.lockFile.syncDates.count - 1;  i >= 0; i--
        {
            let date = self.lockFile.syncDates[i]
            if lastSyncTime < date.doubleValue
            {
                fetchingSyncFilesQueue.append(self.lockFile.syncFiles[i])
            }
        }
        fetchNextSyncFile(0)
    }
    
    private func fetchNextSyncFile(fileIndex:Int)
    {
        if fileIndex >= fetchingSyncFilesQueue.count
        {
            mergeFetchedSyncFile()
            return
        }
        let file = fetchingSyncFilesQueue[fileIndex]
        if let fetching = fetchingSyncFiles[file]
        {
            if fetching.status == .Fetched && fetching.syncFile != nil
            {
                fetchNextSyncFile(fileIndex + 1)
                return
            }
        }
        fetchingSyncFiles[file] = (status:.Fetching,syncFile:nil)
        let icloud = iCloudExtension.defaultInstance.iCloudManager
        icloud.retrieveCloudDocumentWithName(file) { (doc, docData, error) -> Void in
            if error == nil
            {
                let syncFileJson = String(data: docData, encoding: NSUTF8StringEncoding)
                let syncFile = SyncFileModel(json: syncFileJson)
                self.fetchingSyncFiles[file]!.status = .Fetched
                self.fetchingSyncFiles[file]!.syncFile = syncFile
            }else
            {
                self.fetchingSyncFiles[file]!.status = .Failed
            }
            self.fetchNextSyncFile(fileIndex + 1)
        }
    }
    
    private func mergeFetchedSyncFile()
    {
        fetchedDiaries.removeAll()
        fetchedTimeMails.removeAll()
        var allFetched:Bool = true
        for sf in self.fetchingSyncFilesQueue
        {
            if let fetching = self.fetchingSyncFiles[sf]
            {
                if fetching.status == .Fetched && fetching.syncFile != nil
                {
                    fetchedDiaries.appendContentsOf(fetching.syncFile.diaries)
                    fetchedTimeMails.appendContentsOf(fetching.syncFile.mails)
                    continue
                }
            }
            allFetched = false
            break
        }
        if allFetched
        {
            self.saveFetchingSyncModels()
        }
        syncingStateLock.lock()
        syncingState = syncingState + (allFetched ? 1 : 2)
        syncingStateLock.unlock()
    }
    
    private func saveFetchingSyncModels()
    {
        DiaryModel.saveObjectOfArray(fetchedDiaries)
        DiaryModel.saveObjectOfArray(fetchedTimeMails)
        PersistentManager.sharedInstance.saveAll()
        self.lastetFetchServerDate = NSDate(timeIntervalSince1970: self.syncTime)
    }
    
    //MARK: send local files
    private func sendLocalToiCloud()
    {
        let lastSyncTime = self.lockFile.syncDates.last?.doubleValue ?? 0
        let newSyncFileModel = SyncFileModel()
        DiaryService.sharedInstance.getAllDiaries({ (diaries) -> Void in
            newSyncFileModel.diaries = diaries.filter{$0.lastModifiedTime.doubleValue > lastSyncTime}
            TimeMailService.sharedInstance.getAllTimeMail({ (mails) -> Void in
                newSyncFileModel.mails = mails.filter{$0.lastModifiedTime.doubleValue > lastSyncTime}
                
                if newSyncFileModel.diaries.count > 0 || newSyncFileModel.mails.count > 0
                {
                    self.saveSyncFile(newSyncFileModel)
                }else
                {
                    self.syncingStateLock.lock()
                    self.syncingState = self.syncingState + 4
                    self.syncingStateLock.unlock()
                }
            })
        })
    }
    
    private func saveSyncFile(newSyncFileModel:SyncFileModel)
    {
        let newSyncFile = "sync_file_\(IntMax(syncTime))"
        
        //if fetch task is failed and send task is success,add this to avoid restarted task fetch this send task model
        let candy = SyncFileModel()
        candy.diaries = [DiaryModel]()
        candy.mails = [TimeMailModel]()
        fetchingSyncFiles[newSyncFile] = (status:FetchingSyncFileStatus.Fetched,candy)
        
        let syncFileJson = newSyncFileModel.toJsonString()
        
        let data = syncFileJson.toUTF8EncodingData()
        let icloud = iCloudExtension.defaultInstance.iCloudManager
        icloud.saveAndCloseDocumentWithName(newSyncFile, withContent: data, completion: { (doc, docData, error) -> Void in
            if error == nil
            {
                let newLockFile = LockFileModel()
                newLockFile.syncDates = self.lockFile.syncDates.map{$0}
                newLockFile.syncFiles = self.lockFile.syncFiles.map{$0}
                newLockFile.syncDates.append(self.syncTime)
                newLockFile.syncFiles.append(newSyncFile)
                self.saveLockFile(newLockFile)
                doc.closeWithCompletionHandler(nil)
            }else
            {
                self.syncingStateLock.lock()
                self.syncingState = self.syncingState + 8
                self.syncingStateLock.unlock()
            }
        })
    }
    
    private func saveLockFile(newLockFileModel:LockFileModel)
    {
        let lockFileJson = newLockFileModel.toJsonString()
        
        let data = lockFileJson.toUTF8EncodingData()
        let icloud = iCloudExtension.defaultInstance.iCloudManager
        icloud.saveAndCloseDocumentWithName(LockFileName, withContent: data) { (doc, docData, err) -> Void in
            if err == nil
            {
                doc.closeWithCompletionHandler(nil)
                self.lockFile = newLockFileModel
            }
            self.syncingStateLock.lock()
            self.syncingState = self.syncingState + (err == nil ? 4 : 8)
            self.syncingStateLock.unlock()
            self.lastSyncDate = NSDate()
        }
    }
    
}
