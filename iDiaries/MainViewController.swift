//
//  ViewController.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/2.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import UIKit
import KKGestureLockView
import MJRefresh

enum ViewControllerMode
{
    case NewDiaryMode
    case DiaryListMode
}

extension String
{
    func localizedString() -> String{
        return NSLocalizedString(self, comment: "")
    }
}

let SegueShowTimeMailController = "ShowTimeMailController"
let SegueShowEditView = "ShowEditView"
let SegueShowUserSetting = "ShowUserSettingController"
let SegueShowDairyDetailViewController = "ShowDairyDetailViewController"
let SegueShowMoodReportViewController = "ShowMoodReportViewController"

let LAUNCH_TIMES_KEY = "LAUNCH_TIMES"


//MARK:ViewController

class MainViewController: UITableViewController, KKGestureLockViewDelegate{
    
    private(set) static var instance:MainViewController!
    
    @IBOutlet weak var reportBarItem: UIBarButtonItem!{
        didSet{
            reportBarItem.badgeBGColor = UIColor.orangeColor()
            reportBarItem.badge.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var timeMailBarItem: UIBarButtonItem!{
        didSet{
            timeMailBarItem.badgeBGColor = UIColor.orangeColor()
            timeMailBarItem.badge.layer.cornerRadius = 10
            
        }
    }
    var mode:ViewControllerMode = .NewDiaryMode{
        didSet{
            if tableView != nil
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.updateTableViewHeader()
                    self.updateTableViewFooter()
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    private let diaryShot:UIImageView = UIImageView(image: UIImage(named: "diary_shot"))
    
    //MARK: life process
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        MainViewController.instance = self
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 48;
        updateTableViewHeader()
        initDiaryShot()
        self.tableView.reloadData()
        self.tableView.tableFooterView = UIView()
        let times = NSUserDefaults.standardUserDefaults().integerForKey(LAUNCH_TIMES_KEY)
        NSUserDefaults.standardUserDefaults().setInteger(times + 1, forKey: LAUNCH_TIMES_KEY)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        changeNavigationBarColor()
        MobClick.beginLogPageView("ViewController")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        MobClick.endLogPageView("ViewController")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refreshDiaryView()
    }
    
    private func refreshDiaryView()
    {
        if mode == .NewDiaryMode
        {
            self.tableView.reloadData()
            ServiceContainer.getTimeMailService().refreshTimeMailBox { () -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.timeMailBarItem.badgeValue = "\(ServiceContainer.getTimeMailService().notReadMailCount)"
                })
            }
            self.reportBarItem.badgeValue = isThisMonthNotReadReport ? "1" : "0"
            sync()
        }
    }
    
    private var isThisMonthNotReadReport:Bool{
        let now = NSDate()
        let nowMonths = now.yearOfDate * 12 + now.monthOfDate
        let month = NSUserDefaults.standardUserDefaults().integerForKey("LAST_READ_MOOD_REPORT_MONTH")
        return month < nowMonths
    }
    
    private func setThisMonthReadReport()
    {
        let now = NSDate()
        let nowMonths = now.yearOfDate * 12 + now.monthOfDate
        NSUserDefaults.standardUserDefaults().setInteger(nowMonths, forKey: "LAST_READ_MOOD_REPORT_MONTH")
    }
    
    private func sync()
    {
        if ServiceContainer.getSyncService().isRemindSyncNow
        {
            let date = ServiceContainer.getSyncService().lastSyncDate
            let msgFormat = NSLocalizedString("NOT_SYNC_DAYS", comment: "")
            let msg = String(format: msgFormat, "\(abs(date.totalDaysSinceNow))")
            let alert = UIAlertController(title: NSLocalizedString("SYNC", comment: ""), message: msg, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("REMIND_SYNC_NEXT_TIME", comment: ""), style: .Default, handler: { (action) -> Void in
                ServiceContainer.getSyncService().remindSyncAfterDay = NSDate().totalDaysSince1970
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("DONT_REMIND_SYNC", comment: ""), style: .Default, handler: { (action) -> Void in
                ServiceContainer.getSyncService().remindSyncInterval = .noAlarm
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("SYNC_NOW", comment: ""), style: .Default, handler: { (action) -> Void in
                ServiceContainer.getSyncService().remindSyncAfterDay = NSDate().totalDaysSince1970
                SyncDiariesViewController.showSyncDiariesViewController(self.navigationController!)
            }))
            showAlert(self, alertController: alert)
        }
    }
    
    private func initDiaryShot()
    {
        let height:CGFloat = 196
        let width:CGFloat = 96
        diaryShot.frame = CGRectMake((self.view.frame.width - width)/2, -1000, width, height)
        self.view.addSubview(diaryShot)
    }

    private func animationSaveDiary()
    {
        let startPos = CGPointMake(diaryShot.frame.origin.x + diaryShot.frame.width/2, self.view.frame.height - 72)
        UIAnimationHelper.flyToTopForView(startPos,view: diaryShot)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func updateTableViewHeader()
    {
        let imageName = mode == .DiaryListMode ? "new_diary" : "diary"
        tableView.separatorStyle = mode == .DiaryListMode ? .SingleLine : .None
        let image = UIImage(named: imageName)!
        let header = MJRefreshGifHeader { () -> Void in
            self.switchDiaryMode()
            self.tableView.mj_header.endRefreshing()
        }
        header.lastUpdatedTimeLabel?.hidden = true
        header.stateLabel?.hidden = true
        header.setImages([image], forState: .Idle)
        tableView.mj_header = header
    }
    
    private func updateTableViewFooter()
    {
        if mode == .DiaryListMode && DiaryListManager.sharedInstance.diaryListItemCount == 0
        {
            let footer = NothingViewFooter.instanceFromXib()
            footer.messageLabel.text = NSLocalizedString("NO_DIARY_HERE", comment: "")
            footer.frame = tableView.bounds
            tableView.tableFooterView = footer
        }else
        {
            tableView.tableFooterView = UIView()
        }
    }
    
    private func openDiaries()
    {
        let hud = self.showActivityHud()
        self.navigationItem.title = "MY_DIARIES".localizedString()
        DiaryListManager.sharedInstance.refreshDiary({ () -> Void in
            hud.hideAsync(true)
            self.mode = .DiaryListMode
        })
    }
    
    private func switchDiaryMode()
    {
        if mode == .NewDiaryMode
        {
            if DiaryListManager.sharedInstance.isLocked
            {
                if ServiceContainer.getDiaryService().hasPassword()
                {
                    PasswordLocker.showValidateLocker(self,useTouchId: UserSetting.isSettingEnable("USE_TOUCH_ID")){
                        DiaryListManager.sharedInstance.unlockDiary()
                        self.openDiaries()
                    }
                }else
                {
                    PasswordLocker.showSetPasswordLocker(self){ newPsw in
                        DiaryListManager.sharedInstance.unlockDiary()
                        self.openDiaries()
                    }
                }
            }else
            {
                openDiaries()
            }
            
        }else
        {
            self.mode = .NewDiaryMode
            if let diaryDate = NewDiaryCellManager.sharedInstance.dateCell?.diaryDate
            {
                updateDiaryDateTitle(diaryDate)
            }
        }
    }
    
    func updateDiaryDateTitle(diaryDate:NSDate)
    {
        self.navigationItem.title = "NEW_DIARY".localizedString()
        /*
        let formatter = NSDateFormatter()
        formatter.dateFormat = "NEW_DIARY_DATE_TITILE_FORMAT".localizedString()
        formatter.timeZone = NSTimeZone.systemTimeZone()
        self.navigationItem.title = formatter.stringFromDate(diaryDate)
        NSTimer.scheduledTimerWithTimeInterval(1.2, target: self, selector: #selector(MainViewController.onDisplayDateTitleEnd(_:)), userInfo: nil, repeats: false)
         */
    }
    
    /*
    func onDisplayDateTitleEnd(_:NSTimer) {
        if mode == .NewDiaryMode {
            self.navigationItem.title = "NEW_DIARY".localizedString()
        }
    }
     */
    
    func saveDiary() {
        if let notReady = NewDiaryCellManager.sharedInstance.notReadyForSaveCell()
        {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: notReady.index, inSection: 0), atScrollPosition: .None, animated: true)
            notReady.cell.shakeAnimationForView(7)
            SystemSoundHelper.vibrate()
        }else
        {
            NewDiaryCellManager.sharedInstance.saveNewDiary()
            animationSaveDiary()
            SystemSoundHelper.playSound(1001)
        }
    }
    
    //MARK: actions
    private func validateToShowSegue(segue:String)
    {
        if DiaryListManager.sharedInstance.isLocked
        {
            if ServiceContainer.getDiaryService().hasPassword()
            {
                PasswordLocker.showValidateLocker(self,useTouchId: UserSetting.isSettingEnable("USE_TOUCH_ID")){
                    DiaryListManager.sharedInstance.unlockDiary()
                    self.performSegueWithIdentifier(segue, sender: self)
                }
            }else
            {
                PasswordLocker.showSetPasswordLocker(self){ newPsw in
                    DiaryListManager.sharedInstance.unlockDiary()
                    self.performSegueWithIdentifier(segue, sender: self)
                }
            }
        }else
        {
            self.performSegueWithIdentifier(segue, sender: self)
        }
    }
    
    @IBAction func moodReportClick(sender: AnyObject)
    {
        validateToShowSegue(SegueShowMoodReportViewController)
    }
    
    @IBAction func timeMailClick(sender: AnyObject) {
        
        validateToShowSegue(SegueShowTimeMailController)
    }
    
    @IBAction func userSettingClick(sender: AnyObject)
    {
        validateToShowSegue(SegueShowUserSetting)
    }
    
    //MARK:Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.identifier == SegueShowEditView
        {
            let vc = segue.destinationViewController as! EditMainContentViewController
            vc.mainContentCell = sender as! NewDiaryTextContentCell
            
        }else if segue.identifier == SegueShowDairyDetailViewController
        {
            let vc = segue.destinationViewController as! DiaryDetailViewController
            vc.diary = (sender as! DiaryContentCell).diary
        }else if segue.identifier == SegueShowMoodReportViewController
        {
            self.setThisMonthReadReport()
        }
    }
    
    //MARK:TableView delegate
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mode
        {
        case .NewDiaryMode:
            return NewDiaryCellManager.sharedInstance.newDiaryCellsCount
        case .DiaryListMode:
            return DiaryListManager.sharedInstance.diaryListItemCount
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if mode == .NewDiaryMode
        {
            let cell = NewDiaryCellManager.sharedInstance.getNewDiaryCell(self, row: indexPath.row)
            return cell
        }else
        {
            let contentCell = tableView.dequeueReusableCellWithIdentifier(DiaryContentCell.reuseId,forIndexPath: indexPath) as! DiaryContentCell
            contentCell.rootController = self
            contentCell.diary = DiaryListManager.sharedInstance.diaries[indexPath.row]
            contentCell.update()
            return contentCell
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if mode == .NewDiaryMode
        {
            return NewDiaryCellManager.sharedInstance.getCellHeight(indexPath.row)
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if mode == .DiaryListMode
        {
            return .Delete
        }
        return .None
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let diary = DiaryListManager.sharedInstance.removeDiary(indexPath.row)
        ServiceContainer.getDiaryService().deleteDiary(diary)
        tableView.reloadData()
    }
 
}

