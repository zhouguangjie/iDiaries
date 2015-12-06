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
    private var textContentCell:NewDiaryTextContentCell!
    private var remindCell:NewDiaryRemindFutureCell!
    private var saveCell:NewDiarySaveCell!
    
    var newDiaryCellsCount:Int{
        return 7
    }
    
    func saveNewDiary()
    {
        let dm = DiaryModel()
        dm.diaryId = IdUtil.generateUniqueId()
        dm.dateTime = dateCell.diaryDate.toDateTimeString()
        dm.weathers = weatherCell.selectedMarks
        dm.moods = moodCell.selectedMarks
        dm.summary = summaryCell.selectedMarks
        dm.mainContent = textContentCell.mainContent
        dm.diaryMarked = textContentCell.isMarkedDiary
        dm.diaryType = DiaryType.Normal.rawValue
        DiaryService.sharedInstance.addDiary(dm)
        
        weatherCell.refresh()
        moodCell.refresh()
        summaryCell.refresh()
        textContentCell.clearContent()
        textContentCell.isMarkedDiary = false
        
        if let futureReviewTime = remindCell.futureReviewTime
        {
            let ftmsgModel = TimeMailModel()
            ftmsgModel.futureMsgId = IdUtil.generateUniqueId()
            let now = NSDate()
            let msgFormat = NSLocalizedString("PastRemindMessageFormat", comment: "")
            let msg = String(format: msgFormat, now.toLocalDateTimeString())
            ftmsgModel.msgContent = msg
            ftmsgModel.mailReceiveDateTime = futureReviewTime.toLocalDateTimeString()
            ftmsgModel.diary = dm
            ftmsgModel.sendMailTime = NSDate().toLocalDateTimeString()
            DiaryService.sharedInstance.addFutureMessage(ftmsgModel)
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
            }else{
                mcell = markCells[markIndex]
            }
            cell = mcell
            if mcell.marksCollectionView.contentSize.height > markCellHeight[markIndex]
            {
                markCellHeight[markIndex] = mcell.marksCollectionView.contentSize.height
            }
            
        case 4:
            textContentCell = textContentCell ?? tableView.dequeueReusableCellWithIdentifier(NewDiaryTextContentCell.reuseId) as! NewDiaryTextContentCell
            cell = textContentCell
        case 5:
            remindCell = remindCell ?? tableView.dequeueReusableCellWithIdentifier(NewDiaryRemindFutureCell.reuseId) as! NewDiaryRemindFutureCell
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
}