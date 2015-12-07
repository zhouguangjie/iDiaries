//
//  LockViewController.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/4.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import UIKit
import KKGestureLockView

class LockViewController: UIViewController {
    
    
    @IBOutlet weak var lockView: KKGestureLockView!
    
    @IBOutlet weak var messageLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        changeNavigationBarColor()
        messageLabel.text = message
        lockView.delegate = self.delegate
        lockView.normalGestureNodeImage = UIImage(named: "gesture_node_normal")
        lockView.selectedGestureNodeImage = UIImage(named: "gesture_node_selected")
        lockView.numberOfGestureNodes = 9
        lockView.gestureNodesPerRow = 3
        lockView.lineWidth = 12;
        self.view.addSubview(lockView)
    }
    var message:String = ""{
        didSet{
            if messageLabel != nil{
                messageLabel.text = message
            }
        }
    }
    var delegate:KKGestureLockViewDelegate!{
        didSet{
            if lockView != nil{
                lockView.delegate = self.delegate
            }
        }
    }
    
    static func instanceFromStoreboard() -> LockViewController
    {
        return instanceFromStoryBoard("Main", identifier: "LockViewController") as! LockViewController
    }
}
