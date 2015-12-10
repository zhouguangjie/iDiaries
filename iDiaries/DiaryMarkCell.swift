//
//  DiaryMarkCell.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/3.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import UIKit

let MarkBorderColor = UIColor(hexString: "#0080FF")

extension DiaryMark
{
    var displayName:String{
        return NSLocalizedString(name, comment: "")
    }
}

//MARK: DiaryMarkCell
class DiaryMarkCell: UICollectionViewCell {

    static let reuseId = "DiaryMarkCell"
    @IBOutlet weak var markName: UILabel!

    static func cellSize(model:MarkStruct) -> CGSize
    {
        let modelDisplayName = NSLocalizedString(model.name, comment: "")
        return cellSizeFor("\(model.emoji ?? "")\(modelDisplayName)")
    }
    
    static func cellSize(model:DiaryMark) -> CGSize
    {
        return cellSizeFor("\(model.emoji ?? "")\(model.displayName)")
    }
    
    static func cellSizeFor(text:String) -> CGSize
    {
        let label = UILabel()
        label.text = text
        label.sizeToFit()
        return CGSizeMake(label.bounds.width + 3, label.bounds.height + 7)
    }
    
    var markModel:DiaryMark!
    func refresh(){
        markName.text = "\(markModel.emoji ?? "")\(markModel.displayName)"
        self.layer.cornerRadius = 14
        self.layer.borderColor = MarkBorderColor.CGColor
        self.layer.borderWidth = self.selected ? 3 : 1
    }
}
