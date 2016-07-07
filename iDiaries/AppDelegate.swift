//
//  AppDelegate.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/2.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        configureLanguage()
        configureUmeng()
        configureNotification(application)
        return true
    }
    
    private func configureNotification(application: UIApplication)
    {
        let setting = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert,UIUserNotificationType.Sound,UIUserNotificationType.Badge], categories: nil)
        application.registerUserNotificationSettings(setting)
    }
    
    private func configureLanguage()
    {
        let langCode = NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode)!.debugDescription!
        if let langCodeStored = NSUserDefaults.standardUserDefaults().stringForKey("langCode")
        {
            if langCode != langCodeStored
            {
                NewDiaryCellManager.sharedInstance.resetMarkCellHeights()
            }
        }else
        {
            NewDiaryCellManager.sharedInstance.resetMarkCellHeights()
        }
        NSUserDefaults.standardUserDefaults().setObject(langCode, forKey: "langCode")
    }

    private func configureUmeng()
    {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            UMAnalyticsConfig.sharedInstance().appKey = iDiariesConfig.umengAppkey
            MobClick.setAppVersion(iDiariesConfig.appVersion)
            MobClick.setEncryptEnabled(true)
            MobClick.setLogEnabled(false)
            MobClick.startWithConfigure(UMAnalyticsConfig.sharedInstance())
        }
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        NSLog("LocalNotification")
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func application(application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        DiaryListManager.sharedInstance.lockDiary()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        NewDiaryCellManager.sharedInstance.returnForeground()
        if let c = MainViewController.instance
        {
            c.navigationController?.popToViewController(c, animated: true)
            c.mode = ViewControllerMode.NewDiaryMode
        }
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        application.applicationIconBadgeNumber = 0
        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
    }


}

