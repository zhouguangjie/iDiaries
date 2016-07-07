//
//  SyncDiariesViewController.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/9.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import Foundation

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
    
        
    @IBAction func sync(sender: AnyObject)
    {
        ServiceContainer.getSyncService().sync()
    }
    
    private func refreshStatus()
    {
        let syncStatus = ServiceContainer.getSyncService().syncStatus
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.syncStatusLabel.text = NSLocalizedString(syncStatus.rawValue, comment: "")
            self.syncIndicator.startAnimating()
            self.syncIndicator.hidden = (syncStatus != .CheckingiCloud && syncStatus != .Syncing)
            self.syncButton.hidden = (syncStatus != .NeedToSync && syncStatus != .SyncError)
        }
    }
    
    //MARK: Life process
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshStatus()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidLoad()
        ServiceContainer.getSyncService().initStatus()
        MobClick.beginLogPageView("SyncView")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        ServiceContainer.getSyncService().addObserver(self, selector: #selector(SyncDiariesViewController.syncStatusChanged(_:)), name: SyncService.syncStatusChanged, object: nil)
        MobClick.endLogPageView("SyncView")
    }
    
    override func viewWillDisappear(animated: Bool) {
        ServiceContainer.getSyncService().removeObserver(self)
    }
    
    //MARK: notification
    func syncStatusChanged(_:AnyObject)
    {
        refreshStatus()
    }
     
    //MARK: show controller
    static func showSyncDiariesViewController(navController:UINavigationController)
    {
        let brController = instanceFromStoryBoard("Main", identifier: "SyncDiariesViewController")
        navController.pushViewController(brController, animated: true)
    }
}
