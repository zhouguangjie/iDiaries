//
//  DiaryLockedCell.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/4.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import UIKit
import KKGestureLockView
import AudioToolbox

enum LockedCellStatus
{
    case NoPasswordStored
    case Validating
}

class DiaryLockedCell: UITableViewCell,KKGestureLockViewDelegate {
    static let reuseId = "DiaryLockedCell"
    var rootController:ViewController!
    @IBAction func unlock(sender: AnyObject) {
        
        
    }
}

enum PasswordLockerType
{
    case ValidatePassword
    case SetPassword
}

class PasswordLocker: NSObject,KKGestureLockViewDelegate {
    init(type:PasswordLockerType) {
        self.type = type
    }
    private var type:PasswordLockerType = .ValidatePassword
    private var password:String!
    private var lockViewController:LockViewController!
    private var rootController:ViewController!
    
    static func showValidateLocker(rootController:ViewController)
    {
        let locker = PasswordLocker(type: .ValidatePassword)
        locker.showLocker(rootController)
    }
    
    static func showSetPasswordLocker(rootController:ViewController)
    {
        let locker = PasswordLocker(type: .SetPassword)
        locker.showLocker(rootController)
    }
    
    func showLocker(rootController:ViewController)
    {
        self.rootController = rootController
        lockViewController = rootController.showLockView()
        lockViewController.delegate = self
        switch type
        {
        case .SetPassword:lockViewController.message = NSLocalizedString("SWIPE_KEY_SET_PASSWORD", comment: "")
        case .ValidatePassword:lockViewController.message = NSLocalizedString("SWIPE_KEY_VALIDATE_PASSWORD", comment: "")
        }
    }
    
    //MARK:KKGestureLockViewDelegate
    func gestureLockView(gestureLockView: KKGestureLockView!, didBeginWithPasscode passcode: String!) {
        print("didBeginWithPasscode:\(passcode)")
    }
    
    func gestureLockView(gestureLockView: KKGestureLockView!, didCanceledWithPasscode passcode: String!) {
        print("didCanceledWithPasscode:\(passcode)")
    }
    
    func gestureLockView(gestureLockView: KKGestureLockView!, didEndWithPasscode passcode: String!) {
        print("didEndWithPasscode:\(passcode)")
        if type == .ValidatePassword
        {
            if DiaryService.sharedInstance.checkPswCorrent(passcode)
            {
                lockViewController.navigationController?.popViewControllerAnimated(true)
                DiaryListManager.sharedInstance.unlockDiary()
            }else
            {
                lockViewController.message = NSLocalizedString("INCORRECT_PASSWORD", comment: "Incorrect Password,Please Retry")
                lockViewController.messageLabel.shakeAnimationForView()
                AudioServicesPlaySystemSound(1011)
            }
        }else if type == .SetPassword
        {
            if password == nil
            {
                password = passcode
                lockViewController.message = NSLocalizedString("REPEAT_PASSWORD", comment: "Repeat Password")
            }else if password == passcode{
                DiaryService.sharedInstance.setPassword(passcode)
                lockViewController.navigationController?.popViewControllerAnimated(true)
                DiaryListManager.sharedInstance.unlockDiary()
            }else{
                password = nil
                AudioServicesPlaySystemSound(1011)
                lockViewController.messageLabel.shakeAnimationForView()
                lockViewController.message = NSLocalizedString("REPEAT_PASSWORD_NOT_MATCH", comment: "Twice swipe not match,reset password again")
            }
        }
    }
}