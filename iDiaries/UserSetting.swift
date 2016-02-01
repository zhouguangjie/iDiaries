//
//  UserSetting.swift
//  Bahamut
//
//  Created by AlexChow on 16/1/5.
//  Copyright © 2016年 GStudio. All rights reserved.
//

import Foundation

class UserSetting
{
    static var isAppstoreReviewing:Bool{
        get{
            return NSUserDefaults.standardUserDefaults().boolForKey("isAppstoreReviewId")
        }
        set{
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "isAppstoreReviewId")
        }
    }
    
    static let lastLoginAccountId:String = "user"
    
    static func getSettingKey(setting:String) -> String{
        return "\(UserSetting.lastLoginAccountId):\(setting)"
    }
    
    static func isSettingEnable(setting:String) -> Bool{
        return NSUserDefaults.standardUserDefaults().boolForKey(getSettingKey(setting))
    }
    
    static func setSetting(setting:String,enable:Bool)
    {
        NSUserDefaults.standardUserDefaults().setBool(enable, forKey: getSettingKey(setting))
    }
    
    static func enableSetting(setting:String)
    {
        setSetting(setting, enable: true)
    }
    
    static func disableSetting(setting:String)
    {
        setSetting(setting, enable: false)
    }
}