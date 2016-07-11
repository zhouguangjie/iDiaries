//
//  iDiariesConfig.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/8.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import Foundation

class iDiariesConfig
{
    static let appTitle = NSLocalizedString("APP_TITLE", comment: "")
    static let appName = "iDiaries"
    static let appStoreId = "1065482853"
    static let officalMail = "cplover@live.cn"
    
    static let umengAppkey = "56738bef67e58e976e001370"
    
    static var appVersion:String{
        if let infoDic = NSBundle.mainBundle().infoDictionary
        {
            let version = infoDic["CFBundleShortVersionString"] as! String
            return version
        }
        return "1.0"
    }
    
    static let sharelink = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=1065482853"
}