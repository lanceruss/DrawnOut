//
//  EndGameStackOnlyViewController.swift
//  Fictionary
//
//  Created by Ernie Barojas on 7/13/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import Firebase

class EndGameStackOnlyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

            print(arrayToPass)

        self.view.backgroundColor = UIColor.pastelGreen()

    
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayToPass.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! EndGameStackOnlyCustomTableViewCell

        if let image = arrayToPass[indexPath.row] as? UIImage {
            //cell.imageView?.image = items[indexPath.row] as! UIImage
            cell.imageView6.hidden = false
            cell.imageView6.image = arrayToPass[indexPath.row] as! UIImage
            cell.cellCaptionTextView.hidden = true
            tableView.rowHeight = 250

            
        } else {
            //cell.textLabel?.text = "\(items[indexPath.row])"
            
            // image from text
            /*
             let image1 = drawImagesAndText("\(array[indexPath.row])")
             tableView.rowHeight = 100
             cell.imageView5?.image = image1
             */
            
            // just display text
            cell.imageView6.hidden = true
            cell.textLabel!.text = "\(arrayToPass[indexPath.row])"
            cell.cellCaptionTextView.hidden = false
            tableView.rowHeight = 100
            
        }
        
        return cell
    }


    @IBAction func onBackButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
