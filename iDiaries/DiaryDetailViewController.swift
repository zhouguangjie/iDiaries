//
//  DiaryDetailViewController.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/10.
//  Copyright © 2015年 GStudio. All rights reserved.
//


//MARK:DiaryDetailCell
class DiaryDetailCell: UITableViewCell{
    static let reuseId = "DiaryDetailCell"
    var diary:DiaryModel!
    
    @IBOutlet weak var moodAndWeatherLabel: UILabel!
    @IBOutlet weak var diaryContentLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func refresh(){
        moodAndWeatherLabel.text = diary.weathers.map{$0.emoji!}.joinWithSeparator("") + diary.moods.map{$0.emoji!}.joinWithSeparator("")
        let content  = "\(NSDate(timeIntervalSince1970: diary.dateTime.doubleValue).toLocalDateString()) \(diary.summary.map{$0.displayName}.joinWithSeparator(" "))\n\( diary.mainContent)"
        diaryContentLabel.text = content
    }
}

//MARK:DiaryDetailViewController
class DiaryDetailViewController: UITableViewController {
    var diary:DiaryModel!
    
    //MARK: life process
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 48;
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    //MARK: table view delegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(DiaryDetailCell.reuseId, forIndexPath: indexPath) as! DiaryDetailCell
        cell.diary = self.diary
        cell.refresh()
        return cell
    }
}

