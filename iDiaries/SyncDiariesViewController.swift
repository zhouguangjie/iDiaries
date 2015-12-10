//
//  SyncDiariesViewController.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/9.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import Foundation
import EVReflection

//MARK:Sync Status
enum SyncDiariesStatus:String
{
    case CheckingiCloud = "ICLOUD_STATUS_CHECKING"
    case iCloudUnavailable = "ICLOUD_STATUS_UNAVAILABLE"
    case Syncing = "SYNCING"
    case SyncUpToDate = "SYNC_UP_TO_DATE"
    case NeedToSync = "NEED_TO_SYNC"
    case SyncError = "SYNC_ERROR"
}

let SyncFileVersion = "1"
let LockFileVersion = "1"
let LockFileName = "idiaries.lock"
let LastestFetchServerDateKey = "idiariesLastestFetchServerDate"

//MARK: - SyncDiariesViewController
class SyncDiariesViewController: UIViewController
{
    @IBOutlet weak var syncStatusLabel: UILabel!
    @IBOutlet weak var syncIndicator: UIActivityIndicatorView!
    @IBOutlet weak var syncButton: UIButton!
    
    private var syncStatus:SyncDiariesStatus = .CheckingiCloud{
        didSet{
            if syncIndicator != nil && syncButton != nil && syncStatusLabel != nil{
                refreshStatus()
            }
        }
    }
    
    private func refreshStatus()
    {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.syncStatusLabel.text = NSLocalizedString(self.syncStatus.rawValue, comment: "")
            self.syncIndicator.startAnimating()
            self.syncIndicator.hidden = (self.syncStatus != .CheckingiCloud && self.syncStatus != .Syncing)
            self.syncButton.hidden = (self.syncStatus != .NeedToSync && self.syncStatus != .SyncError)
        }
    }
    
    //MARK: Life process
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshStatus()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidLoad()
        initStatus()
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
    
    //MARK: status
    
    var lockFile:LockFileModel!
    private func initStatus()
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
    var syncTime:NSTimeInterval = 0
    let syncingStateLock = NSRecursiveLock()
    var syncingState = 0{
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
    
    @IBAction func sync(sender: AnyObject)
    {
        syncStatus = .Syncing
        syncTime = NSDate().timeIntervalSince1970
        print("sync time:\(syncTime)")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            self.syncingState == 0
            self.fetchFromiCloud()
            self.sendLocalToiCloud()
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
    var fetchedDiaries = [DiaryModel]()
    var fetchedTimeMails = [TimeMailModel]()
    
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
        DiaryService.sharedInstance.getAllDailies({ (diaries) -> Void in
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
        }
    }
    
    //MARK: show controller
    static func showSyncDiariesViewController(navController:UINavigationController)
    {
        let brController = instanceFromStoryBoard("Main", identifier: "SyncDiariesViewController")
        navController.pushViewController(brController, animated: true)
    }
}
