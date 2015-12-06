//
//  TimeMailService.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/7.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import Foundation

class TimeMailService: NSNotificationCenter
{
    static var sharedInstance = {
        return TimeMailService()
    }()
    
    var notReadMailCount:Int{
        return 0
    }
}