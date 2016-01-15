//
//  DailyMarksConfig.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/3.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import Foundation

typealias MarkStruct = (id:Int,name:String,emoji:String!,info:AnyObject!)

let WeatherMarks:[MarkStruct] =
[
    (id:10000,name:"Sunny",emoji:"☀️",info:nil),
    (id:10001,name:"Cloudy",emoji:"☁️",info:nil),
    (id:10002,name:"Rainy",emoji:"🌧",info:nil),
    (id:10003,name:"Snowy",emoji:"❄️",info:nil),
    (id:10004,name:"Thunder",emoji:"⚡️",info:nil),
    (id:10005,name:"Windy",emoji:"🌪",info:nil),
    (id:10006,name:"Overcast",emoji:"⛅️",info:nil)
]

let MoodMarks:[MarkStruct] =
[
    (id:20000,name:"Happy",emoji:"😄",info:98.0),
    (id:20001,name:"Delightful",emoji:"😀",info:83.0),
    (id:20002,name:"Pleasant",emoji:"😃",info:76.0),
    (id:20003,name:"Sad",emoji:"😔",info:20.0),
    (id:20004,name:"Dysphoria",emoji:"😫",info:30.0),
    (id:20005,name:"Anger",emoji:"😡",info:60.0),
    (id:20006,name:"Fear",emoji:"😨",info:40.0),
    (id:20007,name:"Normal",emoji:"🙂",info:67.0)
]

let DaySummaryMarks:[MarkStruct] =
[
    (id:30000,name:"Beautiful Day",emoji:"",info:nil),
    (id:30001,name:"Funny Day",emoji:"",info:nil),
    (id:30002,name:"Boring Day",emoji:"",info:nil),
    (id:30003,name:"Full Day",emoji:"",info:nil),
    (id:30004,name:"Leisure Day",emoji:"",info:nil),
    (id:30005,name:"Busy Day",emoji:"",info:nil),
    (id:30006,name:"Routine Day",emoji:"",info:nil),
    (id:30007,name:"Unforgettable Day",emoji:"",info:nil),
    (id:30008,name:"Meaningful Day",emoji:"",info:nil),
    (id:30009,name:"Bad Day",emoji:"",info:nil),
    (id:30010,name:"Good Day",emoji:"",info:nil),
    (id:30011,name:"Excited Day",emoji:"",info:nil)
]

typealias TypedMarks = (markType:String,marks:[MarkStruct])

let AllDiaryMarks:[TypedMarks] =
[
    (markType:"Weather",marks:WeatherMarks),
    (markType:"Mood",marks:MoodMarks),
    (markType:"DaySummary",marks:DaySummaryMarks)
]

let AllDiaryMarksMap:[Int:MarkStruct] = {
   var marksMap = [Int:MarkStruct]()
    
    for tm in AllDiaryMarks
    {
        for m in tm.marks
        {
            marksMap[m.id] = m
        }
    }
    return marksMap
}()

let AllDiaryMarksNameMap:[String:Int] = {
    var map = [String:Int]()
    
    for (key,value) in AllDiaryMarksMap
    {
        map[value.name] = key
    }
    
    return map
}()

func getDiaryMark(markId:String) -> MarkStruct?
{
    if let index = Int(markId)
    {
        return AllDiaryMarksMap[index]
    }else if let index = AllDiaryMarksNameMap[markId]
    {
        return AllDiaryMarksMap[index]
    }else if markId == "Thundering"
    {
        return AllDiaryMarksMap[10004]
    }else
    {
        return nil
    }
}