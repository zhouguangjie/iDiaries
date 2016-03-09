//
//  DiaryLockedCell.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/4.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import UIKit
import KKGestureLockView
import LocalAuthentication

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
    private var useTouchId:Bool = false
    
    private var onValidateSuc:ValidateSuccessCallback!
    private var onSetPasswordSuc:SetPasswordSuccessCallback!
    
    static func showValidateLocker(rootController:UIViewController,useTouchId:Bool,callback:ValidateSuccessCallback)
    {
        let locker = PasswordLocker(type: .ValidatePassword)
        locker.onValidateSuc = callback
        locker.useTouchId = useTouchId
        locker.showLocker(rootController)
    }
    
    static func showSetPasswordLocker(rootController:UIViewController,callback:SetPasswordSuccessCallback)
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
        case .SetPassword:
            lockViewController.message = NSLocalizedString("SWIPE_KEY_SET_PASSWORD", comment: "")
        case .ValidatePassword:
            if useTouchId{
                showTouchIdValidation()
            }
            lockViewController.message = NSLocalizedString("SWIPE_KEY_VALIDATE_PASSWORD", comment: "")
        }
    }
    
    private func showTouchIdValidation()
    {
        let laCtx = LAContext()
        let policy = LAPolicy.DeviceOwnerAuthenticationWithBiometrics
        if laCtx.canEvaluatePolicy(policy, error: nil){
                laCtx.evaluatePolicy(policy, localizedReason: "USE_TOUCH_ID_VALIDATION".localizedString(), reply: { (suc, error) -> Void in
                    if suc
                    {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.lockViewController.navigationController?.popViewControllerAnimated(true)
                            if let handler = self.onValidateSuc
                            {
                                handler()
                            }
                        })
                    }
                })
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