//
//  ReportService.swift
//  iDiaries
//
//  Created by AlexChow on 16/1/13.
//  Copyright © 2016年 GStudio. All rights reserved.
//

import Foundation
import EVReflection

class Report: BahamutObject
{
    override func getObjectUniqueIdValue() -> String {
        return "report:\(year)_\(month)"
    }
    var year:Int!
    var month:Int!
}

class ReportService
{
    static var sharedInstance = {
        return ReportService()
    }()
    
    func releaseReport(year:Int,month:Int,diaries:[DiaryModel]) -> Report
    {
        let report = Report()
        report.year = year
        report.month = month
        
        let onedaySec = 60 * 60 * 23
        var moods = [(time:Int,mark:MarkStruct)]()
        var moodMap = [Int:Int]()
        
        for diary in diaries
        {
            let interval = onedaySec / diary.moods.count
            let diaryDate = NSDate(timeIntervalSince1970: diary.dateTime.doubleValue)
            let startPoint = diaryDate.dayOfDate * 60 * 60 * 24
            for i in 0..<diary.moods.count
            {
                let m = diary.moods[i]
                if let mood = getDiaryMark(m.markId)
                {
                    let x = startPoint + interval * i
                    moods.append((x,mood))
                    
                    if let count = moodMap[mood.id]
                    {
                        moodMap[mood.id] = count + 1
                    }else
                    {
                        moodMap[mood.id] = 1
                    }
                }
            }
        }
        
        return report
    }
}
