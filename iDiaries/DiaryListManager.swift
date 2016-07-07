//
//  DiaryList.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/5.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import Foundation
import UIKit

class DiaryListManager:NSNotificationCenter
{
    static let DiaryUnlocked = "DiaryUnlocked"
    static var sharedInstance:DiaryListManager = {
        return DiaryListManager()
    }()
    private(set) var isLocked:Bool = true
    private(set) var diaries = [DiaryModel]()
    func lockDiary()
    {
        isLocked = true
        diaries.removeAll()
    }
    
    func removeDiary(index:Int) -> DiaryModel
    {
        return diaries.removeAtIndex(index)
    }
    
    func unlockDiary()
    {
        isLocked = false
        self.postNotificationName(DiaryListManager.DiaryUnlocked, object: self)
    }
    
    func refreshDiary(updatedCallback:()->Void)
    {
        ServiceContainer.getDiaryService().getAllDiaries{ result in
            self.diaries = result
            updatedCallback()
        }
    }
    
    var diaryListItemCount:Int{
        return diaries.count
    }
}