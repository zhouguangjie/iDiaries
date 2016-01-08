//
//  NewDiaryManager.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/5.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import Foundation
import UIKit

class NewDiaryCellManager
{
    static var sharedInstance:NewDiaryCellManager = {
        return NewDiaryCellManager()
    }()
    
    private var markCellHeight:[CGFloat] = [0,0,0]
    private var markCells:[NewDiaryMarkCell!] = [nil,nil,nil]
    private let markCellsMultiSelection = [true,true,false]
    private var dateCell:NewDiaryDateCell!
    private var weatherCell:NewDiaryMarkCell!{
        return markCells[0]
    }
    private var moodCell:NewDiaryMarkCell!{
        return markCells[1]
    }
    private var summaryCell:NewDiaryMarkCell!{
        return markCells[2]
    }
    private var textContentCell:NewDiaryTextContentCell!{
        didSet{
            if oldValue == nil{
                self.returnForeground()
            }
        }
    }
    private var remindCell:NewDiarySendTimeMailCell!
    private var saveCell:NewDiarySaveCell!
    
    private func initMarkCellHeight(i:Int)
    {
        let height = NSUserDefaults.standardUserDefaults().doubleForKey("markCellHeight_\(i)")
        markCellHeight[i] = CGFloat(height)
    }
    
    private func storeMarkCellHeight(index:Int)
    {
        let height = Double(markCellHeight[index])
        NSUserDefaults.standardUserDefaults().setDouble(height, forKey: "markCellHeight_\(index)")
    }
    
    var newDiaryCellsCount:Int{
        return 7
    }
    
    func notReadyForSaveCell() -> (index:Int,cell:NewDiaryBaseCell)?
    {
        for var i:Int = 0 ;i < markCells.count; i++
        {
            let cell = markCells[i]!
            if cell.selectedMarks.count == 0
            {
                return (index:i + 1,cell:cell)
            }
        }
        return nil
    }
    
    func saveNewDiary()
    {
        let dm = DiaryModel()
        dm.diaryId = IdUtil.generateUniqueId()
        dm.dateTime = dateCell.diaryDate.timeIntervalSince1970
        dm.weathers = weatherCell.selectedMarks
        dm.moods = moodCell.selectedMarks
        dm.summary = summaryCell.selectedMarks
        dm.mainContent = textContentCell.mainContent
        dm.diaryMarked = textContentCell.isMarkedDiary
        dm.diaryType = DiaryType.Normal.rawValue
        DiaryService.sharedInstance.addDiary(dm)
        
        dateCell.resetDate()
        weatherCell.clearSelected()
        moodCell.clearSelected()
        summaryCell.clearSelected()
        textContentCell.clearContent()
        textContentCell.isMarkedDiary = false
        
        if let futureReviewTime = remindCell.futureReviewTime
        {
            let timeMail = TimeMailModel()
            timeMail.mailId = IdUtil.generateUniqueId()
            let now = NSDate()
            let msgFormat = NSLocalizedString("TimeMailMessageFormat", comment: "")
            let msg = String(format: msgFormat, now.toLocalDateTimeString())
            timeMail.msgContent = msg
            timeMail.mailReceiveDateTime = futureReviewTime.timeIntervalSince1970
            timeMail.diary = dm
            timeMail.sendMailTime = NSDate().timeIntervalSince1970
            TimeMailService.sharedInstance.addTimeMail(timeMail)
        }
        remindCell.setReviewDiaryTime(nil)
    }
    
    func getCellHeight(row:Int) -> CGFloat
    {
        if row > 0 && row <= 3
        {
            return markCellHeight[row - 1] + 18
        }
        return UITableViewAutomaticDimension
    }
    
    func getNewDiaryCell(rootController:ViewController,row:Int) -> NewDiaryBaseCell
    {
        var cell:NewDiaryBaseCell!
        let tableView = rootController.tableView
        switch row
        {
        case 0:
            dateCell = dateCell ?? tableView.dequeueReusableCellWithIdentifier(NewDiaryDateCell.reuseId) as! NewDiaryDateCell
            cell = dateCell
        case 1,2,3:
            let markIndex = row - 1
            var mcell:NewDiaryMarkCell!
            if markCells[markIndex] == nil{
                mcell = tableView.dequeueReusableCellWithIdentifier(NewDiaryMarkCell.reuseId) as! NewDiaryMarkCell
                self.markCells[markIndex] = mcell
                mcell.typedMarks = AllDiaryMarks[markIndex]
                mcell.marksCollectionView.allowsMultipleSelection = markCellsMultiSelection[markIndex]
                mcell.refresh()
                mcell.sizeToFit()
                initMarkCellHeight(markIndex)
            }else{
                mcell = markCells[markIndex]
            }
            cell = mcell
            
            if mcell.marksCollectionView.contentSize.height > markCellHeight[markIndex]
            {
                markCellHeight[markIndex] = mcell.marksCollectionView.contentSize.height
                storeMarkCellHeight(markIndex)
            }
            
        case 4:
            textContentCell = textContentCell ?? tableView.dequeueReusableCellWithIdentifier(NewDiaryTextContentCell.reuseId) as! NewDiaryTextContentCell
            cell = textContentCell
        case 5:
            remindCell = remindCell ?? tableView.dequeueReusableCellWithIdentifier(NewDiarySendTimeMailCell.reuseId) as! NewDiarySendTimeMailCell
            cell = remindCell
        case 6:
            saveCell = saveCell ?? tableView.dequeueReusableCellWithIdentifier(NewDiarySaveCell.reuseId) as! NewDiarySaveCell
            cell = saveCell
        default:
            break
        }
        cell.rootController = rootController
        return cell
    }
    
    //MARK: temperate
    var isNewDiaryNotNull:Bool{
        get{
            return moodCell.selectedMarks.count > 0 || weatherCell.selectedMarks.count > 0 || summaryCell.selectedMarks.count > 0 || String.isNullOrWhiteSpace(textContentCell.mainContent) == false
        }
    }
    
    func returnForeground()
    {
        if isNewDiaryNotNull == false
        {
            dateCell.resetDate()
        }
        
    }
}