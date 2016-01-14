//
//  LineReportController.swift
//  iDiaries
//
//  Created by AlexChow on 16/1/14.
//  Copyright © 2016年 GStudio. All rights reserved.
//

import Foundation
import PNChart

//MARK: MoodLineReportController
class MoodLineReportController: UIViewController
{
    
    @IBOutlet weak var lineChartView: PNLineChart!
    
    //MARK: life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        initLineChartView()
    }
    
    //MARK: inits
    private func initLineChartView()
    {
        let data = PNLineChartData()

    }
    
    //MARK: actions
    @IBAction func next(sender: AnyObject)
    {
        
    }
}
