//
//  DiaryLockedCell.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/4.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import UIKit
import KKGestureLockView

enum PasswordLockerType
{
    case ValidatePassword
    case SetPassword
}

typealias ValidateSuccessCallback = ()->Void
typealias SetPasswordSuccessCallback = (String)->Void

class PasswordLocker: NSObject,KKGestureLockViewDelegate {
    init(type:PasswordLockerType) {
        self.type = type
    }
    private var type:PasswordLockerType = .ValidatePassword
    private var password:String!
    private var lockViewController:LockViewController!
    
    private var onValidateSuc:ValidateSuccessCallback!
    private var onSetPasswordSuc:SetPasswordSuccessCallback!
    
    static func showValidateLocker(rootController:ViewController,callback:ValidateSuccessCallback)
    {
        let locker = PasswordLocker(type: .ValidatePassword)
        locker.onValidateSuc = callback
        locker.showLocker(rootController)
    }
    
    static func showSetPasswordLocker(rootController:ViewController,callback:SetPasswordSuccessCallback)
    {
        let locker = PasswordLocker(type: .SetPassword)
        locker.onSetPasswordSuc = callback
        locker.showLocker(rootController)
    }
    
    func showLocker(rootController:UIViewController)
    {
        lockViewController = LockViewController.instanceFromStoreboard()
        lockViewController.delegate = self
        rootController.navigationController?.pushViewController(lockViewController, animated: true)
        switch type
        {
        case .SetPassword:lockViewController.message = NSLocalizedString("SWIPE_KEY_SET_PASSWORD", comment: "")
        case .ValidatePassword:lockViewController.message = NSLocalizedString("SWIPE_KEY_VALIDATE_PASSWORD", comment: "")
        }
    }
    
    //MARK:KKGestureLockViewDelegate
    func gestureLockView(gestureLockView: KKGestureLockView!, didBeginWithPasscode passcode: String!) {
    }
    
    func gestureLockView(gestureLockView: KKGestureLockView!, didCanceledWithPasscode passcode: String!) {
    }
    
    func gestureLockView(gestureLockView: KKGestureLockView!, didEndWithPasscode passcode: String!) {
        if type == .ValidatePassword
        {
            if DiaryService.sharedInstance.checkPswCorrent(passcode)
            {
                lockViewController.navigationController?.popViewControllerAnimated(true)
                if let handler = onValidateSuc
                {
                    handler()
                }
            }else
            {
                lockViewController.message = NSLocalizedString("INCORRECT_PASSWORD", comment: "Incorrect Password,Please Retry")
                lockViewController.messageLabel.shakeAnimationForView()
                SystemSoundHelper.vibrate()
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
                if let handler = onSetPasswordSuc
                {
                    handler(passcode)
                }
            }else{
                password = nil
                SystemSoundHelper.vibrate()
                lockViewController.messageLabel.shakeAnimationForView()
                lockViewController.message = NSLocalizedString("REPEAT_PASSWORD_NOT_MATCH", comment: "Twice swipe not match,reset password again")
            }
        }
    }
}