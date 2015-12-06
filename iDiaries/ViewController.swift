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

let SegueShowTimeMailController = "ShowTimeMailController"
let SegueShowEditView = "ShowEditView"

class ViewController: UITableViewController, KKGestureLockViewDelegate{
    var mode:ViewControllerMode = .NewDiaryMode{
        didSet{
            if tableView != nil
            {
                updateTableViewHeader()
            }
        }
    }
    
    private let diaryShot:UIImageView = UIImageView(image: UIImage(named: "diary_shot"))
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 48;
        navigationItem.rightBarButtonItem?.badgeBGColor = UIColor.orangeColor()
        navigationItem.rightBarButtonItem?.badge.layer.cornerRadius = 10
        updateTableViewHeader()
        initDiaryShot()
        DiaryListManager.sharedInstance.addObserver(self, selector: "diaryUnlocked:", name: DiaryListManager.DiaryUnlocked, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
        self.tableView.tableFooterView = UIView()
        initDiaryShot()
        self.navigationItem.rightBarButtonItem?.badgeValue = "\(TimeMailService.sharedInstance.notReadMailCount)"
    }
    
    func diaryUnlocked(a:NSNotification)
    {
        mode = .DiaryListMode
        tableView.reloadData()
    }
    
    private func initDiaryShot()
    {
        let height:CGFloat = 196
        let width:CGFloat = 96
        diaryShot.frame = CGRectMake((self.view.frame.width - width)/2, -1000, width, height)
        self.view.addSubview(diaryShot)
    }

    func animationSaveDiary()
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
            self.tableView.mj_header.endRefreshing()
            self.switchDiaryMode()
        }
        header.lastUpdatedTimeLabel?.hidden = true
        header.stateLabel?.hidden = true
        header.setImages([image], forState: .Idle)
        tableView.mj_header = header
    }
    
    private func switchDiaryMode()
    {
        if mode == .NewDiaryMode
        {
            if DiaryListManager.sharedInstance.isLocked
            {
                if DiaryService.sharedInstance.hasPassword()
                {
                    PasswordLocker.showValidateLocker(self)
                }else
                {
                    PasswordLocker.showSetPasswordLocker(self)
                }
            }else
            {
                mode = .DiaryListMode
                tableView.reloadData()
            }
            
        }else
        {
            mode = .NewDiaryMode
            tableView.reloadData()
        }
    }
    
    func saveDiary() {
        NewDiaryCellManager.sharedInstance.saveNewDiary()
    }
    
    func showLockView() -> LockViewController{
        let lockVC = LockViewController.instanceFromStoreboard()
        self.navigationController?.pushViewController(lockVC, animated: true)
        return lockVC
    }
    //MARK:Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueShowEditView
        {
            let vc = segue.destinationViewController as! EditMainContentViewController
            vc.mainContentCell = sender as! NewDiaryTextContentCell
            
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
            return NewDiaryCellManager.sharedInstance.getNewDiaryCell(self, row: indexPath.row)
        }else
        {
            let contentCell = tableView.dequeueReusableCellWithIdentifier(DiaryContentCell.reuseId,forIndexPath: indexPath) as! DiaryContentCell
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
        DiaryService.sharedInstance.deleteDiary(diary)
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if mode == .DiaryListMode && DiaryListManager.sharedInstance.diaryListItemCount == 0
        {
            return tableView.frame.height
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if mode == .DiaryListMode && DiaryListManager.sharedInstance.diaryListItemCount == 0
        {
            let footer = NothingViewFooter.instanceFromXib()
            footer.messageLabel.text = NSLocalizedString("NO_DIARY_HERE", comment: "")
            return footer
        }
        return nil
    }
}

