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
    case SyncedAtTime = "SYNCED_AT"
    case NoSyncBefore = "NO_SYNC_BEFORE"
    case SyncError = "SYNC_ERROR"
}

let SyncFileVersion = "1"
let LockFileVersion = "1"
let LockFileName = "idiaries.lock"

//MARK: - SyncDiariesViewController
class SyncDiariesViewController: UIViewController
{
    @IBOutlet weak var syncStatusLabel: UILabel!
    @IBOutlet weak var syncIndicator: UIActivityIndicatorView!
    @IBOutlet weak var syncButton: UIButton!
    
    private var syncAtDate:NSDate!
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
            if self.syncStatus == .SyncedAtTime
            {
                let format = NSLocalizedString(self.syncStatus.rawValue, comment: "")
                self.syncStatusLabel.text = String(format: format, self.syncAtDate.toLocalDateTimeString())
            }else
            {
                self.syncStatusLabel.text = NSLocalizedString(self.syncStatus.rawValue, comment: "")
            }
            
            self.syncIndicator.hidden = (self.syncStatus != .CheckingiCloud && self.syncStatus != .Syncing)
            
            self.syncButton.hidden = (self.syncStatus != .SyncedAtTime && self.syncStatus != .NoSyncBefore && self.syncStatus != .SyncError)
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
    
    //MARK: sync
    
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
                            let lockFileJson = String(data: data, encoding: NSUTF8StringEncoding)
                            self.lockFile = LockFileModel(json: lockFileJson)
                            if let lastSyncDate = self.lockFile.syncDates.last
                            {
                                self.syncAtDate =  NSDate(timeIntervalSince1970: lastSyncDate.doubleValue)
                                self.syncStatus = .SyncedAtTime
                            }else
                            {
                                self.syncStatus = .NoSyncBefore
                            }
                            doc.closeWithCompletionHandler(nil)
                        }else
                        {
                            self.syncStatus = .iCloudUnavailable
                        }
                        
                    })
                }else
                {
                    self.lockFile = LockFileModel()
                    self.syncStatus = .NoSyncBefore
                }
            }else
            {
                self.syncStatus = .iCloudUnavailable
            }
        }
    }
    
    @IBAction func sync(sender: AnyObject)
    {
        syncStatus = .Syncing
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            
            let lastSyncTime = self.syncAtDate?.timeIntervalSince1970 ?? 0
            self.startSync(lastSyncTime)
            
        }
    }
    
    
    
    private func startSync(lastSyncTime:NSTimeInterval)
    {
        fetchingSyncFilesQueue.removeAll()
        if self.lockFile.syncDates.count == 0
        {
            sendLocalToiCloud(lastSyncTime)
        }else
        {
            fetchFromiCloud(lastSyncTime)
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
    
    //result
    var fetchedDiaries = [DiaryModel]()
    var fetchedTimeMails = [TimeMailModel]()
    
    private func fetchFromiCloud(lastSyncTime:NSTimeInterval)
    {
        for i in self.lockFile.syncDates.count - 1 ... 0
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
            let lastSyncTime = self.syncAtDate?.timeIntervalSince1970 ?? 0
            self.sendLocalToiCloud(lastSyncTime)
        }else
        {
            self.syncStatus = .SyncError
        }
    }
    
    //MARK: send local files
    private func sendLocalToiCloud(lastSyncTime:NSTimeInterval)
    {
        let newSyncFileModel = SyncFileModel()
        DiaryService.sharedInstance.getAllDailies({ (diaries) -> Void in
            newSyncFileModel.diaries = diaries.filter{$0.dateTime.dateTimeOfString.timeIntervalSince1970 > lastSyncTime}
            TimeMailService.sharedInstance.getAllTimeMail({ (mails) -> Void in
                newSyncFileModel.mails = mails.filter{$0.sendMailTime.dateTimeOfString.timeIntervalSince1970 > lastSyncTime}
                
                if newSyncFileModel.diaries.count == 0 && newSyncFileModel.mails.count == 0
                {
                    self.syncStatus = .SyncUpToDate
                }else
                {
                    self.saveSyncFile(newSyncFileModel)
                }
            })
        })
    }
    
    private func saveSyncFile(newSyncFileModel:SyncFileModel)
    {
        let newSyncDate = NSDate()
        let newSyncFile = "sync_file_\(Int(newSyncDate.timeIntervalSince1970))"
        
        let syncFileJson = newSyncFileModel.toJsonString()
        
        let data = syncFileJson.toUTF8EncodingData()
        let icloud = iCloudExtension.defaultInstance.iCloudManager
        icloud.saveAndCloseDocumentWithName(newSyncFile, withContent: data, completion: { (doc, docData, error) -> Void in
            if error == nil
            {
                let newLockFile = LockFileModel()
                newLockFile.syncDates = self.lockFile.syncDates.map{$0}
                newLockFile.syncFiles = self.lockFile.syncFiles.map{$0}
                newLockFile.syncDates.append(newSyncDate.timeIntervalSince1970)
                newLockFile.syncFiles.append(newSyncFile)
                self.saveLockFile(newLockFile)
                doc.closeWithCompletionHandler(nil)
            }else
            {
                self.syncStatus = .SyncError
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
                self.saveFetchingSyncModels()
                self.lockFile = newLockFileModel
                self.syncFinished()
            }else{
                self.syncStatus = .SyncError
            }
        }
    }
    
    private func saveFetchingSyncModels()
    {
        DiaryModel.saveObjectOfArray(fetchedDiaries)
        DiaryModel.saveObjectOfArray(fetchedTimeMails)
    }
    
    private func syncFinished()
    {
        self.syncAtDate = NSDate(timeIntervalSince1970: self.lockFile.syncDates.last!.doubleValue)
        self.syncStatus = .SyncUpToDate
    }
    
    static func showSyncDiariesViewController(navController:UINavigationController)
    {
        let brController = instanceFromStoryBoard("Main", identifier: "SyncDiariesViewController")
        navController.pushViewController(brController, animated: true)
    }
}
