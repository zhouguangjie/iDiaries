//
//  ReportService.swift
//  iDiaries
//
//  Created by AlexChow on 16/1/13.
//  Copyright © 2016年 GStudio. All rights reserved.
//

import Foundation
import EVReflection

class Report
{
    var year:Int = 2015
    var month:Int = 1
    var diariesCount:Int = 0
    
    var moods:[(day:Int,mark:MarkStruct)]!
    var moodsMap:[Int:Int]!
}

class ReportService
{
    static var sharedInstance = {
        return ReportService()
    }()
    
    private(set) var allReports = [Report]()
    
    func refreshReports(allDiaries:[DiaryModel],callback:()->Void)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            self.allReports.removeAll()
            let diariesGroup = self.getDiariesOfMonthes(allDiaries)
            for t in diariesGroup
            {
                let report = self.releaseReport(t.year, month: t.month, diaries: t.diaries)
                self.allReports.append(report)
            }
            self.allReports.sortInPlace({ (a, b) -> Bool in
                let am = a.year * 12 + a.month
                let bm = b.year * 12 + b.month
                return am > bm
            })
            callback()
        }
    }
    
    private func getDiariesOfMonthes(diaries:[DiaryModel]) -> [(year:Int,month:Int,diaries:[DiaryModel])]
    {
        var monthDiaries = [String:NSMutableArray]()
        
        for diary in diaries
        {
            let date = NSDate(timeIntervalSince1970: diary.dateTime.doubleValue)
            let key = "\(date.yearOfDate)-\(date.monthOfDate)"
            
            if let arr = monthDiaries[key]
            {
                arr.addObject(diary)
            }else{
                monthDiaries[key] = NSMutableArray(array: [diary])
            }
        }
        
        var result = [(year:Int,month:Int,diaries:[DiaryModel])]()
        let now = NSDate()
        let nowYear = now.yearOfDate
        let nowMonth = now.monthOfDate
        for (key,diaries) in monthDiaries
        {
            let ym = key.split("-")
            let year = Int(ym[0])!
            let month = Int(ym[1])!
            if year == nowYear && month == nowMonth
            {
                continue
            }
            let arr = diaries.map{$0 as! DiaryModel}
            result.append((year,month,arr))
            
        }
        return result
    }
    
    private func releaseReport(year:Int,month:Int,diaries:[DiaryModel]) -> Report
    {
        let report = Report()
        report.year = year
        report.month = month
        report.diariesCount = diaries.count
        
        var moods = [(day:Int,mark:MarkStruct)]()
        var moodMap = [Int:Int]()
        
        for diary in diaries
        {
            for i in 0..<diary.moods.count
            {
                let m = diary.moods[i]
                let diaryDate = NSDate(timeIntervalSince1970: diary.dateTime.doubleValue)
                if let mood = getDiaryMark(m.markId)
                {
                    moods.append((diaryDate.dayOfDate,mood))
                    
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
        report.moods = moods
        report.moodsMap = moodMap
        return report
    }
}
