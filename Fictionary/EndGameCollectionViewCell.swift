//
//  EndGameCollectionViewCell.swift
//  Fictionary
//
//  Created by Ernie Barojas on 7/11/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

protocol EndGameCellDelegate {
    func rowWasSelectedForImage(imageNamed: UIImage)
}

var arrayToPass = NSArray()


class EndGameCollectionViewCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var viewStackButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView? {
        didSet {
            tableView?.delegate = self
            tableView?.dataSource = self
        }
    }
    
    var delegate: EndGameCellDelegate?
    
    func rowWasSelectedForImage(imageNamed: UIImage) {
        delegate?.rowWasSelectedForImage(imageNamed)
    }
    
    
    @IBOutlet weak var testCVLabel: UILabel!
    
    //var array = ["jackandjill", "image1.jpeg", "etphonehome", "image2.jpg", "everythingbutthesink", "image3.jpg", "bullinachinacloset", "image4.gif", "cowjumpedoverthemoon", "image5.jpg"]
    
    var array = [AnyObject]()
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("\(array.count)")
        return array.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! EndGameTableViewCell
        
        if indexPath.row < array.count {
            
            if array[indexPath.row] is UIImage {
                //cell.imageView?.image = items[indexPath.row] as! UIImage
                cell.textCaption.hidden = true
                cell.imageView5.hidden = false
                tableView.rowHeight = 250
                cell.imageView5.image = array[indexPath.row] as? UIImage
            } else {
                //cell.textLabel?.text = "\(items[indexPath.row])"
                
                // image from text
                /*
                 let image1 = drawImagesAndText("\(array[indexPath.row])")
                 tableView.rowHeight = 100
                 cell.imageView5?.image = image1
                 */
                
                // just display text
                cell.imageView5.hidden = true
                cell.textCaption.hidden = false
                tableView.rowHeight = 100
                cell.textCaption.text = "\(array[indexPath.row])"
                
                
            }
            
        }
        
        return cell
        
        /*
         let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! EndGameTableViewCell
         cell.imageView5.image = array[indexPath.row] as! UIImage
         tableView.rowHeight = 130
         return cell
         */
        
    }
    
    func drawImagesAndText(string: String) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 512, height: 512), false, 0)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Center
        
        let attrs = [NSFontAttributeName: UIFont(name: "SF UI Text", size: 72)!, NSParagraphStyleAttributeName: paragraphStyle]
        
        string.drawWithRect(CGRect(x: 32, y: 100, width: 400, height: 400), options: .UsesLineFragmentOrigin, attributes: attrs, context: nil)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tableView?.reloadData()
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print("****** didSelectRowAtIndexPath: \(indexPath) - \(array[indexPath.row])")
        
        if let image = array[indexPath.row] as? UIImage {
            rowWasSelectedForImage(array[indexPath.row] as! UIImage)
            
        } else {
            print("Item not an image so no action on didselectrow")
        }
        
        
        
        
        //print("from: \(array)")
        //            self.messageLabel.text = array[indexPath.row]
        
        //rowWasSelectedForImage("\(array[indexPath.row])")
        
        
        
    }
    
    @IBAction func onViewStackButtonTapped(sender: AnyObject) {
        print("onViewStackButtonTapped")
        arrayToPass = array
    }
    
    
    
    
}
