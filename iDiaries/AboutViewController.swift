//
//  AboutViewController.swift
//  Bahamut
//
//  Created by AlexChow on 15/11/10.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import UIKit
import MessageUI
import StoreKit

class AboutViewController: UIViewController,MFMailComposeViewControllerDelegate,SKPaymentTransactionObserver,SKProductsRequestDelegate{

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        MobClick.beginLogPageView("AboutView")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        MobClick.endLogPageView("AboutView")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.changeNavigationBarColor()
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    @IBAction func showInAppStore(sender: AnyObject)
    {
        let url = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=\(iDiariesConfig.appStoreId)"
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }

    @IBAction func mailToBahamutSharelink(sender: AnyObject) {
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setSubject("iDiaries Feedback")
        mail.setToRecipients([iDiariesConfig.officalMail])
        self.presentViewController(mail, animated: true, completion: nil)

    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func rmb1(sender: AnyObject)
    {
        payForApp("1")
    }
    
    var productId:String = ""
    private func payForApp(type:String)
    {
        productId = "com.idiaries.ios.pay\(type)"
        if SKPaymentQueue.canMakePayments()
        {
            let req = SKProductsRequest(productIdentifiers: [productId])
            req.delegate = self
            req.start()
        }else
        {
            self.playToast("CANT_PAY_IN_APP".localizedString())
        }
    }
    
    func request(request: SKRequest, didFailWithError error: NSError) {
        NSLog("------------------错误-----------------:%@", error);
    }
    
    func requestDidFinish(request: SKRequest) {
        NSLog("------------反馈信息结束-----------------");
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        
        let product = response.products
        if product.count == 0
        {
            NSLog("--------------没有商品------------------")
            return
        }
        
        NSLog("productID:%@", response.invalidProductIdentifiers)
        NSLog("产品付费数量:%d",product.count)
        
        var p:SKProduct! = nil
        for pro in product {
            NSLog("%@", pro.description)
            NSLog("%@", pro.localizedTitle)
            NSLog("%@", pro.localizedDescription)
            NSLog("%@", pro.price.description)
            NSLog("%@", pro.productIdentifier)
            if pro.productIdentifier == self.productId
            {
                p = pro
            }
        }
        
        if p != nil{
            
            let payment = SKPayment(product: p)
            NSLog("发送购买请求");
            SKPaymentQueue.defaultQueue().addPayment(payment)
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for tran in transactions{
            switch (tran.transactionState) {
            case SKPaymentTransactionState.Purchased:
                NSLog("交易完成");
                break;
            case SKPaymentTransactionState.Purchasing:
                NSLog("商品添加进列表");
                break;
            case SKPaymentTransactionState.Restored:
                NSLog("已经购买过商品");
                break;
            case SKPaymentTransactionState.Failed:
                NSLog("交易失败");
                break;
            default:
                break;
            }
        }
    }
    
    static func showAbout(currentViewController:UIViewController)
    {
        let controller = instanceFromStoryBoard()
        if let nvController = currentViewController.navigationController
        {
            nvController.pushViewController(controller, animated: true)
        }
    }
    
    static func instanceFromStoryBoard() -> AboutViewController
    {
        return instanceFromStoryBoard("Main", identifier: "aboutViewController") as! AboutViewController
    }
}
