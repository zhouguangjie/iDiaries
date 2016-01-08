//
//  DailyMarksConfig.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/3.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import Foundation

typealias MarkStruct = (name:String,emoji:String!)

let WeatherMarks:[MarkStruct] =
[
    (name:"Sunny",emoji:"☀️"),
    (name:"Cloudy",emoji:"☁️"),
    (name:"Rainy",emoji:"🌧"),
    (name:"Snowy",emoji:"❄️"),
    (name:"Thunder",emoji:"⚡️"),
    (name:"Windy",emoji:"🌪"),
    (name:"Overcast",emoji:"⛅️")
]

let MoodMarks:[MarkStruct] =
[
    (name:"Happy",emoji:"😄"),
    (name:"Delightful",emoji:"😀"),
    (name:"Pleasant",emoji:"😃"),
    (name:"Sad",emoji:"😔"),
    (name:"Dysphoria",emoji:"😫"),
    (name:"Anger",emoji:"😡"),
    (name:"Fear",emoji:"😨"),
    (name:"Normal",emoji:"🙂")
]

let DaySummaryMarks:[MarkStruct] =
[
    (name:"Beautiful Day",emoji:""),
    (name:"Funny Day",emoji:""),
    (name:"Boring Day",emoji:""),
    (name:"Full Day",emoji:""),
    (name:"Leisure Day",emoji:""),
    (name:"Busy Day",emoji:""),
    (name:"Routine Day",emoji:""),
    (name:"Unforgettable Day",emoji:""),
    (name:"Meaningful Day",emoji:""),
    (name:"Bad Day",emoji:""),
    (name:"Good Day",emoji:""),
    (name:"Excited Day",emoji:"")
    
]

typealias TypedMarks = (markType:String,marks:[MarkStruct])

let AllDiaryMarks:[TypedMarks] =
[
    (markType:"Weather",marks:WeatherMarks),
    (markType:"Mood",marks:MoodMarks),
    (markType:"DaySummary",marks:DaySummaryMarks)
]