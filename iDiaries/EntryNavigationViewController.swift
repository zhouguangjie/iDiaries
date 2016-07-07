//
//  EntryNavigationViewController.swift
//  iDiaries
//
//  Created by AlexChow on 16/7/5.
//  Copyright © 2016年 GStudio. All rights reserved.
//

import UIKit

class EntryNavigationViewController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let controller = UIViewController.instanceFromStoryBoard("LaunchScreen", identifier: "LaunchScreen")
        let launchScreen = controller.view
        launchScreen.frame = self.view.bounds
        self.view.addSubview(launchScreen)
        launchScreen.subviews.forEach { (v) in
            v.hidden = false
        }
        ServiceContainer.instance.addObserver(self, selector: #selector(EntryNavigationViewController.onServicesAllReady(_:)), name: ServiceContainer.OnAllServicesReady, object: nil)
        ServiceContainer.instance.initContainer("iDiaries", services: ServicesConfig)
        ServiceContainer.instance.userLogin("default")
    }
    
    func onServicesAllReady(a:NSNotification) {
        ServiceContainer.instance.removeObserver(self)
        
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(EntryNavigationViewController.showMainViewController(_:)), userInfo: self, repeats: false)
    }
    
    func showMainViewController(_:NSTimer?){
        let mc = MainViewController.instanceFromStoryBoard("Main", identifier: "MainViewController")
        let nc = UINavigationController(rootViewController: mc)
        ColorSets.navBarTintColor = UIColor.whiteColor()
        ColorSets.navBarTitleColor = UIColor.whiteColor()
        ColorSets.navBarBcgColor = self.navigationBar.barTintColor!
        ColorSets.themeColor = ColorSets.navBarBcgColor
        self.presentViewController(nc, animated: false){
            ServiceContainer.getTimeMailService().requestReminderPermission()
        }
    }
}
