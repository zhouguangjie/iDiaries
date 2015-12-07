//
//  SelectDateController.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/4.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import UIKit

class SelectDateController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    private var selectedDateCallback:((dateTime:NSDate!)->Void)!
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func done(sender: AnyObject) {
        if let handler = self.selectedDateCallback
        {
            handler(dateTime: self.datePicker.date)
        }
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    static func showDatePicker(rootController:UIViewController,date:NSDate,minDate:NSDate!,maxDate:NSDate!,selectedDateCallback:(dateTime:NSDate!)->Void)
    {
        let controller = instanceFromStoreboard()
        let nvController = UINavigationController(rootViewController: controller)
        nvController.changeNavigationBarColor()
        rootController.presentViewController(nvController, animated: true){
            controller.selectedDateCallback = selectedDateCallback
            controller.datePicker.minimumDate = minDate
            controller.datePicker.maximumDate = maxDate
            controller.datePicker.date = date
        }
    }
    
    static func instanceFromStoreboard() -> SelectDateController
    {
        return instanceFromStoryBoard("Main", identifier: "SelectDateController") as! SelectDateController
    }
}
