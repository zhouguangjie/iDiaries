//
//  NewDiaryMarkCell.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/4.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import UIKit
import AudioToolbox

class NewDiaryMarkCell: NewDiaryBaseCell,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    static let reuseId = "NewDiaryMarkCell"
    var typedMarks:TypedMarks!
    static let minimumInteritemSpacing:CGFloat = 3
    @IBOutlet weak var expandCellMarkImgView: UIImageView!
    @IBOutlet weak var marksCollectionView: UICollectionView!{
        didSet{
            marksCollectionView.delegate = self
            marksCollectionView.dataSource = self
            marksCollectionView.allowsSelection = true
            marksCollectionView.allowsMultipleSelection = true
            let flowLayout = UICollectionViewFullFlowLayout()
            flowLayout.minimumSpacing = NewDiaryMarkCell.minimumInteritemSpacing
            marksCollectionView.collectionViewLayout = flowLayout
        }
    }
    @IBOutlet weak var marksCollectionViewHeight: NSLayoutConstraint!
    private(set) var cellShrinkLabel:UILabel!
    private(set) var selectedMarks = [DiaryMark](){
        didSet{
            cellShrinkLabel?.text = selectedMarks.map{String.isNullOrWhiteSpace($0.emoji) ? $0.displayName : $0.emoji}.joinWithSeparator("")
        }
    }
    
    func clearSelected()
    {
        selectedMarks.removeAll()
        refresh()
    }
    
    func refresh()
    {
        marksCollectionView.reloadData()
    }
    
    //MARK: collection view delegate
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if typedMarks == nil
        {
            return 0
        }
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(DiaryMarkCell.reuseId, forIndexPath: indexPath) as! DiaryMarkCell
        let markStruct = typedMarks.marks[indexPath.row]
        let markModel = DiaryMark(markStruct: markStruct)
        cell.markModel = markModel
        cell.refresh()
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if typedMarks == nil
        {
            return 0
        }
        return typedMarks.marks.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! DiaryMarkCell
        SystemSoundHelper.keyTink()
        if !selectedMarks.contains(cell.markModel){
            selectedMarks.append(cell.markModel)
        }
        cell.refresh()
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! DiaryMarkCell
        SystemSoundHelper.keyTock()
        selectedMarks.removeElement { (itemInArray) -> Bool in
            itemInArray.name == cell.markModel.name
        }
        cell.refresh()
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView{
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "MarkCollectionHeader", forIndexPath: indexPath)
        let headerText = NSLocalizedString(self.typedMarks.markType, comment: "")
        if let title = header.viewWithTag(1) as? UILabel{
            title.text = headerText
        }
        if self.cellShrinkLabel == nil{
            if let shrinkLabel = header.viewWithTag(2) as? UILabel{
                shrinkLabel.text = nil
                self.cellShrinkLabel = shrinkLabel
            }
        }
        
        return header
    }

    //MARK: collection view flowlayout delegate
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let markModel = typedMarks.marks[indexPath.row]
        return DiaryMarkCell.cellSize(markModel)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 3, left: 3, bottom: 7, right: 3)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(10, 23)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return NewDiaryMarkCell.minimumInteritemSpacing
    }
}