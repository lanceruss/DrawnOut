//
//  EndGameCollectionViewCell.swift
//  Fictionary
//
//  Created by Ernie Barojas on 7/11/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

class EndGameCollectionViewCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView? {
        didSet {
            tableView?.delegate = self
            tableView?.dataSource = self
        }
    }
    @IBOutlet weak var testCVLabel: UILabel!
    
    //var array = ["jackandjill", "image1.jpeg", "etphonehome", "image2.jpg", "everythingbutthesink", "image3.jpg", "bullinachinacloset", "image4.gif", "cowjumpedoverthemoon", "image5.jpg"]
    var array = [AnyObject]()

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! EndGameTableViewCell
        
        if let image = array[indexPath.row] as? UIImage {
            //cell.imageView?.image = items[indexPath.row] as! UIImage
            cell.imageView5.image = array[indexPath.row] as! UIImage
        } else {
            //cell.textLabel?.text = "\(items[indexPath.row])"
            let image1 = drawImagesAndText("\(array[indexPath.row])")
            cell.imageView5?.image = image1
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
        
        let attrs = [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 48)!, NSParagraphStyleAttributeName: paragraphStyle]
        
        string.drawWithRect(CGRect(x: 32, y: 32, width: 400, height: 200), options: .UsesLineFragmentOrigin, attributes: attrs, context: nil)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img
        
    }

    
    


    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("****** didSelectRowAtIndexPath: \(indexPath) - \(array[indexPath.row])")
        //print("from: \(array)")
        //            self.messageLabel.text = array[indexPath.row]
        
        //rowWasSelectedForImage("\(array[indexPath.row])")
        
    }
    
}
