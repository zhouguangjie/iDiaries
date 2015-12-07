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
    
    private(set) var timeMails = [TimeMailModel]()
    
    var notReadMailCount:Int{
        return timeMails.filter{$0.read == false}.count
    }
    
    func refreshTimeMailBox(refreshedCallback:()->Void)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            let mails = PersistentManager.sharedInstance.getAllModel(TimeMailModel)
            self.timeMails.removeAll()
            let receivedMails = mails.filter{ $0.mailReceiveDateTime.dateTimeOfString.timeIntervalSinceNow > 0 }
            self.timeMails.appendContentsOf(receivedMails)
            refreshedCallback()
        }
        
    }
}